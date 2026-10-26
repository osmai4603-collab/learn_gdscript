import 'package:flutter/material.dart';
import 'package:learn_gdscript/core/theme/editor_theme_extension.dart';
import 'package:learn_gdscript/core/theme/color_schemes.dart';
import 'package:go_router/go_router.dart';
import 'package:learn_gdscript/core/constants/app_constants.dart';
import 'package:provider/provider.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../data/models/curriculum_models.dart';
import '../../../data/models/onboarding_draft.dart';
import '../../../logic/providers/app_settings_provider.dart';
import '../../../logic/providers/curriculum_provider.dart';
import '../../../logic/providers/onboarding_provider.dart';
import '../../../logic/providers/progress_provider.dart';
import '../../routers/app_routes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    )..forward();
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<bool> _saveDraft(OnboardingDraft draft) async {
    if (_busy) return false;
    setState(() => _busy = true);
    try {
      await context.read<OnboardingProvider>().save(draft);
      return true;
    } on Object {
      if (!mounted) return false;
      _showError(context.l10n.onboardingSaveError);
      return false;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _goToStep(int step) async {
    if (_busy || step < 0 || step > 3) return;
    final draft = context.read<OnboardingProvider>().draft!;
    _fadeController.reset();
    final saved = await _saveDraft(draft.copyWith(currentStep: step));
    if (!mounted) return;
    if (!saved ||
        context.read<OnboardingProvider>().draft?.currentStep != step) {
      _fadeController.forward();
      return;
    }
    _fadeController.forward();
  }

  Future<void> _selectTier(ExperienceTier tier) async {
    final draft = context.read<OnboardingProvider>().draft!;
    await _saveDraft(
      draft.copyWith(selectedTier: tier, clearRecommendation: true),
    );
  }

  Future<void> _selectAnswer(int optionIndex) async {
    final draft = context.read<OnboardingProvider>().draft!;
    final answers = List<int?>.from(draft.selectedAnswers);
    if (draft.currentQuestionIndex >= answers.length) return;
    answers[draft.currentQuestionIndex] = optionIndex;
    await _saveDraft(draft.copyWith(selectedAnswers: answers));
  }

  Future<void> _nextQuestion() async {
    final draft = context.read<OnboardingProvider>().draft!;
    if (draft.currentQuestionIndex >= _questions(context).length ||
        draft.currentQuestionIndex >= draft.selectedAnswers.length ||
        draft.selectedAnswers[draft.currentQuestionIndex] == null) {
      return;
    }
    if (draft.currentQuestionIndex < _questions(context).length - 1) {
      await _saveDraft(
        draft.copyWith(currentQuestionIndex: draft.currentQuestionIndex + 1),
      );
      return;
    }
    final unit = _recommendedUnit(context, draft);
    final next = draft.copyWith(
      currentStep: 3,
      recommendedUnitId: unit?.id,
      recommendedLessonId: unit == null ? null : unit.lessonIds.first,
      clearRecommendation: unit == null,
    );
    final saved = await _saveDraft(next);
    if (saved &&
        mounted &&
        context.read<OnboardingProvider>().draft?.currentStep == 3) {
      _fadeController.reset();
      _fadeController.forward();
    }
  }

  Future<void> _previousQuestion() async {
    final draft = context.read<OnboardingProvider>().draft!;
    if (draft.currentQuestionIndex == 0) return;
    await _saveDraft(
      draft.copyWith(currentQuestionIndex: draft.currentQuestionIndex - 1),
    );
  }

  Future<void> _finish({bool skipped = false}) async {
    if (_busy) return;
    final onboarding = context.read<OnboardingProvider>();
    final settings = context.read<AppSettingsProvider>();
    final progress = context.read<ProgressProvider>();
    final draft = onboarding.draft!;
    final unit = skipped
        ? null
        : _unitForDraft(context, draft) ?? _recommendedUnit(context, draft);
    final savedLessonId = draft.recommendedLessonId;
    final lessonId = unit == null
        ? null
        : unit.lessonIds.contains(savedLessonId)
        ? savedLessonId
        : unit.lessonIds.first;

    setState(() => _busy = true);
    try {
      if (unit != null && lessonId != null) {
        if (progress.progress == null) {
          await progress.initialize(
            visitorId: AppConstants.visitorId,
            unitId: unit.id,
            lessonId: lessonId,
          );
        } else {
          await progress.setStartingPoint(unitId: unit.id, lessonId: lessonId);
        }
      }
      await onboarding.save(
        draft.copyWith(
          currentStep: 3,
          recommendedUnitId: unit?.id,
          recommendedLessonId: lessonId,
          status: skipped
              ? OnboardingStatus.skipped
              : OnboardingStatus.completed,
          clearRecommendation: skipped || unit == null,
        ),
      );
      if (!mounted) return;
      await settings.completeOnboarding();
      if (!mounted) return;
      context.go(AppRoutes.root);
    } on Object {
      if (mounted) _showError(context.l10n.onboardingSaveError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final onboarding = context.watch<OnboardingProvider>();
    final draft = onboarding.draft;
    if (draft == null) {
      final l10n = context.l10n;
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
        body: Center(
          child: onboarding.loadError != null
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.onboardingRestoreError,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: onboarding.isLoading
                          ? null
                          : () => onboarding.load(AppConstants.visitorId),
                      child: Text(l10n.retry),
                    ),
                  ],
                )
              : CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      body: Column(
        children: [
          _OnboardingTopBar(busy: _busy, onSkip: () => _finish(skipped: true)),
          Divider(
            height: 1,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 24,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 820),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _OnboardingStepper(activeStep: draft.currentStep),
                        const SizedBox(height: 36),
                        if (draft.currentStep == 0)
                          _WelcomeStepView(
                            busy: _busy,
                            onStart: () => _goToStep(1),
                          )
                        else if (draft.currentStep == 1)
                          _ExperienceTierStepView(
                            selectedTier: draft.selectedTier,
                            busy: _busy,
                            onSelectTier: _selectTier,
                            onContinue: () => _goToStep(2),
                          )
                        else if (draft.currentStep == 2)
                          _DiagnosticQuizStepView(
                            questions: _questions(context),
                            questionIndex: draft.currentQuestionIndex,
                            answers: draft.selectedAnswers,
                            busy: _busy,
                            onSelectOption: _selectAnswer,
                            onNextQuestion: _nextQuestion,
                            onPrevQuestion: _previousQuestion,
                          )
                        else
                          _RoadmapRecommendationStepView(
                            draft: draft,
                            unit: _unitForDraft(context, draft),
                            onStartLearning: () => _finish(),
                            busy: _busy,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiagnosticQuestion {
  const _DiagnosticQuestion({
    required this.id,
    required this.question,
    required this.code,
    required this.options,
    required this.correctOptionIndex,
  });

  final String id;
  final String question;
  final String code;
  final List<String> options;
  final int correctOptionIndex;
}

List<_DiagnosticQuestion> _questions(BuildContext context) {
  final l10n = context.l10n;
  return [
    _DiagnosticQuestion(
      id: 'strict_typing',
      question: l10n.onboardingQuestionTyping,
      code: l10n.onboardingCodeTyping,
      options: [
        l10n.onboardingOptionTyping0,
        l10n.onboardingOptionTyping1,
        l10n.onboardingOptionTyping2,
        l10n.onboardingOptionTyping3,
      ],
      correctOptionIndex: 1,
    ),
    _DiagnosticQuestion(
      id: 'physics_process',
      question: l10n.onboardingQuestionPhysics,
      code: l10n.onboardingCodePhysics,
      options: [
        l10n.onboardingOptionPhysics0,
        l10n.onboardingOptionPhysics1,
        l10n.onboardingOptionPhysics2,
        l10n.onboardingOptionPhysics3,
      ],
      correctOptionIndex: 1,
    ),
    _DiagnosticQuestion(
      id: 'match_wildcard',
      question: l10n.onboardingQuestionMatch,
      code: l10n.onboardingCodeMatch,
      options: [
        l10n.onboardingOptionMatch0,
        l10n.onboardingOptionMatch1,
        l10n.onboardingOptionMatch2,
        l10n.onboardingOptionMatch3,
      ],
      correctOptionIndex: 1,
    ),
  ];
}

Unit? _recommendedUnit(BuildContext context, OnboardingDraft draft) {
  final curriculum = context.read<CurriculumProvider>().state.value;
  final units = curriculum?.units
      .where((unit) => unit.lessonIds.isNotEmpty)
      .toList();
  if (units == null || units.isEmpty) return null;
  units.sort((left, right) => left.order.compareTo(right.order));
  final questions = _questions(context);
  final score = [
    for (var index = 0; index < draft.selectedAnswers.length; index++)
      if (index < questions.length &&
          draft.questionIds[index] == questions[index].id &&
          draft.selectedAnswers[index] == questions[index].correctOptionIndex)
        index,
  ].length;
  final preferredIndex = switch (draft.selectedTier) {
    ExperienceTier.absoluteBeginner => 0,
    ExperienceTier.transitionDev => score >= 2 ? 2 : 1,
    ExperienceTier.godotVeteran => score >= 2 ? 3 : 2,
  };
  return units[preferredIndex.clamp(0, units.length - 1).toInt()];
}

Unit? _unitForDraft(BuildContext context, OnboardingDraft draft) {
  final units = context.read<CurriculumProvider>().state.value?.units;
  final savedId = draft.recommendedUnitId;
  if (savedId != null && units != null) {
    for (final unit in units) {
      if (unit.id == savedId && unit.lessonIds.isNotEmpty) return unit;
    }
  }
  return _recommendedUnit(context, draft);
}

class _OnboardingTopBar extends StatelessWidget {
  const _OnboardingTopBar({required this.busy, required this.onSkip});

  final bool busy;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Row(
        children: [
          Icon(
            Icons.gamepad_rounded,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            l10n.onboardingBrand,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontFamily: 'IBM Plex Sans Arabic',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          if (MediaQuery.sizeOf(context).width >= 720) ...[
            const SizedBox(width: 8),
            Text(
              '/',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.onboardingPlacementLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ] else
            const Spacer(),
          TextButton(
            onPressed: busy ? null : onSkip,
            child: Text(
              l10n.onboardingSkip,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontFamily: 'IBM Plex Sans Arabic',
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingStepper extends StatelessWidget {
  const _OnboardingStepper({required this.activeStep});

  final int activeStep;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final steps = [
      l10n.onboardingStepWelcome,
      l10n.onboardingStepExperience,
      l10n.onboardingStepAssessment,
      l10n.onboardingStepRoadmap,
    ];

    return Row(
      children: List.generate(steps.length, (index) {
        final isCompleted = index < activeStep;
        final isCurrent = index == activeStep;
        final circleColor = isCompleted
            ? Theme.of(context).colorScheme.successContainer
            : isCurrent
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.surfaceContainerLow;
        final borderColor = isCompleted
            ? Theme.of(context).colorScheme.tertiary
            : isCurrent
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.outlineVariant;
        final textColor = isCompleted
            ? Theme.of(context).colorScheme.tertiary
            : isCurrent
            ? Theme.of(context).colorScheme.onSurface
            : Theme.of(context).colorScheme.onSurfaceVariant;

        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: circleColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: borderColor),
                      ),
                      child: Center(
                        child: isCompleted
                            ? Icon(
                                Icons.check_rounded,
                                size: 16,
                                color: Theme.of(context).colorScheme.tertiary,
                              )
                            : Text(
                                '${index + 1}',
                                style: CodeTextTheme.of(context).bodyMedium.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isCurrent
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        steps[index],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontSize: 12,
                          fontWeight: isCurrent
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (index < steps.length - 1)
                Container(
                  width: 32,
                  height: 2,
                  color: isCompleted
                      ? Theme.of(context).colorScheme.tertiary
                      : Theme.of(context).colorScheme.outlineVariant,
                ),
            ],
          ),
        );
      }),
    );
  }
}

class _WelcomeStepView extends StatelessWidget {
  const _WelcomeStepView({required this.busy, required this.onStart});

  final bool busy;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: Theme.of(context).colorScheme.primary),
            ),
            child: Icon(
              Icons.rocket_launch_rounded,
              size: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.onboardingWelcomeHeading,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontFamily: 'IBM Plex Sans Arabic',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.onboardingWelcomeBody,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontFamily: 'IBM Plex Sans Arabic',
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: busy ? null : onStart,
            icon: Icon(
              Icons.arrow_back_rounded,
              size: 18,
              textDirection: Directionality.of(context) == .ltr ? .rtl : .ltr,
            ),
            iconAlignment: .end,
            label: Text(
              l10n.onboardingWelcomeAction,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontFamily: 'IBM Plex Sans Arabic',
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExperienceTierStepView extends StatelessWidget {
  const _ExperienceTierStepView({
    required this.selectedTier,
    required this.busy,
    required this.onSelectTier,
    required this.onContinue,
  });

  final ExperienceTier selectedTier;
  final bool busy;
  final ValueChanged<ExperienceTier> onSelectTier;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tiers = [
      (
        tier: ExperienceTier.absoluteBeginner,
        title: l10n.onboardingTierBeginner,
        description: l10n.onboardingTierBeginnerDescription,
        icon: Icons.school_rounded,
      ),
      (
        tier: ExperienceTier.transitionDev,
        title: l10n.onboardingTierTransition,
        description: l10n.onboardingTierTransitionDescription,
        icon: Icons.swap_horiz_rounded,
      ),
      (
        tier: ExperienceTier.godotVeteran,
        title: l10n.onboardingTierVeteran,
        description: l10n.onboardingTierVeteranDescription,
        icon: Icons.auto_awesome_rounded,
      ),
    ];

    return Column(
      children: [
        Text(
          l10n.onboardingExperiencePrompt,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            fontFamily: 'IBM Plex Sans Arabic',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.onboardingExperienceDescription,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            fontFamily: 'IBM Plex Sans Arabic',
            fontSize: 13,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        ...tiers.map((item) {
          final isSelected = item.tier == selectedTier;
          return InkWell(
            onTap: busy ? null : () => onSelectTier(item.tier),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.surfaceContainerHigh
                    : Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outlineVariant,
                  width: isSelected ? 1.6 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.2)
                          : Theme.of(context).colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      item.icon,
                      size: 24,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontFamily: 'IBM Plex Sans Arabic',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Theme.of(context).colorScheme.onSurface
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.description,
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontFamily: 'IBM Plex Sans Arabic',
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: busy ? null : onContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              l10n.onboardingContinueAssessment,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontFamily: 'IBM Plex Sans Arabic',
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DiagnosticQuizStepView extends StatelessWidget {
  const _DiagnosticQuizStepView({
    required this.questions,
    required this.questionIndex,
    required this.answers,
    required this.busy,
    required this.onSelectOption,
    required this.onNextQuestion,
    required this.onPrevQuestion,
  });

  final List<_DiagnosticQuestion> questions;
  final int questionIndex;
  final List<int?> answers;
  final bool busy;
  final ValueChanged<int> onSelectOption;
  final VoidCallback onNextQuestion;
  final VoidCallback onPrevQuestion;

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty ||
        questionIndex < 0 ||
        questionIndex >= questions.length ||
        questionIndex >= answers.length) {
      return const SizedBox.shrink();
    }
    final l10n = context.l10n;
    final question = questions[questionIndex];
    final selectedOption = answers[questionIndex];
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.onboardingQuestionProgress(
                  questionIndex + 1,
                  questions.length,
                ),
                style: CodeTextTheme.of(context).bodyMedium.copyWith(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  l10n.onboardingAssessmentTag,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            question.question,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontFamily: 'IBM Plex Sans Arabic',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                question.code,
                style: CodeTextTheme.of(context).bodyMedium.copyWith(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.primary,
                  height: 1.4,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ...List.generate(question.options.length, (optionIndex) {
            final isChosen = selectedOption == optionIndex;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: busy ? null : () => onSelectOption(optionIndex),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isChosen
                        ? Theme.of(context).colorScheme.surfaceContainerHigh
                        : Theme.of(context).colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isChosen
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: isChosen
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isChosen
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        child: isChosen
                            ? Icon(
                                Icons.check,
                                size: 14,
                                color: Theme.of(context).colorScheme.onPrimary,
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            question.options[optionIndex],
                            style: CodeTextTheme.of(context).bodyMedium.copyWith(
                              fontSize: 12,
                              color: isChosen
                                  ? Theme.of(context).colorScheme.onSurface
                                  : Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (questionIndex > 0)
                OutlinedButton(
                  onPressed: busy ? null : onPrevQuestion,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant,
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: Text(
                    l10n.onboardingPrevious,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontFamily: 'IBM Plex Sans Arabic'),
                  ),
                )
              else
                const SizedBox.shrink(),
              ElevatedButton(
                onPressed: !busy && selectedOption != null
                    ? onNextQuestion
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text(
                  questionIndex == questions.length - 1
                      ? l10n.onboardingFinishAssessment
                      : l10n.onboardingNextQuestion,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoadmapRecommendationStepView extends StatelessWidget {
  const _RoadmapRecommendationStepView({
    required this.draft,
    required this.unit,
    required this.onStartLearning,
    required this.busy,
  });

  final OnboardingDraft draft;
  final Unit? unit;
  final VoidCallback onStartLearning;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final title =
        unit?.title.resolve(Localizations.localeOf(context)) ?? l10n.noLessons;
    final unitLabel = unit == null
        ? l10n.noLessons
        : l10n.onboardingUnitLabel(unit!.order.toString().padLeft(2, '0'));
    final summary = switch (draft.selectedTier) {
      ExperienceTier.absoluteBeginner => l10n.onboardingSummaryBeginner,
      ExperienceTier.transitionDev => l10n.onboardingSummaryTransition,
      ExperienceTier.godotVeteran => l10n.onboardingSummaryVeteran,
    };

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.successContainer.withValues(alpha: 0.3),
              shape: BoxShape.circle,
              border: Border.all(color: Theme.of(context).colorScheme.tertiary),
            ),
            child: Icon(
              Icons.verified_rounded,
              size: 40,
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            l10n.onboardingRoadmapSuccess,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontFamily: 'IBM Plex Sans Arabic',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            summary,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontFamily: 'IBM Plex Sans Arabic',
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.play_circle_filled_rounded,
                  size: 28,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.onboardingRecommendedStart(unitLabel),
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        title,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: busy ? null : onStartLearning,
              icon: Icon(
                Icons.arrow_back_rounded,
                size: 18,
                textDirection: Directionality.of(context) == .ltr ? .rtl : .ltr,
              ),
              iconAlignment: .end,
              label: Text(
                l10n.onboardingStartLearning,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.tertiary,
                foregroundColor: Theme.of(context).colorScheme.onTertiary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
