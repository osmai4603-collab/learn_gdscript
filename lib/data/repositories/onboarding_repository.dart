import 'dart:convert';

import '../models/onboarding_draft.dart';
import '../sqlite/database_helper.dart';

class OnboardingRepository {
  OnboardingRepository(this._databaseHelper);

  final DatabaseHelper _databaseHelper;

  Future<OnboardingDraft?> load(String visitorId) async {
    final database = await _databaseHelper.database;
    final rows = database.select(
      'SELECT current_step, selected_tier, current_question_index, '
      'question_ids, selected_answers, recommended_unit_id, '
      'recommended_lesson_id, status '
      'FROM onboarding_state WHERE visitor_id = ?',
      [visitorId],
    );
    if (rows.isEmpty) return null;
    final row = rows.single;
    final answers = jsonDecode(row['selected_answers'] as String);
    if (answers is! List<Object?>) {
      throw const FormatException('Stored onboarding answers must be a list.');
    }
    return OnboardingDraft.fromJson({
      'currentStep': row['current_step'],
      'selectedTier': row['selected_tier'],
      'currentQuestionIndex': row['current_question_index'],
      'questionIds': jsonDecode(row['question_ids'] as String),
      'selectedAnswers': answers,
      'recommendedUnitId': row['recommended_unit_id'],
      'recommendedLessonId': row['recommended_lesson_id'],
      'status': row['status'],
    });
  }

  Future<void> save(String visitorId, OnboardingDraft draft) async {
    final database = await _databaseHelper.database;
    database.execute(
      '''
      INSERT INTO onboarding_state (
        visitor_id, current_step, selected_tier, current_question_index,
        question_ids, selected_answers, recommended_unit_id,
        recommended_lesson_id, status, updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ON CONFLICT(visitor_id) DO UPDATE SET
        current_step = excluded.current_step,
        selected_tier = excluded.selected_tier,
        current_question_index = excluded.current_question_index,
        question_ids = excluded.question_ids,
        selected_answers = excluded.selected_answers,
        recommended_unit_id = excluded.recommended_unit_id,
        recommended_lesson_id = excluded.recommended_lesson_id,
        status = excluded.status,
        updated_at = excluded.updated_at
      ''',
      [
        visitorId,
        draft.currentStep,
        draft.selectedTier.name,
        draft.currentQuestionIndex,
        jsonEncode(draft.questionIds),
        jsonEncode(draft.selectedAnswers),
        draft.recommendedUnitId,
        draft.recommendedLessonId,
        draft.status.name,
        DateTime.now().toUtc().toIso8601String(),
      ],
    );
  }
}
