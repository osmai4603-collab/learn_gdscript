import 'dart:convert';
import 'dart:io';

import 'audit_models.dart';
import 'config/validation_rules.dart';

class AuditLocalizedText {
  const AuditLocalizedText({required this.ar, required this.en});

  final String ar;
  final String en;
}

class AuditUnit {
  const AuditUnit({
    required this.id,
    required this.order,
    required this.lessonIds,
  });

  final String id;
  final int order;
  final List<String> lessonIds;
}

class AuditExerciseTestCase {
  const AuditExerciseTestCase({
    required this.expectedOutput,
    this.setupCode,
  });

  final String expectedOutput;
  final String? setupCode;
}

class AuditExercise {
  const AuditExercise({
    required this.id,
    required this.lessonId,
    required this.type,
    required this.prompt,
    required this.options,
    required this.correctOptionIndex,
    required this.steps,
    required this.testCases,
    required this.hints,
    required this.order,
  });

  final String id;
  final String lessonId;
  final String type;
  final AuditLocalizedText prompt;
  final List<AuditLocalizedText> options;
  final int? correctOptionIndex;
  final List<AuditLocalizedText> steps;
  final List<AuditExerciseTestCase> testCases;
  final List<AuditLocalizedText> hints;
  final int order;
}

class AuditLesson {
  const AuditLesson({
    required this.id,
    required this.unitId,
    required this.estimatedMinutes,
    required this.contentMarkdown,
    required this.documentationSources,
    required this.exercises,
    required this.order,
  });

  final String id;
  final String unitId;
  final int estimatedMinutes;
  final AuditLocalizedText contentMarkdown;
  final List<String> documentationSources;
  final List<AuditExercise> exercises;
  final int order;
}

class AuditConceptDefinition {
  const AuditConceptDefinition({
    required this.id,
    required this.lessonId,
    required this.prerequisiteIds,
    required this.x,
    required this.y,
  });

  final String id;
  final String lessonId;
  final List<String> prerequisiteIds;
  final double x;
  final double y;
}

class LessonRecord {
  const LessonRecord({
    required this.lesson,
    required this.unit,
    required this.unitDirectory,
    required this.file,
    required this.raw,
  });

  final AuditLesson lesson;
  final AuditUnit unit;
  final String unitDirectory;
  final File file;
  final Map<String, Object?> raw;
}

class AuditContext {
  AuditContext(this.root, this.report);

  final Directory root;
  final AuditReport report;
  final units = <AuditUnit>[];
  final lessons = <LessonRecord>[];
  final concepts = <AuditConceptDefinition>[];
  final allLessonIds = <String>{};

