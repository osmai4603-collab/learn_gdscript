import 'package:flutter/foundation.dart';

import 'exercise_models.dart';
import 'localized_text.dart';
import 'model_json.dart';

@immutable
class Lesson {
  final String id;
  final String unitId;
  final LocalizedText title;
  final LocalizedText objective;
  final int estimatedMinutes;
  final int order;
  final LocalizedText contentMarkdown;
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
    this.exampleCode,
    required List<Exercise> exercises,
  }) : exercises = List.unmodifiable(exercises) {
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
