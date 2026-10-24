import 'package:flutter/foundation.dart';

import 'model_json.dart';

enum ExperienceTier { absoluteBeginner, transitionDev, godotVeteran }

enum OnboardingStatus { inProgress, completed, skipped }

const onboardingQuestionIds = [
  'strict_typing',
  'physics_process',
  'match_wildcard',
];

@immutable
class OnboardingDraft {
  OnboardingDraft({
    this.currentStep = 1,
    this.selectedTier = ExperienceTier.transitionDev,
    this.currentQuestionIndex = 0,
    List<String> questionIds = onboardingQuestionIds,
    required List<int?> selectedAnswers,
    this.recommendedUnitId,
    this.recommendedLessonId,
    this.status = OnboardingStatus.inProgress,
  }) : questionIds = List.unmodifiable(questionIds),
       selectedAnswers = List.unmodifiable(selectedAnswers) {
    if (currentStep < 0 || currentStep > 3) {
      throw ArgumentError.value(currentStep, 'currentStep');
    }
    if (currentQuestionIndex < 0) {
      throw ArgumentError.value(currentQuestionIndex, 'currentQuestionIndex');
    }
    if (this.selectedAnswers.any(
      (answer) => answer != null && (answer < 0 || answer > 3),
    )) {
      throw ArgumentError.value(selectedAnswers, 'selectedAnswers');
    }
    if (currentQuestionIndex >= this.selectedAnswers.length) {
      throw ArgumentError.value(currentQuestionIndex, 'currentQuestionIndex');
    }
    if (this.questionIds.length != this.selectedAnswers.length ||
        this.questionIds.toSet().length != this.questionIds.length ||
        this.questionIds.any((id) => id.trim().isEmpty)) {
      throw ArgumentError(
        'Question identifiers must be unique and match the answer count.',
      );
    }
    if ((recommendedUnitId == null) != (recommendedLessonId == null)) {
      throw ArgumentError(
        'Recommended unit and lesson must either both be present or both be absent.',
      );
    }
  }

  final int currentStep;
  final ExperienceTier selectedTier;
  final int currentQuestionIndex;
  final List<String> questionIds;
  final List<int?> selectedAnswers;
  final String? recommendedUnitId;
  final String? recommendedLessonId;
  final OnboardingStatus status;

  factory OnboardingDraft.initial() => OnboardingDraft(
    selectedAnswers: List<int?>.filled(onboardingQuestionIds.length, null),
  );

  factory OnboardingDraft.fromJson(JsonObject json) {
    final tierName = requiredString(json, 'selectedTier');
    final tier = ExperienceTier.values.where((value) => value.name == tierName);
    if (tier.isEmpty) {
      throw FormatException('Unsupported experience tier "$tierName".');
    }
    final statusName = requiredString(json, 'status');
    final status = OnboardingStatus.values.where(
      (value) => value.name == statusName,
    );
    if (status.isEmpty) {
      throw FormatException('Unsupported onboarding status "$statusName".');
    }
    final answers = requiredList(json, 'selectedAnswers');
    return OnboardingDraft(
      currentStep: requiredInt(json, 'currentStep', minimum: 0),
      selectedTier: tier.first,
      currentQuestionIndex: requiredInt(
        json,
        'currentQuestionIndex',
        minimum: 0,
      ),
      questionIds: stringList(json, 'questionIds'),
      selectedAnswers: [for (final answer in answers) _parseAnswer(answer)],
      recommendedUnitId: optionalString(json, 'recommendedUnitId'),
      recommendedLessonId: optionalString(json, 'recommendedLessonId'),
      status: status.first,
    );
  }

  JsonObject toJson() => {
    'currentStep': currentStep,
    'selectedTier': selectedTier.name,
    'currentQuestionIndex': currentQuestionIndex,
    'questionIds': questionIds,
    'selectedAnswers': selectedAnswers,
    'recommendedUnitId': recommendedUnitId,
    'recommendedLessonId': recommendedLessonId,
    'status': status.name,
  };

  OnboardingDraft copyWith({
    int? currentStep,
    ExperienceTier? selectedTier,
    int? currentQuestionIndex,
    List<String>? questionIds,
    List<int?>? selectedAnswers,
    String? recommendedUnitId,
    String? recommendedLessonId,
    OnboardingStatus? status,
    bool clearRecommendation = false,
  }) => OnboardingDraft(
    currentStep: currentStep ?? this.currentStep,
    selectedTier: selectedTier ?? this.selectedTier,
    currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
    questionIds: questionIds ?? this.questionIds,
    selectedAnswers: selectedAnswers ?? this.selectedAnswers,
    recommendedUnitId: clearRecommendation
        ? null
        : recommendedUnitId ?? this.recommendedUnitId,
    recommendedLessonId: clearRecommendation
        ? null
        : recommendedLessonId ?? this.recommendedLessonId,
    status: status ?? this.status,
  );
}

int? _parseAnswer(Object? answer) {
  if (answer == null) return null;
  if (answer is int && answer >= 0 && answer <= 3) return answer;
  throw const FormatException(
    'Selected answers must be integers from 0 to 3 or null.',
  );
}