  Future<void> load({String? unitFilter}) async {
    final manifestFile = File(
      '${root.path}/assets/curriculum/manifest.json',
    );
    if (!manifestFile.existsSync()) {
      report.add(
        IssueSeverity.error,
        'schema',
        'Curriculum manifest was not found.',
        path: pathFor(manifestFile),
      );
      return;
    }

    Map<String, Object?> curriculum;
    try {
      curriculum = _readObject(manifestFile);
      _requiredString(curriculum, 'version');
      _requiredString(curriculum, 'targetGDScriptVersion');
      final rawUnits = _requiredList(curriculum, 'units');
      final unitIds = <String>{};
      for (var index = 0; index < rawUnits.length; index++) {
        final unitJson = _asObject(rawUnits[index], 'units[$index]');
        final unit = _parseUnit(unitJson);
        if (!unitIds.add(unit.id)) {
          report.add(
            IssueSeverity.error,
            'identifiers',
            'Duplicate unit ID "${unit.id}".',
            path: pathFor(manifestFile),
          );
        }
        for (final lessonId in unit.lessonIds) {
          if (!allLessonIds.add(lessonId)) {
            report.add(
              IssueSeverity.error,
              'identifiers',
              'Lesson ID "$lessonId" appears more than once in the curriculum manifest.',
              path: pathFor(manifestFile),
            );
          }
        }

        final directory = unit.id.replaceFirst('unit_', '');
        if (unitFilter != null &&
            !directory.startsWith(unitFilter) &&
            unit.id != unitFilter) {
          continue;
        }
        units.add(unit);
        final unitFile = File(
          '${root.path}/assets/curriculum/units/$directory/unit.json',
        );
        if (!unitFile.existsSync()) {
          report.add(
            IssueSeverity.error,
            'identifiers',
            'Missing unit file for "${unit.id}".',
            path: pathFor(unitFile),
          );
          continue;
        }
        try {
          final parsedUnit = _parseUnit(_readObject(unitFile));
          if (parsedUnit.id != unit.id) {
            report.add(
              IssueSeverity.error,
              'identifiers',
              'Unit file ID "${parsedUnit.id}" does not match "${unit.id}".',
              path: pathFor(unitFile),
            );
          }
          if (parsedUnit.lessonIds.length != unit.lessonIds.length ||
              !parsedUnit.lessonIds.toSet().containsAll(unit.lessonIds)) {
            report.add(
              IssueSeverity.error,
              'identifiers',
              'Unit lesson IDs do not match the curriculum manifest.',
              path: pathFor(unitFile),
            );
          }
        } on Object catch (error) {
          report.add(
            IssueSeverity.error,
            'schema',
            'Invalid unit JSON: $error',
            path: pathFor(unitFile),
          );
          continue;
        }

        for (final lessonId in unit.lessonIds) {
          final lessonFile = File(
            '${root.path}/assets/curriculum/units/$directory/$lessonId.json',
          );
          if (!lessonFile.existsSync()) {
            report.add(
              IssueSeverity.error,
              'identifiers',
              'Missing lesson file for "$lessonId".',
              path: pathFor(lessonFile),
            );
            continue;
          }
          try {
            final lessonJson = _readObject(lessonFile);
            lessons.add(
              LessonRecord(
                lesson: _parseLesson(lessonJson),
                unit: unit,
                unitDirectory: directory,
                file: lessonFile,
                raw: lessonJson,
              ),
            );
          } on Object catch (error) {
            report.add(
              IssueSeverity.error,
              'schema',
              'Invalid lesson JSON: $error',
              path: pathFor(lessonFile),
            );
          }
        }
      }

      if (unitFilter != null && units.isEmpty) {
        report.add(
          IssueSeverity.error,
          'identifiers',
          'No curriculum unit matches "$unitFilter".',
          path: pathFor(manifestFile),
        );
      }
      if (unitFilter == null) {
        _checkUnlistedLessonFiles();
      }
    } on Object catch (error) {
      report.add(
        IssueSeverity.error,
        'schema',
        'Invalid curriculum manifest: $error',
        path: pathFor(manifestFile),
      );
      return;
    }

    _loadConceptMap();
  }

  void _checkUnlistedLessonFiles() {
    final lessonRoot = Directory('${root.path}/assets/curriculum/units');
    if (!lessonRoot.existsSync()) return;
    final expectedFiles = <String>{
      for (final unit in units)
        for (final lessonId in unit.lessonIds)
          '${root.path}/assets/curriculum/units/'
          '${unit.id.replaceFirst('unit_', '')}/$lessonId.json',
    };
    for (final file in lessonRoot.listSync(recursive: true).whereType<File>()) {
      if (file.uri.pathSegments.last.startsWith('lesson_') &&
          file.path.endsWith('.json') &&
          !expectedFiles.contains(file.path)) {
        report.add(
          IssueSeverity.error,
          'identifiers',
          'Lesson file is not listed in the curriculum manifest.',
          path: pathFor(file),
        );
      }
    }
  }

  void _loadConceptMap() {
    final conceptFile = File('${root.path}/assets/concept_map/manifest.json');
    if (!conceptFile.existsSync()) {
      report.add(
        IssueSeverity.error,
        'concept-map',
        'Concept map manifest was not found.',
        path: pathFor(conceptFile),
      );
      return;
    }
    try {
      final json = _readObject(conceptFile);
      final items = _requiredList(json, 'concepts');
      for (var index = 0; index < items.length; index++) {
        final item = _asObject(items[index], 'concepts[$index]');
        final id = _requiredString(item, 'id');
        final lessonId = _requiredString(item, 'lessonId');
        final prerequisites = item['prerequisiteIds'] == null
            ? <String>[]
            : _stringList(item, 'prerequisiteIds');
        final x = _requiredNumber(item, 'x');
        final y = _requiredNumber(item, 'y');
        concepts.add(
          AuditConceptDefinition(
            id: id,
            lessonId: lessonId,
            prerequisiteIds: prerequisites,
            x: x,
            y: y,
          ),
        );
      }
      _validateConceptGraph(conceptFile);
    } on Object catch (error) {
      report.add(
        IssueSeverity.error,
        'concept-map',
        'Invalid concept map manifest: $error',
        path: pathFor(conceptFile),
      );
    }
  }

