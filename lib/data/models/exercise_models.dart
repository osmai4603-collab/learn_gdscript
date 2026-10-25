import 'package:flutter/foundation.dart';

import 'localized_text.dart';
import 'model_json.dart';

enum ExerciseType {
  writeCode,
  fillBlank,
  predictOutput,
  fixBug,
  reorderSteps,
  multipleChoice,
  guidedTask,
}

@immutable
class ExerciseTestCase {
  final LocalizedText description;
  final String? setupCode;
  final String expectedOutput;
  final bool ignoreWhitespace;
  final bool ignoreCase;

  const ExerciseTestCase({
    required this.description,
    this.setupCode,
    required this.expectedOutput,
    this.ignoreWhitespace = false,
    this.ignoreCase = false,
  });

  factory ExerciseTestCase.fromJson(JsonObject json) => ExerciseTestCase(
    description: LocalizedText.fromJson(requiredObject(json, 'description')),
    setupCode: optionalString(json, 'setupCode'),
    expectedOutput: requiredText(json, 'expectedOutput'),
    ignoreWhitespace: json.containsKey('ignoreWhitespace')
        ? requiredBool(json, 'ignoreWhitespace')
        : false,
    ignoreCase: json.containsKey('ignoreCase')
        ? requiredBool(json, 'ignoreCase')
        : false,
  );

  JsonObject toJson() => {
    'description': description.toJson(),
    'setupCode': setupCode,
    'expectedOutput': expectedOutput,
    'ignoreWhitespace': ignoreWhitespace,
    'ignoreCase': ignoreCase,
  };
}

@immutable
class Exercise {
  final String id;
  final String lessonId;
  final ExerciseType type;
  final LocalizedText prompt;
  final String starterCode;
  final String solutionCode;
  final List<LocalizedText> options;
  final int? correctOptionIndex;
  final List<LocalizedText> steps;
  final List<ExerciseTestCase> testCases;
  final List<LocalizedText> hints;
  final int order;

  Exercise({
    required this.id,
    required this.lessonId,
    required this.type,
    required this.prompt,
    this.starterCode = '',
    this.solutionCode = '',
    List<LocalizedText> options = const [],
    this.correctOptionIndex,
    List<LocalizedText> steps = const [],
    required List<ExerciseTestCase> testCases,
    required List<LocalizedText> hints,
    required this.order,
  }) : options = List.unmodifiable(options),
       steps = List.unmodifiable(steps),
       testCases = List.unmodifiable(testCases),
       hints = List.unmodifiable(hints) {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id');
    }
    if (lessonId.trim().isEmpty) {
      throw ArgumentError.value(lessonId, 'lessonId');
    }
    if (order < 0) {
      throw ArgumentError.value(order, 'order');
    }
    if (type == ExerciseType.multipleChoice &&
        (options.length < 2 ||
            correctOptionIndex == null ||
            correctOptionIndex! < 0 ||
            correctOptionIndex! >= options.length)) {
      throw ArgumentError(
        'Multiple-choice exercises need at least two options and a valid answer.',
      );
    }
    if (type == ExerciseType.guidedTask && steps.isEmpty) {
      throw ArgumentError('Guided tasks need at least one step.');
    }
  }

  factory Exercise.fromJson(JsonObject json) {
    final typeName = requiredString(json, 'type');
    final exerciseType = ExerciseType.values.where(
      (value) => value.name == typeName,
    );
    if (exerciseType.isEmpty) {
      throw FormatException('Unsupported exercise type "$typeName".');
    }
    return Exercise(
      id: requiredString(json, 'id'),
      lessonId: requiredString(json, 'lessonId'),
      type: exerciseType.first,
      prompt: LocalizedText.fromJson(requiredObject(json, 'prompt')),
      starterCode: json.containsKey('starterCode')
          ? requiredText(json, 'starterCode')
          : '',
      solutionCode: json.containsKey('solutionCode')
          ? requiredText(json, 'solutionCode')
          : '',
      options: [
        for (final item
            in json['options'] == null
                ? const <Object?>[]
                : requiredList(json, 'options'))
          LocalizedText.fromJson(_asObject(item, 'options')),
      ],
      correctOptionIndex: json.containsKey('correctOptionIndex')
          ? requiredInt(json, 'correctOptionIndex', minimum: 0)
          : null,
      steps: [
        for (final item
            in json['steps'] == null
                ? const <Object?>[]
                : requiredList(json, 'steps'))
          LocalizedText.fromJson(_asObject(item, 'steps')),
      ],
      testCases: [
        for (final item
            in json['testCases'] == null
                ? const <Object?>[]
                : requiredList(json, 'testCases'))
          ExerciseTestCase.fromJson(_asObject(item, 'testCases')),
      ],
      hints: [
        for (final item
            in json['hints'] == null
                ? const <Object?>[]
                : requiredList(json, 'hints'))
          LocalizedText.fromJson(_asObject(item, 'hints')),
      ],
      order: requiredInt(json, 'order', minimum: 0),
    );
  }

  JsonObject toJson() => {
    'id': id,
    'lessonId': lessonId,
    'type': type.name,
    'prompt': prompt.toJson(),
    'starterCode': starterCode,
    'solutionCode': solutionCode,
    if (options.isNotEmpty)
      'options': options.map((option) => option.toJson()).toList(),
    if (correctOptionIndex != null) 'correctOptionIndex': correctOptionIndex,
    if (steps.isNotEmpty) 'steps': steps.map((step) => step.toJson()).toList(),
    'testCases': testCases.map((test) => test.toJson()).toList(growable: false),
    'hints': hints.map((hint) => hint.toJson()).toList(growable: false),
    'order': order,
  };

  static JsonObject _asObject(Object? value, String field) {
    if (value is! Map) {
      throw FormatException('Every item in "$field" must be an object.');
    }
    try {
      return Map<String, Object?>.from(value);
    } on TypeError {
      throw FormatException('Every item in "$field" must have string keys.');
    }
  }
}
