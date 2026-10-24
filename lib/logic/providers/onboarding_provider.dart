import 'package:flutter/foundation.dart';

import '../../data/models/onboarding_draft.dart';
import '../../data/repositories/onboarding_repository.dart';

class OnboardingProvider extends ChangeNotifier {
  OnboardingProvider(this._repository);

  final OnboardingRepository _repository;
  OnboardingDraft? _draft;
  String? _visitorId;
  Future<void> _saveQueue = Future<void>.value();
  Object? _loadError;
  bool _isLoading = false;

  OnboardingDraft? get draft => _draft;
  Object? get loadError => _loadError;
  bool get isLoading => _isLoading;

  Future<void> load(String visitorId) async {
    _visitorId = visitorId;
    _isLoading = true;
    _loadError = null;
    notifyListeners();
    try {
      final saved = await _repository.load(visitorId);
      var draft = saved ?? OnboardingDraft.initial();
      final validQuestionIndex = saved == null
          ? 0
          : saved.currentQuestionIndex
              .clamp(0, onboardingQuestionIds.length - 1)
              .toInt();
      if (saved != null &&
          (!listEquals(saved.questionIds, onboardingQuestionIds) ||
              saved.currentQuestionIndex != validQuestionIndex)) {
        final answersByQuestion = {
          for (var index = 0; index < saved.questionIds.length; index++)
            saved.questionIds[index]: saved.selectedAnswers[index],
        };
        final answers = [
          for (final id in onboardingQuestionIds) answersByQuestion[id],
        ];
        draft = saved.copyWith(
          questionIds: onboardingQuestionIds,
          selectedAnswers: answers,
          currentQuestionIndex: validQuestionIndex,
          clearRecommendation: true,
        );
        await _repository.save(visitorId, draft);
      }
      if (saved == null) await _repository.save(visitorId, draft);
      _draft = draft;
    } on Object catch (error) {
      _loadError = error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> save(OnboardingDraft draft) async {
    final visitorId = _visitorId;
    if (visitorId == null) {
      throw StateError('Onboarding state has not been loaded.');
    }
    _loadError = null;
    final write = _saveQueue.then((_) async {
      await _repository.save(visitorId, draft);
      _draft = draft;
      notifyListeners();
    });
    _saveQueue = write.catchError((Object _) {});
    await write;
  }
}