  void _validateConceptGraph(File conceptFile) {
    final ids = <String>{};
    for (final concept in concepts) {
      if (!ids.add(concept.id)) {
        report.add(
          IssueSeverity.error,
          'concept-map',
          'Duplicate concept ID "${concept.id}".',
          path: pathFor(conceptFile),
        );
      }
    }
    final byId = {for (final concept in concepts) concept.id: concept};
    final visiting = <String>{};
    final visited = <String>{};
    void visit(String id) {
      if (visited.contains(id)) return;
      if (!visiting.add(id)) {
        throw const FormatException(
          'Concept prerequisites must not contain cycles.',
        );
      }
      final concept = byId[id];
      if (concept != null) {
        for (final prerequisiteId in concept.prerequisiteIds) {
          if (!byId.containsKey(prerequisiteId)) {
            throw FormatException(
              'Concept "$id" references unknown prerequisite "$prerequisiteId".',
            );
          }
          if (prerequisiteId == id) {
            throw FormatException('Concept "$id" cannot depend on itself.');
          }
          visit(prerequisiteId);
        }
      }
      visiting.remove(id);
      visited.add(id);
    }

    for (final concept in concepts) {
      visit(concept.id);
    }
  }

  AuditUnit _parseUnit(Map<String, Object?> json) {
    final id = _requiredString(json, 'id');
    _parseLocalizedText(json, 'title');
    _parseLocalizedText(json, 'description');
    _requiredString(json, 'iconName');
    final order = _requiredInt(json, 'order', minimum: 0);
    final lessonIds = _stringList(json, 'lessonIds');
    if (lessonIds.toSet().length != lessonIds.length) {
      throw const FormatException('Unit lesson IDs must be unique.');
    }
    return AuditUnit(id: id, order: order, lessonIds: lessonIds);
  }

  AuditLesson _parseLesson(Map<String, Object?> json) {
    final id = _requiredString(json, 'id');
    final unitId = _requiredString(json, 'unitId');
    _parseLocalizedText(json, 'title');
    _parseLocalizedText(json, 'objective');
    final estimatedMinutes = _requiredInt(
      json,
      'estimatedMinutes',
      minimum: 0,
    );
    final order = _requiredInt(json, 'order', minimum: 0);
    final contentMarkdown = _parseLocalizedText(json, 'contentMarkdown');
    if (json.containsKey('documentation') && json['documentation'] != null) {
      _parseLocalizedText(json, 'documentation');
    }
    final sources = <String>[];
    for (final source in _optionalList(json, 'documentationSources')) {
      final sourceJson = _asObject(source, 'documentationSources item');
      _parseLocalizedText(sourceJson, 'title');
      sources.add(_requiredString(sourceJson, 'url'));
    }
    if (json.containsKey('exampleCode') && json['exampleCode'] != null) {
      _requiredOptionalString(json, 'exampleCode');
    }
    final exercises = [
      for (final item in _optionalList(json, 'exercises'))
        _parseExercise(_asObject(item, 'exercise')),
    ];
    return AuditLesson(
      id: id,
      unitId: unitId,
      estimatedMinutes: estimatedMinutes,
      contentMarkdown: contentMarkdown,
      documentationSources: sources,
      exercises: exercises,
      order: order,
    );
  }

  AuditExercise _parseExercise(Map<String, Object?> json) {
    final id = _requiredString(json, 'id');
    final lessonId = _requiredString(json, 'lessonId');
    final type = _requiredString(json, 'type');
    if (!supportedExerciseTypes.contains(type)) {
      throw FormatException('Unsupported exercise type "$type".');
    }
    final prompt = _parseLocalizedText(json, 'prompt');
    if (json.containsKey('starterCode') && json['starterCode'] != null) {
      _requiredText(json, 'starterCode');
    }
    if (json.containsKey('solutionCode') && json['solutionCode'] != null) {
      _requiredText(json, 'solutionCode');
    }
    final options = [
      for (final item in _optionalList(json, 'options'))
        _parseLocalizedObject(item, 'options item'),
    ];
    final correctOptionIndex = json.containsKey('correctOptionIndex')
        ? _requiredInt(json, 'correctOptionIndex', minimum: 0)
        : null;
    final steps = [
      for (final item in _optionalList(json, 'steps'))
        _parseLocalizedObject(item, 'steps item'),
    ];
    final testCases = [
      for (final item in _optionalList(json, 'testCases'))
        _parseTestCase(_asObject(item, 'test case')),
    ];
    final hints = [
      for (final item in _optionalList(json, 'hints'))
        _parseLocalizedObject(item, 'hints item'),
    ];
    final order = _requiredInt(json, 'order', minimum: 0);
    if (type == 'multipleChoice' &&
        (options.length < 2 ||
            correctOptionIndex == null ||
            correctOptionIndex >= options.length)) {
      throw const FormatException(
        'Multiple-choice exercises need two options and a valid answer index.',
      );
    }
    if (type == 'guidedTask' && steps.isEmpty) {
      throw const FormatException('Guided tasks must have at least one step.');
    }
    return AuditExercise(
      id: id,
      lessonId: lessonId,
      type: type,
      prompt: prompt,
      options: options,
      correctOptionIndex: correctOptionIndex,
      steps: steps,
      testCases: testCases,
      hints: hints,
      order: order,
    );
  }

