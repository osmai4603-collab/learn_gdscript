import 'package:flutter/foundation.dart';

import 'exercise_models.dart';
import 'localized_text.dart';
import 'model_json.dart';

@immutable
class DocumentationSource {
  const DocumentationSource({required this.title, required this.url});

  final LocalizedText title;
  final String url;

  factory DocumentationSource.fromJson(JsonObject json) {
    final url = requiredString(json, 'url');
    final uri = Uri.tryParse(url);
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host != 'docs.godotengine.org') {
      throw const FormatException(
        'Documentation sources must use the official Godot documentation site.',
      );
    }
    return DocumentationSource(
      title: LocalizedText.fromJson(requiredObject(json, 'title')),
      url: url,
    );
  }

  JsonObject toJson() => {'title': title.toJson(), 'url': url};
}

@immutable
class Lesson {
  final String id;
  final String unitId;
  final LocalizedText title;
  final LocalizedText objective;
  final int estimatedMinutes;
  final int order;
  final LocalizedText contentMarkdown;
  final LocalizedText? documentation;
  final List<DocumentationSource> documentationSources;
  final String? exampleCode;
  final List<Exercise> exercises;

  Lesson({
    required this.id,
    required this.unitId,
    required this.title,
    required this.objective,
    required this.estimatedMinutes,
    required this.order,
    required this.contentMarkdown,
    this.documentation,
    List<DocumentationSource> documentationSources = const [],
    this.exampleCode,
    required List<Exercise> exercises,
  }) : documentationSources = List.unmodifiable(documentationSources),
       exercises = List.unmodifiable(exercises) {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id');
    }
    if (unitId.trim().isEmpty) {
      throw ArgumentError.value(unitId, 'unitId');
    }
    if (estimatedMinutes < 0) {
      throw ArgumentError.value(estimatedMinutes, 'estimatedMinutes');
    }
    if (order < 0) {
      throw ArgumentError.value(order, 'order');
    }
  }

  factory Lesson.fromJson(JsonObject json) => Lesson(
    id: requiredString(json, 'id'),
    unitId: requiredString(json, 'unitId'),
    title: LocalizedText.fromJson(requiredObject(json, 'title')),
    objective: LocalizedText.fromJson(requiredObject(json, 'objective')),
    estimatedMinutes: requiredInt(json, 'estimatedMinutes', minimum: 0),
    order: requiredInt(json, 'order', minimum: 0),
    contentMarkdown: LocalizedText.fromJson(
      requiredObject(json, 'contentMarkdown'),
    ),
    documentation: json.containsKey('documentation')
        ? LocalizedText.fromJson(requiredObject(json, 'documentation'))
        : null,
    documentationSources: [
      for (final item
          in json['documentationSources'] == null
              ? const <Object?>[]
              : requiredList(json, 'documentationSources'))
        DocumentationSource.fromJson(_asObject(item)),
    ],
    exampleCode: optionalString(json, 'exampleCode'),
    exercises: [
      for (final item
          in json['exercises'] == null
              ? const <Object?>[]
              : requiredList(json, 'exercises'))
        Exercise.fromJson(_asObject(item)),
    ],
  );

  JsonObject toJson() => {
    'id': id,
    'unitId': unitId,
    'title': title.toJson(),
    'objective': objective.toJson(),
    'estimatedMinutes': estimatedMinutes,
    'order': order,
    'contentMarkdown': contentMarkdown.toJson(),
    if (documentation != null) 'documentation': documentation!.toJson(),
    if (documentationSources.isNotEmpty)
      'documentationSources': documentationSources
          .map((source) => source.toJson())
          .toList(growable: false),
    'exampleCode': exampleCode,
    'exercises': exercises.map((item) => item.toJson()).toList(growable: false),
  };

  static JsonObject _asObject(Object? value) {
    if (value is! Map) {
      throw FormatException('Every exercise must be an object.');
    }
    try {
      return Map<String, Object?>.from(value);
    } on TypeError {
      throw FormatException('Every exercise must have string keys.');
    }
  }
}
