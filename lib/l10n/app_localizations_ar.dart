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
  String get dashboardLspConnecting => 'GDScript: محلي | LSP: جارٍ الاتصال';

  @override
  String get dashboardLspActive => 'GDScript: محلي | LSP: نشط';

  @override
  String get dashboardLspDisconnected => 'GDScript: محلي | LSP: غير متصل';

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
  String get dashboardEngineTitle => 'خادم اللغة والمحاكي';

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
  String get dashboardLsp => 'خادم اللغة';

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
  String get workspaceDescription => 'تشغيل خادم اللغة محليًا مدعوم على أجهزة سطح المكتب فقط.';

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
  String get settingsEngineCategory => 'المحرك وخادم اللغة';

  @override
  String get settingsAboutCategory => 'حول التطبيق والتقدم';

  @override
  String get settingsEditorDescription => 'تخصيص تفضيلات محرر GDScript.';

  @override
  String get settingsAppearanceDescription => 'اختيار لغة العرض ونسق الألوان وسلوك المظهر.';

  @override
  String get settingsEngineDescription => 'حالة خادم اللغة والانتقال إلى أدوات التطوير.';

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
  String get lspStatus => 'حالة خادم اللغة';

  @override
  String get lspConnected => 'متصل';

  @override
  String get lspDisconnected => 'غير متصل';

  @override
  String get lspDiagnosticsTitle => 'تشخيصات خادم اللغة';

  @override
  String get lspDiagnosticsDescription => 'استعراض الأخطاء والتحذيرات التي يرسلها خادم اللغة.';

  @override
  String get lspDiagnosticsEmpty => 'لا توجد تشخيصات حالية.';

  @override
  String get lspDiagnosticsConnectPrompt => 'اتصل بخادم اللغة من مساحة العمل لعرض التشخيصات.';

  @override
  String lspDiagnosticsSummary(int count) {
    return 'عدد التشخيصات: $count';
  }

  @override
  String get lspDiagnosticError => 'أخطاء';

  @override
  String get lspDiagnosticWarning => 'تحذيرات';

  @override
  String get lspDiagnosticInformation => 'معلومات';

  @override
  String get lspDiagnosticHint => 'تلميحات';

  @override
  String get lspDiagnosticNoMessage => 'لم يقدّم خادم اللغة وصفاً لهذا التشخيص.';

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
  String get lspExecutablePath => 'مسار ملف خادم اللغة (اختياري)';

  @override
  String get connectLsp => 'اتصال وفهرسة';

  @override
  String get disconnectLsp => 'قطع الاتصال';

  @override
  String indexedFiles(Object count) {
    return '$count ملفات مفهرسة';
  }

  @override
  String get lspConnectionError => 'تعذّر الاتصال بخادم اللغة.';

  @override
  String get completeCode => 'إكمال';

  @override
  String get formatCode => 'تنسيق';

  @override
  String get lspFeatureError => 'تعذّرت ميزة خادم اللغة.';

  @override
  String diagnosticLine(Object line) {
    return 'السطر $line';
  }

  @override
  String get workspaceSearchTitle => 'البحث في مساحة العمل';

  @override
  String get workspaceSearchPlaceholder => 'أدخل نصاً أو رمزاً للبحث';

  @override
  String get searchWorkspaceText => 'نص';

  @override
  String get searchWorkspaceSymbols => 'رموز';

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
  String get syntaxExplorerDocumentedCount => 'عنصر موثّق';

  @override
  String get syntaxExplorerSearchHint => 'ابحث عن كلمة مفتاحية أو عنصر مدمج أو نوع بيانات...';

  @override
  String get syntaxExplorerSortAlphabetical => 'الترتيب: أبجدي';

  @override
  String get syntaxExplorerEntriesHeading => 'العناصر';

  @override
  String syntaxExplorerCount(int count) {
    return '$count عنصر';
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
}
