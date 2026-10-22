import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/curriculum_models.dart';
import '../models/lesson_models.dart';

class CurriculumRepository {
  CurriculumRepository({
    required this._assetBundle,
    this.manifestAsset = 'assets/curriculum/manifest.json',
  });

  final AssetBundle _assetBundle;
  final String manifestAsset;

  Future<Curriculum> loadCurriculum() async {
    final source = await _assetBundle.loadString(manifestAsset);
    final decoded = jsonDecode(source);
    if (decoded is! Map) {
      throw const FormatException('Curriculum manifest must be a JSON object.');
    }
    try {
      return Curriculum.fromJson(Map<String, Object?>.from(decoded));
    } on TypeError {
      throw const FormatException(
        'Curriculum manifest must have string object keys.',
      );
    }
  }

  Future<Lesson> loadLesson(Curriculum curriculum, String lessonId) async {
    for (final unit in curriculum.units) {
      if (!unit.lessonIds.contains(lessonId)) continue;
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
    throw ArgumentError.value(lessonId, 'lessonId', 'Unknown lesson.');
  }
}
