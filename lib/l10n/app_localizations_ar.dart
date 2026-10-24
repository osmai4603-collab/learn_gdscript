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
  String get learningPathTitle => 'مسار التعلّم';

  @override
  String get learningPathEmpty => 'ستُضاف المواد التعليمية في مرحلة لاحقة.';

  @override
  String get workspaceTitle => 'مساحة العمل';

  @override
  String get workspaceDescription => 'تشغيل خادم اللغة محليًا مدعوم على أجهزة سطح المكتب فقط.';

  @override
  String get settingsTitle => 'الإعدادات';

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
}
