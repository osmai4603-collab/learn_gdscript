import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/curriculum_models.dart';
import '../models/lesson_models.dart';

/// Base class for all curriculum repository exceptions.
sealed class CurriculumException implements Exception {
  final String message;
  final Object? cause;

  const CurriculumException(this.message, [this.cause]);

  @override
  String toString() =>
      'CurriculumException: $message${cause != null ? ' (Cause: $cause)' : ''}';
}

/// Thrown when the curriculum manifest asset cannot be found or loaded.
class ManifestNotFoundException extends CurriculumException {
  final String assetPath;

  const ManifestNotFoundException(this.assetPath, [Object? cause])
      : super('Curriculum manifest asset not found at "$assetPath".', cause);
}

/// Thrown when the curriculum manifest JSON is malformed or invalid.
class ManifestParseException extends CurriculumException implements FormatException {
  const ManifestParseException(String details, [Object? cause])
      : super('Failed to parse curriculum manifest: $details', cause);

  @override
  String get source => cause?.toString() ?? '';

  @override
  int? get offset => null;
}

/// Thrown when a requested lesson asset cannot be found.
class LessonNotFoundException extends CurriculumException {
  final String lessonId;
  final String? unitId;

  const LessonNotFoundException(this.lessonId, [this.unitId, Object? cause])
      : super(
          'Lesson "$lessonId"${unitId != null ? ' in unit "$unitId"' : ''} was not found.',
          cause,
        );
}

/// Thrown when a lesson JSON file is malformed, invalid, or missing required fields.
class LessonParseException extends CurriculumException implements FormatException {
  final String lessonId;

  const LessonParseException(this.lessonId, String details, [Object? cause])
      : super('Failed to parse lesson "$lessonId": $details', cause);

  @override
  String get source => cause?.toString() ?? '';

  @override
  int? get offset => null;
}

class CurriculumRepository {
  CurriculumRepository({
    required this._assetBundle,
    this.manifestAsset = 'assets/curriculum/manifest.json',
  });

  final AssetBundle _assetBundle;
  final String manifestAsset;

  Future<Curriculum> loadCurriculum() async {
    final String source;
    try {
      source = await _assetBundle.loadString(manifestAsset);
    } catch (e) {
      if (e is CurriculumException) rethrow;
      throw ManifestNotFoundException(manifestAsset, e);
    }

    if (source.trim().isEmpty) {
      throw const ManifestParseException('Manifest JSON file is empty.');
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(source);
    } catch (e) {
      throw ManifestParseException('Invalid JSON string syntax.', e);
    }

    if (decoded is! Map) {
      throw const ManifestParseException('Curriculum manifest must be a JSON object.');
    }

    try {
      return Curriculum.fromJson(Map<String, Object?>.from(decoded));
    } catch (e) {
      throw ManifestParseException(
        'Curriculum manifest format does not match expected schema.',
        e,
      );
    }
  }

  Future<Lesson> loadLesson(Curriculum curriculum, String lessonId) async {
    Unit? targetUnit;
    for (final unit in curriculum.units) {
      if (unit.lessonIds.contains(lessonId)) {
        targetUnit = unit;
        break;
      }
    }

    if (targetUnit == null) {
      throw LessonNotFoundException(lessonId);
    }

    final directory = targetUnit.id.startsWith('unit_')
        ? targetUnit.id.substring('unit_'.length)
        : targetUnit.id;
    final assetPath = 'assets/curriculum/units/$directory/$lessonId.json';

    final String source;
    try {
      source = await _assetBundle.loadString(assetPath);
    } catch (e) {
      if (e is CurriculumException) rethrow;
      throw LessonNotFoundException(lessonId, targetUnit.id, e);
    }

    if (source.trim().isEmpty) {
      throw LessonParseException(lessonId, 'Lesson JSON file is empty.');
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(source);
    } catch (e) {
      throw LessonParseException(lessonId, 'Invalid JSON string syntax.', e);
    }

    if (decoded is! Map) {
      throw LessonParseException(
        lessonId,
        'Lesson "$lessonId" must be a JSON object.',
      );
    }

    try {
      final lesson = Lesson.fromJson(Map<String, Object?>.from(decoded));
      if (lesson.id != lessonId || lesson.unitId != targetUnit.id) {
        throw LessonParseException(
          lessonId,
          'Lesson "$lessonId" does not match its curriculum entry (ID or Unit ID mismatch).',
        );
      }
      return lesson;
    } catch (e) {
      if (e is LessonParseException) rethrow;
      throw LessonParseException(
        lessonId,
        'Lesson format does not match expected schema.',
        e,
      );
    }
  }
}