  AuditExerciseTestCase _parseTestCase(Map<String, Object?> json) {
    _parseLocalizedText(json, 'description');
    if (json.containsKey('setupCode') && json['setupCode'] != null) {
      _requiredText(json, 'setupCode');
    }
    final expectedOutput = _requiredText(json, 'expectedOutput');
    if (json.containsKey('ignoreWhitespace')) {
      _requiredBool(json, 'ignoreWhitespace');
    }
    if (json.containsKey('ignoreCase')) {
      _requiredBool(json, 'ignoreCase');
    }
    return AuditExerciseTestCase(
      expectedOutput: expectedOutput,
      setupCode: json['setupCode'] as String?,
    );
  }

  AuditLocalizedText _parseLocalizedObject(Object? value, String field) =>
      _parseLocalizedMap(_asObject(value, field));

  AuditLocalizedText _parseLocalizedText(
    Map<String, Object?> json,
    String key,
  ) {
    final object = _asObject(_requiredValue(json, key), key);
    return _parseLocalizedMap(object);
  }

  AuditLocalizedText _parseLocalizedMap(Map<String, Object?> object) {
    return AuditLocalizedText(
      ar: _requiredString(object, 'ar'),
      en: _requiredString(object, 'en'),
    );
  }

  Map<String, Object?> _readObject(File file) {
    final decoded = jsonDecode(file.readAsStringSync());
    return _asObject(decoded, file.path);
  }

  Map<String, Object?> _asObject(Object? value, String field) {
    if (value is! Map) {
      throw FormatException('Field "$field" must be an object.');
    }
    try {
      return Map<String, Object?>.from(value);
    } on TypeError {
      throw FormatException('Field "$field" must have string keys.');
    }
  }

  Object? _requiredValue(Map<String, Object?> json, String key) {
    if (!json.containsKey(key) || json[key] == null) {
      throw FormatException('Missing required field "$key".');
    }
    return json[key];
  }

  String _requiredString(Map<String, Object?> json, String key) {
    final value = _requiredValue(json, key);
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('Field "$key" must be a non-empty string.');
    }
    return value;
  }

  String _requiredText(Map<String, Object?> json, String key) {
    final value = _requiredValue(json, key);
    if (value is! String) throw FormatException('Field "$key" must be a string.');
    return value;
  }

  String? _requiredOptionalString(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is! String) {
      throw FormatException('Field "$key" must be a string or null.');
    }
    return value;
  }

  int _requiredInt(
    Map<String, Object?> json,
    String key, {
    int? minimum,
  }) {
    final value = _requiredValue(json, key);
    if (value is! int || (minimum != null && value < minimum)) {
      throw FormatException(
        minimum == null
            ? 'Field "$key" must be an integer.'
            : 'Field "$key" must be an integer >= $minimum.',
      );
    }
    return value;
  }

  bool _requiredBool(Map<String, Object?> json, String key) {
    final value = _requiredValue(json, key);
    if (value is! bool) throw FormatException('Field "$key" must be a boolean.');
    return value;
  }

  double _requiredNumber(Map<String, Object?> json, String key) {
    final value = _requiredValue(json, key);
    if (value is! num || !value.isFinite || value < 0) {
      throw FormatException(
        'Field "$key" must be a finite non-negative number.',
      );
    }
    return value.toDouble();
  }

  List<Object?> _requiredList(Map<String, Object?> json, String key) {
    final value = _requiredValue(json, key);
    if (value is! List) throw FormatException('Field "$key" must be a list.');
    return value.cast<Object?>();
  }

  List<Object?> _optionalList(Map<String, Object?> json, String key) =>
      json[key] == null ? <Object?>[] : _requiredList(json, key);

  List<String> _stringList(Map<String, Object?> json, String key) {
    final values = <String>[];
    for (final value in _requiredList(json, key)) {
      if (value is! String || value.trim().isEmpty) {
        throw FormatException(
          'Every item in "$key" must be a non-empty string.',
        );
      }
      values.add(value);
    }
    return values;
  }

  String pathFor(File file) {
    final absoluteRoot = root.absolute.path;
    final absolutePath = file.absolute.path;
    return absolutePath.startsWith('$absoluteRoot/')
        ? absolutePath.substring(absoluteRoot.length + 1)
        : absolutePath;
  }
}
