import 'package:flutter/foundation.dart';
import 'package:learn_gdscript/data/models/localized_text.dart';

import 'curriculum_models.dart';
import 'lesson_models.dart';
import 'progress_models.dart';
import 'review_schedule.dart';
import 'model_json.dart';

@immutable
class ConceptDefinition {
  ConceptDefinition({
    required this.id,
    required this.lessonId,
    required List<String> prerequisiteIds,
    required this.x,
    required this.y,
  }) : prerequisiteIds = List.unmodifiable(prerequisiteIds) {
    if (id.trim().isEmpty) throw ArgumentError.value(id, 'id');
    if (lessonId.trim().isEmpty)
      throw ArgumentError.value(lessonId, 'lessonId');
    if (x < 0 || y < 0)
      throw ArgumentError('Concept positions must be non-negative.');
    if (this.prerequisiteIds.toSet().length != this.prerequisiteIds.length) {
      throw ArgumentError('Concept prerequisites must be unique.');
    }
  }

  final String id;
  final String lessonId;
  final List<String> prerequisiteIds;
  final double x;
  final double y;

  factory ConceptDefinition.fromJson(JsonObject json) {
    final x = _number(json, 'x');
    final y = _number(json, 'y');
    return ConceptDefinition(
      id: requiredString(json, 'id'),
      lessonId: requiredString(json, 'lessonId'),
      prerequisiteIds: json['prerequisiteIds'] == null
          ? const []
          : stringList(json, 'prerequisiteIds'),
      x: x,
      y: y,
    );
  }

  JsonObject toJson() => {
    'id': id,
    'lessonId': lessonId,
    'prerequisiteIds': prerequisiteIds,
    'x': x,
    'y': y,
  };

  static double _number(JsonObject json, String key) {
    final value = requiredValue(json, key);
    if (value is! num || !value.isFinite || value < 0) {
      throw FormatException(
        'Field "$key" must be a finite non-negative number.',
      );
    }
    return value.toDouble();
  }
}

@immutable
class ConceptMapManifest {
  ConceptMapManifest({required List<ConceptDefinition> concepts})
    : concepts = List.unmodifiable(concepts) {
    final ids = this.concepts.map((concept) => concept.id).toSet();
    if (ids.length != this.concepts.length) {
      throw ArgumentError('Concept IDs must be unique.');
    }
    for (final concept in this.concepts) {
      if (concept.prerequisiteIds.any((id) => !ids.contains(id))) {
        throw ArgumentError(
          'Concept "${concept.id}" references an unknown prerequisite.',
        );
      }
      if (concept.prerequisiteIds.contains(concept.id)) {
        throw ArgumentError('A concept cannot depend on itself.');
      }
    }
    _validateAcyclic();
  }

  final List<ConceptDefinition> concepts;

  factory ConceptMapManifest.fromJson(JsonObject json) {
    final items = requiredList(json, 'concepts');
    return ConceptMapManifest(
      concepts: [
        for (var index = 0; index < items.length; index++)
          ConceptDefinition.fromJson(
            _asObject(items[index], 'concepts[$index]'),
          ),
      ],
    );
  }

  JsonObject toJson() => {
    'concepts': concepts.map((concept) => concept.toJson()).toList(),
  };

  void _validateAcyclic() {
    final byId = {for (final concept in concepts) concept.id: concept};
    final visiting = <String>{};
    final visited = <String>{};

    void visit(String id) {
      if (visited.contains(id)) return;
      if (!visiting.add(id)) {
        throw ArgumentError('Concept prerequisites must not contain cycles.');
      }
      for (final prerequisiteId in byId[id]!.prerequisiteIds) {
        visit(prerequisiteId);
      }
      visiting.remove(id);
      visited.add(id);
    }

    for (final concept in concepts) {
      visit(concept.id);
    }
  }

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

@immutable
class ConceptMapContent {
  ConceptMapContent({
    required this.manifest,
    required Map<String, Lesson> lessons,
    required Map<String, Unit> units,
  }) : lessons = Map.unmodifiable(lessons),
       units = Map.unmodifiable(units);

  final ConceptMapManifest manifest;
  final Map<String, Lesson> lessons;
  final Map<String, Unit> units;
}

@immutable
class ConceptMapReviewCard {
  const ConceptMapReviewCard({
    required this.id,
    required this.conceptId,
    required this.lessonId,
    required this.prompt,
    required this.codeContext,
    required this.answerCode,
    required this.answerExplanation,
  });

  final String id;
  final String conceptId;
  final String lessonId;
  final LocalizedText prompt;
  final String codeContext;
  final String answerCode;
  final LocalizedText answerExplanation;
}

@immutable
class ConceptMapSnapshot {
  ConceptMapSnapshot({
    required this.content,
    required this.progress,
    required Map<String, ReviewSchedule> schedules,
    required List<ConceptMapReviewCard> dueCards,
    required this.loadedAt,
  }) : schedules = Map.unmodifiable(schedules),
       dueCards = List.unmodifiable(dueCards);

  final ConceptMapContent content;
  final UserProgress progress;
  final Map<String, ReviewSchedule> schedules;
  final List<ConceptMapReviewCard> dueCards;
  final DateTime loadedAt;

  List<ConceptMapReviewCard> get allCards {
    final cards = <ConceptMapReviewCard>[];
    for (final definition in content.manifest.concepts) {
      final lesson = content.lessons[definition.lessonId]!;
      for (final exercise in lesson.exercises) {
        cards.add(
          ConceptMapReviewCard(
            id: exercise.id,
            conceptId: definition.id,
            lessonId: lesson.id,
            prompt: exercise.prompt,
            codeContext: exercise.starterCode,
            answerCode: exercise.solutionCode,
            answerExplanation: lesson.objective,
          ),
        );
      }
    }
    return List.unmodifiable(cards);
  }

  List<ConceptMapReviewCard> dueCardsAt(DateTime now) {
    final currentTime = now.toUtc();
    final definitionsById = {
      for (final definition in content.manifest.concepts)
        definition.id: definition,
    };
    return allCards
        .where((card) {
          final schedule = schedules[card.id];
          if (schedule != null) {
            return !schedule.nextReviewAt.isAfter(currentTime);
          }
          final concept = definitionsById[card.conceptId]!;
          return progress.lessonsProgress[concept.lessonId]?.status ==
              LessonStatus.completed;
        })
        .toList(growable: false)
      ..sort((a, b) {
        final aDate = schedules[a.id]?.nextReviewAt;
        final bDate = schedules[b.id]?.nextReviewAt;
        if (aDate == null) return bDate == null ? 0 : -1;
        if (bDate == null) return 1;
        return aDate.compareTo(bDate);
      });
  }
}
