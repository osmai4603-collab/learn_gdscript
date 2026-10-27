const prohibitedQuestionPhrases = <String>[
  'ما الفكرة الأساسية في هذا الدرس',
  'ما الفكرة الرئيسية في هذا الدرس',
  'أي ممارسة تساعد على استخدام المفهوم',
  'what is the main idea of this lesson',
  'which practice helps use the concept',
];

const requiredArabicSectionPatterns = <String, List<String>>{
  'المفهوم والهدف': ['المفهوم', 'الهدف'],
  'الصياغة والقواعد': ['الصياغة', 'القواعد', 'القاعدة'],
  'مثال عملي مشروح': ['مثال عملي', 'مثال مشروح'],
  'أخطاء شائعة وتحذيرات': ['أخطاء شائعة', 'تحذيرات'],
  'قاعدة ذهبية وملخص': ['قاعدة ذهبية', 'ملخص'],
};

const directivePattern = r'\[!(WARNING|NOTE|TIP)\]';
const minimumCodeTestCases = 2;
const minimumLessonMinutes = 8;
const maximumLessonMinutes = 25;
