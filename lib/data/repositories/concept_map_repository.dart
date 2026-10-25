import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/concept_map_models.dart';
import '../models/curriculum_models.dart';
import '../models/lesson_models.dart';

class ConceptMapRepository {
  ConceptMapRepository({
    required AssetBundle assetBundle,
    this.manifestAsset = 'assets/concept_map/manifest.json',
  }) : _assetBundle = assetBundle;

  final AssetBundle _assetBundle;
  final String manifestAsset;

  Future<ConceptMapContent> load(Curriculum curriculum) async {
    final source = await _assetBundle.loadString(manifestAsset);
    final decoded = jsonDecode(source);
    if (decoded is! Map) {
      throw const FormatException('Concept map manifest must be a JSON object.');
    }

    final ConceptMapManifest manifest;
    try {
      manifest = ConceptMapManifest.fromJson(Map<String, Object?>.from(decoded));
    } on TypeError {
      throw const FormatException(
        'Concept map manifest must have string object keys.',
      );
    } on ArgumentError catch (error) {
      throw FormatException('Invalid concept map manifest: $error');
    }

    final unitByLessonId = <String, Unit>{};
    for (final unit in curriculum.units) {
      for (final lessonId in unit.lessonIds) {
        unitByLessonId[lessonId] = unit;
      }
    }
    for (final definition in manifest.concepts) {
      if (!unitByLessonId.containsKey(definition.lessonId)) {
        throw FormatException(
          'Concept "${definition.id}" references unknown lesson '
          '"${definition.lessonId}".',
        );
      }
    }
    if (manifest.concepts
            .map((concept) => concept.lessonId)
            .toSet()
            .length !=
        manifest.concepts.length) {
      throw const FormatException(
        'A lesson may be linked to only one concept in the manifest.',
      );
    }

    final lessons = await Future.wait(
      manifest.concepts.map(
        (concept) => _loadLesson(curriculum, concept.lessonId),
      ),
    );
    final lessonsById = {for (final lesson in lessons) lesson.id: lesson};
    return ConceptMapContent(
      manifest: manifest,
      lessons: lessonsById,
      units: {
        for (final unit in unitByLessonId.values) unit.id: unit,
      },
    );
  }

  Future<Lesson> _loadLesson(Curriculum curriculum, String lessonId) async {
    final unit = curriculum.units.firstWhere(
      (unit) => unit.lessonIds.contains(lessonId),
    );
    final directory = unit.id.startsWith('unit_')
        ? unit.id.substring('unit_'.length)
        : unit.id;
    final source = await _assetBundle.loadString(
      'assets/curriculum/units/$directory/$lessonId.json',
    );
    final decoded = jsonDecode(source);
    if (decoded is! Map) {
      throw FormatException('Lesson "$lessonId" must be a JSON object.');
    }
    try {
      final lesson = Lesson.fromJson(Map<String, Object?>.from(decoded));
      if (lesson.id != lessonId || lesson.unitId != unit.id) {
        throw FormatException(
          'Lesson "$lessonId" does not match its curriculum entry.',
        );
      }
      return lesson;
    } on TypeError {
      throw FormatException('Lesson "$lessonId" must have string keys.');
    }
  }
}
