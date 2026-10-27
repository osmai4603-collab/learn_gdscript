// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'تعلّم GDScript';

  @override
  String get homeTitle => 'الرئيسية';

  @override
  String get homeWelcome => 'تعلّم GDScript خطوة بخطوة';

  @override
  String dashboardDays(int days) {
    return '$days أيام';
  }

  @override
  String dashboardWelcomeBack(String name) {
    return 'مرحباً بعودتك، $name 👋';
  }

  @override
  String get dashboardWelcomeMessage => 'خطوة واحدة تفصلك عن إتقان منطق تفرع اللعبة. لنواصل كتابة الأكواد والتحكم بسلوك العقد اليوم!';

  @override
  String get dashboardCurrentUnit => 'الوحدة الحالية:';

  @override
  String dashboardPercentComplete(int percent) {
    return '$percent% مكتمل';
  }

  @override
  String get dashboardNextLevel => 'التقدم للمستوى التالي';

  @override
  String dashboardLessonsCompleted(int completed, int total) {
    return '$completed من $total درساً';
  }

  @override
  String dashboardXpToNextLevel(int xp) {
    return '$xp XP للمستوى التالي';
  }

  @override
  String get dashboardContinueDescription => 'تابع من حيث توقفت، وسيتم حفظ تقدمك تلقائياً.';

  @override
  String get dashboardContinueAction => 'تابع التعلم الآن';

  @override
  String get dashboardDraftAutoSaved => 'حفظ تلقائي لآخر مسودة كود';

  @override
  String get dashboardCurriculumTitle => 'خريطة المنهج البرمجي';

  @override
  String get dashboardCurriculumDescription => 'تابع تقدمك من أول برنامج إلى بناء منطق الألعاب باستخدام GDScript.';

  @override
  String get dashboardViewFullPath => 'عرض شجرة المسار الكاملة';

  @override
  String get dashboardRecentBadges => 'أحدث الأوسمة المكتسبة';

  @override
  String dashboardBadgeCount(int earned, int total) {
    return '$earned من $total';
  }

  @override
  String get dashboardNoBadges => 'لا توجد أوسمة بعد';

  @override
  String get dashboardEarnBadges => 'أكمل الدروس لاكتساب الأوسمة';

  @override
  String get dashboardStreak => 'سلسلة الالتزام (Streak)';

  @override
  String dashboardConsecutiveDays(int days) {
    return '$days أيام متتالية 🔥';
  }

  @override
  String get dashboardEngineTitle => 'محرك GDScript';

  @override
  String get dashboardEngineConnecting => 'جارٍ الاتصال';

  @override
  String get dashboardEngineConnected => 'متصل';

  @override
  String get dashboardEngineDisconnected => 'غير متصل';

  @override
  String get dashboardWorkspace => 'مساحة العمل';

  @override
  String get dashboardRuntime => 'بيئة تشغيل GDScript';

  @override
  String get dashboardLocal => 'محلي';

  @override
  String get dashboardPlaygroundReset => 'إعادة تعيين الكود';

  @override
  String get dashboardPlaygroundRun => 'تشغيل الكود (F5)';

  @override
  String get dashboardPlaygroundRunning => 'جارٍ التنفيذ';

  @override
  String get dashboardPlaygroundOutputTitle => 'مخرجات وحدة التحكم (Godot Output Console)';

  @override
  String get dashboardPlaygroundOutputRunning => 'جارٍ تنفيذ الشيفرة...';

  @override
  String get dashboardPlaygroundOutputEmpty => 'اضغط على تشغيل الكود لعرض النتيجة هنا.';

  @override
  String get dashboardPlaygroundOutputSuccess => 'تم التنفيذ بنجاح دون مخرجات.';

  @override
  String dashboardSaveError(String error) {
    return 'تعذر حفظ المسودة: $error';
  }

  @override
  String dashboardExecutionError(String error) {
    return 'تعذر تنفيذ الشيفرة: $error';
  }

  @override
  String get dashboardExecutionFailed => 'تعذر تنفيذ الشيفرة.';

  @override
  String get dashboardExampleTag => 'عرض تجريبي';

  @override
  String get learningPathTitle => 'مسار التعلّم';

  @override
  String get learningPathEmpty => 'ستُضاف المواد التعليمية في مرحلة لاحقة.';

  @override
  String get learningPathHeading => 'مسار التعلّم وخريطة المفاهيم البرمجية';

  @override
  String get conceptMapAction => 'خريطة المفاهيم';

  @override
  String get smartReviewAction => 'مراجعة ذكية';

  @override
  String curriculumVersion(String version) {
    return 'منهج GDScript إصدار $version';
  }

  @override
  String completedUnitsSummary(int completed, int total) {
    return 'أكملت $completed من $total وحدات';
  }

  @override
  String completedLessonsSummary(int completed, int total) {
    return 'أكملت $completed من $total دروس';
  }

  @override
  String get milestoneCompleted => 'مكتمل';

  @override
  String get milestoneCurrent => 'المرحلة الحالية';

  @override
  String get milestoneUpcoming => 'قادم';

  @override
  String completedModulesCount(int count) {
    return '$count مكتملة';
  }

  @override
  String upcomingModulesCount(int count) {
    return '$count متبقية';
  }

  @override
  String moduleNumber(int number) {
    return 'الوحدة $number';
  }

  @override
  String moduleLessonCount(int count) {
    return '$count دروس';
  }

  @override
  String moduleDurationHours(int hours) {
    return 'مجموع $hours دقيقة';
  }

  @override
  String get lessonStatusCurrent => 'الدرس الحالي';

  @override
  String get lessonStatusCompleted => 'مكتمل';

  @override
  String get lessonStatusAvailable => 'متاح';

  @override
  String get lessonStatusLocked => 'مقفل';

  @override
  String get moduleDetails => 'تفاصيل الوحدة';

  @override
  String get showLessons => 'عرض الدروس';

  @override
  String get hideLessons => 'إخفاء الدروس';

  @override
  String get masteryStatistics => 'تقدم التعلّم والإحصاءات';

  @override
  String get progressByUnit => 'التقدم حسب الوحدة';

  @override
  String get achievementsTitle => 'إنجازاتك';

  @override
  String earnedBadgesSummary(int count) {
    return 'اكتسبت $count شارات';
  }

  @override
  String get reviewNextStep => 'درسك التالي';

  @override
  String get openReview => 'فتح المراجعة';

  @override
  String get reviewTitle => 'المراجعة';

  @override
  String get workspaceStatus => 'مساحة العمل';

  @override
  String get workspaceReady => 'جاهزة لتطبيق الدروس';

  @override
  String get openWorkspace => 'فتح مساحة العمل';

  @override
  String get xpTotalLabel => 'إجمالي XP';

  @override
  String get streakLabel => 'سلسلة التعلّم';

  @override
  String get capstoneTitle => 'مشروع الإتقان النهائي';

  @override
  String get capstoneDescription => 'طبّق مهارات GDScript التي اكتسبتها في مشروع متكامل.';

  @override
  String get workspaceTitle => 'مساحة العمل';

  @override
  String get workspaceDescription => 'اختر مجلد مشروع محليًا لفحص ملفات GDScript وتحريرها.';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsReload => 'إعادة تحميل الإعدادات';

  @override
  String get settingsLoadError => 'تعذّر تحميل الإعدادات. حاول مرة أخرى.';

  @override
  String get settingsResetProgressError => 'تعذّر إعادة ضبط التقدم.';

  @override
  String get settingsCategories => 'أقسام الإعدادات';

  @override
  String get settingsEditorCategory => 'المحرر';

  @override
  String get settingsAppearanceCategory => 'المظهر واللغة';

  @override
  String get settingsEngineCategory => 'المحرك';

  @override
  String get settingsAboutCategory => 'حول التطبيق والتقدم';

  @override
  String get settingsEditorDescription => 'تخصيص تفضيلات محرر GDScript.';

  @override
  String get settingsAppearanceDescription => 'اختيار لغة العرض ونسق الألوان وسلوك المظهر.';

  @override
  String get settingsEngineDescription => 'تشخيصات محرك GDScript وأدوات التطوير.';

  @override
  String get settingsAboutDescription => 'معلومات التطبيق وإدارة تقدم التعلّم.';

  @override
  String get settingsEditorFontDescription => 'يُطبّق حجم الخط المحدد على محرر الأكواد.';

  @override
  String get settingsLanguageDescription => 'تُحدّث لغة الواجهة فور اختيارها.';

  @override
  String get settingsThemeModeDescription => 'يمكنك اتباع تفضيل النظام أو اختيار مظهر ثابت.';

  @override
  String get settingsThemeVariantDescription => 'اختر أحد قوالب الألوان المضمّنة في التطبيق.';

  @override
  String get settingsStreakDescription => 'عرض سلسلة التعلّم في واجهات التطبيق.';

  @override
  String get onboardingTitle => 'مرحبًا';

  @override
  String get onboardingDescription => 'اختر مسارًا للتعلّم وتقدّم بالسرعة التي تناسبك.';

  @override
  String get lessonTitle => 'الدرس';

  @override
  String get lessonMissing => 'تعذّر العثور على الدرس المطلوب.';

  @override
  String get notFoundTitle => 'الصفحة غير موجودة';

  @override
  String get backHome => 'العودة إلى الرئيسية';

  @override
  String get languageLabel => 'اللغة';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'الإنجليزية';

  @override
  String get themeLabel => 'المظهر';

  @override
  String get themeVariantLabel => 'نسق الألوان';

  @override
  String get themeAcademy => 'أكاديمية مطوري Godot';

  @override
  String get themeArabicIde => 'بيئة Godot العربية';

  @override
  String get themeSystem => 'اتباع النظام';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get saveSettingsError => 'تعذّر حفظ الإعدادات. أُعيد الاختيار السابق.';

  @override
  String get navigateHome => 'الرئيسية';

  @override
  String get navigatePath => 'مسار التعلّم';

  @override
  String get navigateCodeEditor => 'محرر الأكواد';

  @override
  String get navigateWorkspace => 'مساحة العمل';

  @override
  String get navigateSettings => 'الإعدادات';

  @override
  String get navigateOnboarding => 'مرحبًا';

  @override
  String get onboardingQuestion => 'هل سبق لك البرمجة؟';

  @override
  String get onboardingNewbie => 'أنا جديد تماماً';

  @override
  String get onboardingExperienced => 'أعرف أساسيات البرمجة';

  @override
  String get continueLearning => 'تابع التعلّم';

  @override
  String get quickTry => 'جرّب الآن';

  @override
  String get runCode => 'شغّل';

  @override
  String get resetCode => 'إعادة';

  @override
  String get showHint => 'تلميح';

  @override
  String get showSolution => 'عرض الحل';

  @override
  String get nextLesson => 'الدرس التالي';

  @override
  String get previousLesson => 'الدرس السابق';

  @override
  String get exercisePrompt => 'التمرين';

  @override
  String get outputLabel => 'الناتج';

  @override
  String get outputEmpty => 'اضغط شغّل لرؤية الناتج';

  @override
  String get outputRunning => 'جارٍ التشغيل...';

  @override
  String get testResults => 'نتائج الاختبار';

  @override
  String get testPassed => 'ناجح';

  @override
  String get testFailed => 'فشل';

  @override
  String get lessonComplete => 'أحسنت!';

  @override
  String completedLesson(Object name) {
    return 'أكملت درس «$name»';
  }

  @override
  String exercisesSolved(Object count) {
    return '$count تمارين محلولة';
  }

  @override
  String hintsUsed(Object count) {
    return 'استخدمت $count تلميحات';
  }

  @override
  String timeSpent(Object minutes) {
    return '$minutes دقائق';
  }

  @override
  String currentStreakDays(int count) {
    return 'سلسلة تعلّم لمدة $count أيام';
  }

  @override
  String levelUpTo(int level) {
    return 'ترقية إلى المستوى $level';
  }

  @override
  String levelProgress(int progress) {
    return 'التقدم نحو المستوى التالي: $progress٪';
  }

  @override
  String lessonCompleteDetailsError(String error) {
    return 'تعذر تحميل بعض تفاصيل إكمال الدرس: $error';
  }

  @override
  String get backToPath => 'العودة للمسار';

  @override
  String get unitLocked => 'مقفل';

  @override
  String get unitInProgress => 'قيد التقدم';

  @override
  String get unitCompleted => 'مكتمل';

  @override
  String get editorFontSize => 'حجم خط المحرر';

  @override
  String get fontSmall => 'صغير';

  @override
  String get fontMedium => 'متوسط';

  @override
  String get fontLarge => 'كبير';

  @override
  String get resetProgress => 'إعادة ضبط التقدم';

  @override
  String get resetConfirmation => 'هل أنت متأكد؟ سيتم حذف كل تقدمك.';

  @override
  String get aboutApp => 'حول التطبيق';

  @override
  String get sendFeedback => 'إرسال ملاحظات';

  @override
  String get engineDiagnosticsTitle => 'تشخيصات محرك GDScript';

  @override
  String get engineDiagnosticsDescription => 'استعراض تشخيصات ملفات GDScript في مساحة العمل المحددة.';

  @override
  String get engineDiagnosticsEmpty => 'لا توجد تشخيصات في ملفات مساحة العمل المفهرسة.';

  @override
  String engineDiagnosticsSummary(int count) {
    return 'عدد التشخيصات: $count';
  }

  @override
  String get startLearning => 'ابدأ التعلّم';

  @override
  String get newUserWelcome => 'مرحباً! ابدأ رحلتك في تعلّم البرمجة';

  @override
  String get returningWelcome => 'مرحباً بعودتك!';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get loading => 'جارٍ التحميل...';

  @override
  String get noLessons => 'لا توجد دروس في هذه الوحدة.';

  @override
  String get runExample => 'شغّل المثال';

  @override
  String get exampleLabel => 'المثال';

  @override
  String exerciseProgress(Object current, Object total) {
    return 'التمرين $current من $total';
  }

  @override
  String get nextExercise => 'التمرين التالي';

  @override
  String get runTests => 'تحقّق من الحل';

  @override
  String get allTestsPassed => 'أحسنت! كل الاختبارات ناجحة';

  @override
  String testSummary(Object passed, Object total) {
    return '$passed من $total ناجحة';
  }

  @override
  String get resetCodeConfirmation => 'إعادة الكود إلى نقطة البداية؟';

  @override
  String get hintUnavailable => 'لا توجد تلميحات أخرى.';

  @override
  String get lessonUnavailable => 'تعذّر تحميل الدرس.';

  @override
  String get lessonProgress => 'تقدم الدرس';

  @override
  String get quickTryCode => 'print(\"مرحباً!\")';

  @override
  String get workspaceUnavailable => 'ميزات مساحة العمل غير متاحة حالياً.';

  @override
  String get executionFailed => 'تعذّر تشغيل الشيفرة.';

  @override
  String get expectedOutput => 'المتوقع';

  @override
  String get actualOutput => 'الفعلي';

  @override
  String errorLine(Object line) {
    return 'خطأ في السطر $line';
  }

  @override
  String get workspacePath => 'مسار مجلد المشروع';

  @override
  String get completeCode => 'إكمال';

  @override
  String diagnosticLine(Object line) {
    return 'السطر $line';
  }

  @override
  String get workspaceSearchTitle => 'البحث في مساحة العمل';

  @override
  String get workspaceSearchPlaceholder => 'أدخل نصاً للبحث في ملفات GDScript المفهرسة';

  @override
  String get workspaceSearchEmpty => 'لم يتم العثور على نتائج.';

  @override
  String levelLabel(Object level) {
    return 'المستوى $level';
  }

  @override
  String totalXp(Object xp) {
    return '$xp نقطة خبرة';
  }

  @override
  String streakDays(Object count) {
    return 'سلسلة $count أيام';
  }

  @override
  String get streakInfo => 'تعلّم مرة واحدة على الأقل يوميًا للحفاظ على سلسلتك. تفويت يوم يعيد السلسلة الحالية إلى البداية، لكنه لا يحذف نقاط الخبرة أو الشارات.';

  @override
  String get badgesTitle => 'الشارات';

  @override
  String badgesCompletionSummary(int unlocked, int total) {
    return 'اكتسبت $unlocked من أصل $total شارات';
  }

  @override
  String badgeFilterAll(int count) {
    return 'الكل ($count)';
  }

  @override
  String badgeFilterEarned(int count) {
    return 'المكتسبة ($count)';
  }

  @override
  String badgeFilterInProgress(int count) {
    return 'قيد التقدم ($count)';
  }

  @override
  String badgeFilterLocked(int count) {
    return 'المقفلة ($count)';
  }

  @override
  String get badgeFilterEmpty => 'لا توجد شارات ضمن هذه الفئة.';

  @override
  String get badgeCatalogEmpty => 'لا توجد شارات متاحة حالياً.';

  @override
  String get badgeDetailsTitle => 'تفاصيل الشارة';

  @override
  String get badgeEarnedStatus => 'مكتسبة';

  @override
  String get badgeInProgressStatus => 'قيد التقدم';

  @override
  String get badgesLoadError => 'تعذّر تحميل الشارات. تحقق من الاتصال ثم أعد المحاولة.';

  @override
  String get badgeUnlocked => 'لقد فتحت شارة جديدة!';

  @override
  String get badgeLocked => 'لم تُكتسب بعد';

  @override
  String badgeProgress(Object current, Object target) {
    return '$current من $target';
  }

  @override
  String earnedOn(Object date) {
    return 'اكتُسبت في $date';
  }

  @override
  String xpAwarded(Object xp) {
    return 'اكتسبت $xp+ نقطة خبرة';
  }

  @override
  String get showStreak => 'إظهار سلسلة التعلّم اليومية';

  @override
  String get great => 'رائع!';

  @override
  String get syntaxExplorerTitle => 'مستكشف الصياغة';

  @override
  String get syntaxExplorerPlaceholder => 'ابحث عن الكلمات المفتاحية والصياغة والأمثلة';

  @override
  String get onboardingBrand => 'أكاديمية جودو';

  @override
  String get onboardingPlacementLabel => 'الإعداد الأولي وتحديد المسار (Placement & Onboarding)';

  @override
  String get onboardingSkip => 'تخطي إلى الرئيسية ↵';

  @override
  String get onboardingStepWelcome => 'الترحيب';

  @override
  String get onboardingStepExperience => 'مستوى الخبرة';

  @override
  String get onboardingStepAssessment => 'التقييم السريع';

  @override
  String get onboardingStepRoadmap => 'الخطة المخصصة';

  @override
  String get onboardingWelcomeHeading => 'أهلاً بك في أكاديمية جودو التعليمية!';

  @override
  String get onboardingWelcomeBody => 'المنصة العربية الأولى المتكاملة لاحتراف لغة GDScript 2.0 ومحرك Godot 4.3 عبر الممارسة الحية واختبارات الجودة والمشاريع التطبيقية.';

  @override
  String get onboardingWelcomeAction => 'ابدأ تحديد مستواك المخصص (دقيقتان) ↵';

  @override
  String get onboardingExperiencePrompt => 'ما هي خلفيتك البرمجية الحالية؟';

  @override
  String get onboardingExperienceDescription => 'سنقوم بتخصيص وتيرة المنهاج ونوعية التمارين لتناسب خبرتك.';

  @override
  String get onboardingTierBeginner => 'مبتدئ تماماً في البرمجة';

  @override
  String get onboardingTierBeginnerDescription => 'لم أكتب كوداً برمجياً من قبل وأرغب في بدء رحلتي من الصفر عبر فهم المتغيرات والدوال.';

  @override
  String get onboardingTierTransition => 'مبرمج قادم من لغات أخرى (Python, JS, C#)';

  @override
  String get onboardingTierTransitionDescription => 'أفهم أساسيات البرمجة والكائنات، وأريد إتقان صياغة GDScript 2.0 ومحرك Godot بكفاءة.';

  @override
  String get onboardingTierVeteran => 'مطور Godot 3 يرغب في الانتقال لـ Godot 4';

  @override
  String get onboardingTierVeteranDescription => 'أمتلك خبرة سابقة في Godot 3 وأريد استكشاف ميزات GDScript 2.0 والأنواع الصارمة والإشارات.';

  @override
  String get onboardingContinueAssessment => 'متابعة إلى الاختبار التشخيصي السريع (3 أسئلة) ↵';

  @override
  String onboardingQuestionProgress(int current, int total) {
    return 'السؤال $current من أصل $total';
  }

  @override
  String get onboardingAssessmentTag => 'تحديد المستوى الأكاديمي';

  @override
  String get onboardingQuestionTyping => 'ما هي الطريقة الصحيحة للإعلان عن متغير رقمي صارم (Strict Typing) في GDScript 2.0؟';

  @override
  String get onboardingCodeTyping => '# اختر الصياغة الأكثر كفاءة وأماناً للمترجم:';

  @override
  String get onboardingOptionTyping0 => 'var player_speed = 300.0';

  @override
  String get onboardingOptionTyping1 => 'var player_speed: float = 300.0';

  @override
  String get onboardingOptionTyping2 => 'float player_speed = 300.0;';

  @override
  String get onboardingOptionTyping3 => 'let player_speed: number = 300.0';

  @override
  String get onboardingQuestionPhysics => 'أي من الدوال التالية مسؤولة عن معالجة الحركة المتزامنة مع محرك الفيزياء في Godot؟';

  @override
  String get onboardingCodePhysics => 'func ???(delta: float) -> void:\\n    move_and_slide()';

  @override
  String get onboardingOptionPhysics0 => '_process(delta: float)';

  @override
  String get onboardingOptionPhysics1 => '_physics_process(delta: float)';

  @override
  String get onboardingOptionPhysics2 => '_fixed_update(delta: float)';

  @override
  String get onboardingOptionPhysics3 => '_integrate_forces(state: PhysicsDirectBodyState2D)';

  @override
  String get onboardingQuestionMatch => 'ما الدور الذي يلعبه الرمز _ في عبارة match داخل محرك Godot 4.3؟';

  @override
  String get onboardingCodeMatch => 'match player_state:\\n    \"IDLE\": velocity.x = 0.0\\n    _: handle_fallback()';

  @override
  String get onboardingOptionMatch0 => 'تجاهل بقية الكود وإيقاف التنفيذ';

  @override
  String get onboardingOptionMatch1 => 'يعمل كحالة افتراضية (Wildcard Fallback) لأي قيمة غير متطابقة';

  @override
  String get onboardingOptionMatch2 => 'تعريف متغير خاص غير مستخدم';

  @override
  String get onboardingOptionMatch3 => 'إطلاق خطأ تشغيل فوري (Assertion Error)';

  @override
  String get onboardingPrevious => 'السابق';

  @override
  String get onboardingNextQuestion => 'السؤال التالي ↵';

  @override
  String get onboardingFinishAssessment => 'إنهاء التقييم واقتراح الخطة ↵';

  @override
  String get onboardingRoadmapSuccess => 'تم إعداد خطتك التعليمية المخصصة بنجاح!';

  @override
  String onboardingRecommendedStart(String unit) {
    return 'نقطة الانطلاق الموصى بها: $unit';
  }

  @override
  String onboardingUnitLabel(String number) {
    return 'الوحدة $number';
  }

  @override
  String get onboardingSummaryBeginner => 'سنبدأ معك من الأساسيات لبناء قاعدة قوية في البرمجة وGDScript.';

  @override
  String get onboardingSummaryTransition => 'بناءً على إجاباتك وخلفيتك البرمجية، سنبدأ من المستوى الأنسب لتسريع مسارك.';

  @override
  String get onboardingSummaryVeteran => 'سنركز على المفاهيم التي تساعدك على الانتقال إلى GDScript 2.0 وGodot 4.';

  @override
  String get onboardingStartLearning => 'انتقل إلى مسار التعلّم وابدأ الدرس الأول ↵';

  @override
  String get onboardingSaveError => 'تعذّر حفظ تقدم الإعداد. حاول مرة أخرى.';

  @override
  String get onboardingRestoreError => 'تعذّر استعادة بيانات الإعداد المحفوظة.';

  @override
  String get syntaxCategoryAll => 'الكل';

  @override
  String get syntaxCategoryKeywords => 'الكلمات المفتاحية';

  @override
  String get syntaxCategoryBuiltins => 'العناصر المدمجة';

  @override
  String get syntaxCategoryTypes => 'الأنواع';

  @override
  String get syntaxExplorerLoadError => 'تعذّر تحميل مرجع الصياغة.';

  @override
  String get syntaxExplorerProgressError => 'تعذّر تسجيل استخدام مستكشف الصياغة.';

  @override
  String get syntaxExplorerPageDescription => 'ابحث في الكلمات المفتاحية والعناصر المدمجة والأنواع في GDScript.';

  @override
  String get syntaxExplorerRetry => 'إعادة المحاولة';

  @override
  String get syntaxExplorerSearchHint => 'ابحث عن كلمة مفتاحية أو عنصر مدمج أو نوع بيانات...';

  @override
  String get syntaxExplorerSortAlphabetical => 'الترتيب: أبجدي';

  @override
  String get syntaxExplorerEntriesHeading => 'العناصر';

  @override
  String syntaxExplorerCount(int count) {
    return '$count عنصر موثّق';
  }

  @override
  String syntaxExplorerVisibleCount(int visible, int total) {
    return 'عرض $visible من أصل $total';
  }

  @override
  String get syntaxExplorerLoadMore => 'تحميل المزيد';

  @override
  String get syntaxExplorerSelected => 'محدد';

  @override
  String get syntaxExplorerNoResults => 'لا توجد نتائج مطابقة.';

  @override
  String get syntaxExplorerSelectEntry => 'اختر عنصرًا من القائمة لعرض التفاصيل.';

  @override
  String get syntaxExplorerSignature => 'الصياغة';

  @override
  String get syntaxExplorerExample => 'مثال';

  @override
  String get syntaxExplorerExplanation => 'الشرح';

  @override
  String get syntaxExplorerCopyEntry => 'نسخ العنصر';

  @override
  String get syntaxExplorerCopyExample => 'نسخ المثال';

  @override
  String syntaxExplorerCopied(String item) {
    return 'تم نسخ $item';
  }

  @override
  String get syntaxExplorerOpenLesson => 'فتح الدرس';

  @override
  String get syntaxExplorerOpenWorkspace => 'فتح مساحة العمل';

  @override
  String get syntaxExplorerRelatedConcepts => 'مفاهيم مرتبطة';

  @override
  String get syntaxExplorerLessonUnavailable => 'لا يتوفر درس مرتبط بهذا العنصر.';

  @override
  String get syntaxExplorerClearSearch => 'مسح البحث';

  @override
  String workspaceIndexedFilesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ملف مفهرس',
      many: '$count ملفاً مفهرساً',
      few: '$count ملفات مفهرسة',
      two: 'ملفان مفهرسان',
      one: 'ملف واحد مفهرس',
      zero: 'لا توجد ملفات',
    );
    return '$_temp0';
  }

  @override
  String workspaceFileCountSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ملف',
      many: '$count ملفاً',
      few: '$count ملفات',
      two: 'ملفان',
      one: 'ملف واحد',
      zero: 'لا توجد ملفات',
    );
    return '$_temp0';
  }

  @override
  String get workspaceSettings => 'إعداد مساحة العمل';

  @override
  String get workspaceReindex => 'إعادة الفهرسة';

  @override
  String get workspaceEngineReady => 'محرك GDScript جاهز';

  @override
  String get workspaceEngineUnavailable => 'محرك GDScript غير متاح';

  @override
  String get workspaceFilesTab => 'الملفات';

  @override
  String get workspaceSearchTab => 'البحث';

  @override
  String get workspaceSearchProjectFiles => 'بحث في ملفات المشروع';

  @override
  String get workspaceSearchFiles => 'البحث في الملفات';

  @override
  String get workspaceMatchingFiles => 'الملفات المطابقة';

  @override
  String get workspaceSaveFile => 'حفظ الملف';

  @override
  String get workspaceFileInfoTitle => 'معلومات الملف';

  @override
  String get workspaceNoFileOpen => 'لا يوجد ملف مفتوح';

  @override
  String workspaceFileLinesCount(int count) {
    return 'الأسطر: $count';
  }

  @override
  String workspaceFileSizeCharacters(int count) {
    return 'الحجم: $count محرف';
  }

  @override
  String get workspaceOutputTab => 'المخرجات';

  @override
  String get workspaceProblemsTab => 'المشكلات';

  @override
  String get workspaceCopyOutput => 'نسخ المخرجات';

  @override
  String get workspaceClearOutput => 'مسح المخرجات';

  @override
  String get workspaceEngineStatusReady => 'جاهز';

  @override
  String get workspaceEngineStatusUnavailable => 'غير متاح';

  @override
  String get workspaceExecutionRunning => 'جارٍ التنفيذ...';

  @override
  String get workspaceEmptyOutput => 'لا توجد مخرجات بعد. شغّل السكربت لعرضها.';

  @override
  String get workspaceNoProblems => 'لا توجد مشكلات للملف المفتوح.';

  @override
  String get workspaceSearchFilterPlaceholder => 'ابحث عن ملف أو سكربت...';

  @override
  String get workspaceEngineUnavailableNotice => 'GDScript 2.0 • المحرك غير متاح';

  @override
  String workspaceStatusBarCoordinates(int line, int column) {
    return 'السطر $line، العمود $column';
  }

  @override
  String get workspaceUnsavedChangesWarning => 'هناك تعديلات غير محفوظة. هل تريد إغلاق الملف والتخلص منها؟';

  @override
  String get workspaceDirectInspectAction => 'تحليل وتحرير مباشر داخل التطبيق';

  @override
  String get conceptMapHeroTitle => 'خريطة المفاهيم وخوارزمية التكرار المتباعد SM-2';

  @override
  String get conceptMapHeroSubtitle => 'تتبع تقدمك في شجرة المعرفة وثبّت المفاهيم البرمجية في الذاكرة طويلة المدى.';

  @override
  String get conceptMapQuickReviewSession => 'جلسة مراجعة سريعة';

  @override
  String conceptMapRecallRate(int rate) {
    return 'معدل الاسترجاع: $rate%';
  }

  @override
  String conceptMapDueCardsToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count بطاقة مستحقة اليوم',
      many: '$count بطاقة مستحقة اليوم',
      few: '$count بطاقات مستحقة اليوم',
      two: 'بطاقتان مستحقتان اليوم',
      one: 'بطاقة واحدة مستحقة اليوم',
      zero: 'لا توجد بطاقات مستحقة اليوم',
    );
    return '$_temp0';
  }

  @override
  String get conceptMapStartReviewAction => 'بدء المراجعة الآن';

  @override
  String get conceptMapBackToMap => 'العودة للخريطة';

  @override
  String get conceptMapDueTodayBadge => 'مستحق اليوم';

  @override
  String conceptMapRemainingCards(int count) {
    return 'البطاقات المتبقية: $count';
  }

  @override
  String get conceptMapSm2RatingAgain => 'إعادة';

  @override
  String get conceptMapSm2RatingHard => 'صعب';

  @override
  String get conceptMapSm2RatingGood => 'جيد';

  @override
  String get conceptMapSm2RatingEasy => 'سهل';

  @override
  String get conceptMapRevealAnswer => 'كشف الإجابة';

  @override
  String get conceptMapOverviewHeading => 'شرح المفهوم:';

  @override
  String get conceptMapCodeExampleHeading => 'مثال برمجي:';

  @override
  String get conceptMapStatusHeading => 'حالة المفهوم';

  @override
  String conceptMapLastReviewedDate(String date) {
    return 'آخر مراجعة: $date';
  }

  @override
  String get conceptMasteryLocked => 'مقفل';

  @override
  String get conceptMasteryLearning => 'قيد التعلم';

  @override
  String get conceptMasteryReviewing => 'قيد المراجعة';

  @override
  String get conceptMasteryMastered => 'متقن';

  @override
  String get conceptMapEmptyState => 'لا توجد مفاهيم متاحة حالياً.';

  @override
  String get conceptMapRetryAction => 'إعادة المحاولة';

  @override
  String get settingsSavedSuccessToast => 'تم حفظ كافة التفضيلات بنجاح وتمت مزامنتها مع محرك Godot 4.3 ✓';

  @override
  String get settingsPreferencesSections => 'أقسام التفضيلات';

  @override
  String get settingsTabCodeEditor => 'محرر الأكواد والخطوط';

  @override
  String get settingsTabLspEngine => 'خادم LSP ومسار المحرك';

  @override
  String get settingsTabAppearanceTheme => 'المظهر والسمة البصرية';

  @override
  String get settingsTabAccountAcademic => 'الحساب والمسار الأكاديمي';

  @override
  String get settingsDesktopTitle => 'الإعدادات وتفضيلات النظام وبيئة المحرك';

  @override
  String get settingsSaveShortcutAction => 'حفظ التغييرات (Ctrl+S) ↵';

  @override
  String get settingsEditorPrefsTitle => 'تفضيلات محرر الكود (GDScript Editor)';

  @override
  String get settingsEditorPrefsSubtitle => 'تخصيص مقاس الخط، التباعد، وسلوك الإكمال التلقائي في بيئة التطوير.';

  @override
  String settingsEditorFontSize(int size) {
    return 'مقاس خط المحرر البرمجي ($size px):';
  }

  @override
  String get settingsEditorFontSizeHint => 'يتم تطبيق المقاس على خط JetBrains Mono المخصص لكتابة GDScript.';

  @override
  String get settingsEditorTabSize => 'مسافة الإزاحة (Tab Size):';

  @override
  String get settingsEditorTabSizeStandard => 'المعيار الرسمي في GDScript 2.0 هو 4 مسافات مسافية.';

  @override
  String settingsTabSpacesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مسافة',
      few: '$count مسافات',
      two: 'مسافتان',
      one: 'مسافة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get settingsTabSpacesRecommended => '4 مسافات (موصى به)';

  @override
  String get settingsShowLineNumbersTitle => 'إظهار أرقام الأسطر (Line Numbers)';

  @override
  String get settingsShowLineNumbersSubtitle => 'عرض عمود الأرقام على يمين المحرر لسهولة التتبع والتشخيص.';

  @override
  String get settingsHighlightActiveLineTitle => 'إبراز السطر النشط (Highlight Active Line)';

  @override
  String get settingsHighlightActiveLineSubtitle => 'تظليل خلفية السطر الذي يقف عليه المؤشر بلون مغاير.';

  @override
  String get settingsAutoCloseBracketsTitle => 'إغلاق الأقواس وعلامات التنصيص تلقائياً';

  @override
  String get settingsAutoCloseBracketsSubtitle => 'إكمال الأقواس المتنوعة وعلامات التنصيص تلقائياً فور كتابتها.';

  @override
  String get settingsLspSectionTitle => 'خادم اللغة LSP ومحرك Godot 4.3';

  @override
  String get settingsLspSectionSubtitle => 'إدارة جسر الاتصال المحلي ومسارات تشغيل المحرك وبروتوكول JSON-RPC 2.0.';

  @override
  String get settingsOpenDiagnosticsLog => 'فتح سجل التشخيصات المباشر ↵';

  @override
  String get settingsGodotExecutablePath => 'مسار المحرك التنفيذي (Godot Executable Path):';

  @override
  String get settingsLspPort => 'منفذ الاتصال المحلي (LSP Port):';

  @override
  String get settingsStrictTypingTitle => 'فرض تحذيرات الأنواع غير الصارمة (Strict Typing)';

  @override
  String get settingsStrictTypingSubtitle => 'إطلاق تحذيرات فورية عند كتابة متغيرات Variant ديناميكية بدون تصريح نوع صريح.';

  @override
  String get settingsAutoStartLspTitle => 'بدء تشغيل خادم LSP تلقائياً عند فتح الأكاديمية';

  @override
  String get settingsAutoStartLspSubtitle => 'تهيئة وإطلاق جسر الاتصال في الخلفية بمجرد تشغيل الواجهة.';

  @override
  String get settingsAppearanceSectionTitle => 'المظهر والسمة البصرية';

  @override
  String get settingsAppearanceSectionSubtitle => 'تخصيص نسق الألوان بما يطابق واجهة محرك Godot الرسمية وتفضيلات شاشتك.';

  @override
  String get settingsActiveThemeLabel => 'السمة النشطة:';

  @override
  String get settingsDarkThemeGodotDesc => 'الوضع الداكن المعتمد بدرجات الأزرق والرمادي الداكن #0F141B.';

  @override
  String get settingsArabicFontTitle => 'خط الواجهة العربي:';

  @override
  String get settingsArabicFontSubtitle => 'خط معتمد عالي الوضوح للغة العربية في البرمجيات التقنية.';

  @override
  String get learningPathAcademyBrand => 'أكاديمية جودو';

  @override
  String get learningPathCurriculumYear => 'منهج 2025';

  @override
  String get learningPathCourseTab => 'مسار المنهج';

  @override
  String get learningPathConceptMapTab => 'خريطة المفاهيم';

  @override
  String get learningPathSmartReviewTab => 'مراجعة ذكية';

  @override
  String get learningPathNoLessonsYet => 'لا توجد دروس مضافة إلى هذا المسار بعد.';

  @override
  String get learningPathStageFundamentals => 'الأساسيات';

  @override
  String get learningPathStageJourneyStart => 'بداية الرحلة';

  @override
  String get learningPathStageLogicMaker => 'صانع المنطق';

  @override
  String get learningPathStageNextPhase => 'المرحلة التالية';

  @override
  String get learningPathStageEngineExpert => 'خبير المحرك';

  @override
  String get learningPathStageAdvancedPhase => 'المرحلة المتقدمة';

  @override
  String get learningPathUnitStatusDone => 'مكتملة';

  @override
  String get learningPathUnitStatusCurrent => 'الوحدة الحالية';

  @override
  String get learningPathUnitStatusLocked => 'مغلقة';

  @override
  String get learningPathCompletePrevious => 'أكمل الوحدة السابقة';

  @override
  String get learningPathHideLessons => 'إخفاء الدروس';

  @override
  String get learningPathShowLessonsAction => 'عرض الدروس';

  @override
  String get learningPathLessonStatusDone => 'تم الإنجاز';

  @override
  String get learningPathLessonStatusCurrent => 'الدرس الحالي';

  @override
  String get learningPathLessonStatusSoon => 'قريباً';

  @override
  String get learningPathMasteryDashboard => 'لوحة الإتقان والإحصائيات';

  @override
  String get dashboardDailyChallengeTitle => 'تحدي اليوم السريع';

  @override
  String dashboardChallengeParticipants(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'شارك $count مطور اليوم',
      many: 'شارك $count مطوراً اليوم',
      few: 'شارك $count مطورين اليوم',
      two: 'شارك مطوران اليوم',
      one: 'شارك مطور واحد اليوم',
    );
    return '$_temp0';
  }

  @override
  String dashboardChallengeStartAction(int xp) {
    return 'خوض التحدي (+$xp XP)';
  }

  @override
  String get dashboardSmartReviewCardTitle => 'المراجعة الذكية (SM-2)';

  @override
  String dashboardSmartReviewCardBody(int count) {
    return 'لديك $count بطاقات مفاهيم مستحقة للمراجعة اليوم لتثبيت الذاكرة طويلة المدى.';
  }

  @override
  String dashboardSmartReviewRetention(int percent) {
    return 'معدل الاسترجاع $percent%';
  }

  @override
  String dashboardSmartReviewDuration(int minutes) {
    return '~$minutes دقائق';
  }

  @override
  String get dashboardStartQuickReview => 'بدء جلسة المراجعة السريعة';

  @override
  String get dashboardCodingStatsTitle => 'إحصائياتك البرمجية';

  @override
  String get dashboardViewBadgesAction => 'الأوسمة ↵';

  @override
  String get dashboardStatsLinesWritten => 'أسطر كود GDScript مكتوبة:';

  @override
  String dashboardStatsLinesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count سطر',
      many: '$count سطراً',
      few: '$count أسطر',
      two: 'سطران',
      one: 'سطر واحد',
    );
    return '$_temp0';
  }

  @override
  String get dashboardStatsChallengesPassed => 'تحديات برمجية تم اجتيازها:';

  @override
  String dashboardStatsChallengesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تحدٍّ',
      many: '$count تحدياً',
      few: '$count تحديات',
      two: 'تحديان',
      one: 'تحدٍّ واحد',
    );
    return '$_temp0';
  }

  @override
  String get dashboardStatsBadgesEarned => 'أوسمة مكتسبة معتمدة:';

  @override
  String dashboardStatsBadgesRatio(int earned, int total) {
    return '$earned من $total أوسمة';
  }

  @override
  String get calloutOfficialWarning => 'تحذير رسمي';

  @override
  String get calloutBestPractice => 'توصية وممارسة فضلى';

  @override
  String get calloutTechnicalNote => 'معلومة هندسية';

  @override
  String get calloutGoldenRule => 'القاعدة الذهبية';

  @override
  String get lessonDocumentationHeader => 'توثيق الدرس';

  @override
  String get lessonDocumentationSources => 'المصادر';

  @override
  String get lessonDocumentationLicenseNotice => 'يستند هذا المحتوى إلى توثيق Godot Engine المرخّص بموجب CC BY 3.0. هذا إعداد تعليمي مستقل وليس معتمداً من Godot.';

  @override
  String get lessonSplitterDragTooltip => 'اسحب لتغيير عرض اللوحتين';

  @override
  String get reviewScreenTitle => 'المراجعة الذكية';

  @override
  String get reviewScreenTodayHeader => 'استعراض اليوم';

  @override
  String reviewDueItemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عنصر مستحق',
      many: '$count عنصراً مستحقاً',
      few: '$count عناصر مستحقة',
      two: 'عنصران مستحقان',
      one: 'عنصر واحد مستحق',
      zero: 'لا توجد عناصر مستحقة',
    );
    return '$_temp0';
  }

  @override
  String get reviewEmptyStateMessage => 'لا توجد مراجعات مستحقة اليوم. عد لاحقاً.';

  @override
  String reviewIntervalDays(int days) {
    return 'فاصل $days يوم';
  }

  @override
  String reviewLessonReference(String lessonId) {
    return 'درس: $lessonId';
  }

  @override
  String reviewCardUpdatedNotice(String title, String date) {
    return 'تم تحديث $title → $date';
  }

  @override
  String get capstoneScreenTitle => 'مشروع التطوير التكاملي';

  @override
  String get exerciseActionCheckAnswer => 'تحقق من الإجابة';

  @override
  String get exerciseActionRun => 'تشغيل الكود';
}
