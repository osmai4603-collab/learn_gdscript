# الخطة التنفيذية الشاملة لتعريب وتوحيد نصوص الشاشات عبر ملفات الترجمة ARB

# (Screens Localization & ARB Refactoring Plan)

> **تاريخ الإعداد:** 2026-10-27  
> **حالة الوثيقة:** معتمدة للتنفيذ الفوري  
> **المجال المستهدف:** كافة شاشات وودجات واجهة المستخدم (`lib/ui/screens/**` و `lib/ui/widgets/**`)  
> **ملفات الترجمة المركزية:**  
>
> - [`lib/l10n/app_ar.arb`](file:///home/osm/flutter_projects/learn_gdscript/lib/l10n/app_ar.arb) (المرجع العربي المعتمد)  
> - [`lib/l10n/app_en.arb`](file:///home/osm/flutter_projects/learn_gdscript/lib/l10n/app_en.arb) (المرجع الإنجليزي القالب)  
> - [`lib/l10n/app_localizations.dart`](file:///home/osm/flutter_projects/learn_gdscript/lib/l10n/app_localizations.dart) (الكود المولد تلقائياً)  
> - [`lib/core/extensions/context_extensions.dart`](file:///home/osm/flutter_projects/learn_gdscript/lib/core/extensions/context_extensions.dart) (`context.l10n`)  

---

## فهرس الوثيقة

1. [المقدمة والهدف الاستراتيجي](#1-المقدمة-والهدف-الاستراتيجي)
2. [التشخيص المعماري وجرد الوضع الراهن (Root Cause & Audit)](#2-التشخيص-المعماري-وجرد-الوضع-الراهن-root-cause--audit)
3. [المعايير الهندسية وقواعد فصل المسؤوليات (Architectural Standards)](#3-المعايير-الهندسية-وقواعد-فصل-المسؤوليات-architectural-standards)
4. [قاموس المفاتيح ونصوص ARB المستهدفة (Key Dictionary & Translations)](#4-قاموس-المفاتيح-ونصوص-arb-المستهدفة-key-dictionary--translations)
5. [خطة المراحل التنفيذية المتسلسلة (Phased Execution Roadmap)](#5-خطة-المراحل-التنفيذية-المتسلسلة-phased-execution-roadmap)
6. [آليات منع الانحدار والفحص الآلي (Regression Guard & Linting)](#6-آليات-منع-الانحدار-والفحص-الآلي-regression-guard--linting)
7. [معايير القبول والاعتماد (Definition of Done)](#7-معايير-القبول-والاعتماد-definition-of-done)

---

## 1. المقدمة والهدف الاستراتيجي

يهدف مشروع **"تعلّم GDScript"** إلى تقديم بيئة تعليمية احترافية ثنائية اللغة (العربية والإنجليزية) متوافقة كلياً مع معايير Flutter الدولية الرسمية ونظام الترجمة القياسي القائم على ملفات **Application Resource Bundle (ARB)** ومحرك توليد الأكواد `flutter gen-l10n`.

### الهدف الأساسي من الخطة

القضاء التام والشامل على أي نصوص مكتوبة بشكل مباشر (Hardcoded String Literals) داخل كود الشاشات والودجات، وإلغاء الدوال المساعدة الالتفافية (مثل دالة `_localized` أو `_conceptMapCopy`)، وإلغاء الاستعلام المباشر عن رمز اللغة عبر الشرطيات (مثل `locale.languageCode == 'ar' ? ... : ...`). بدلاً من ذلك، يتم استدعاء كافة نصوص الواجهة من ملفات الترجمة المركزية `app_ar.arb` و `app_en.arb` عبر الامتداد المعتمد:

```dart
context.l10n.<keyName>
```

---

## 2. التشخيص المعماري وجرد الوضع الراهن (Root Cause & Audit)

أظهر الفحص الدقيق والمسح الشامل لمجلد `lib/ui/` وجود ثلاثة أنماط مضادة (Anti-Patterns) رئيسية تعيق اكتمال التعريب وتتسبب في تشتت النصوص واختفاء بعض الترجمات عند التبديل للإنجليزية:

```text
                                ┌──────────────────────────────────────────────┐
                                │          الأنماط المضادة المكتشفة            │
                                └──────────────────────────────────────────────┘
                                                       │
         ┌─────────────────────────────────────────────┼─────────────────────────────────────────────┐
         ▼                                             ▼                                             ▼
┌──────────────────────────────┐              ┌──────────────────────────────┐              ┌──────────────────────────────┐
│  1. دوال التفافية محلية      │              │  2. شرطيات فحص اللغة         │              │  3. نصوص مباشرة صلبة         │
│  تستقبل نصوصاً خام           │              │  (languageCode Ternaries)    │              │  (Hardcoded String Literals) │
├──────────────────────────────┤              ├──────────────────────────────┤              ├──────────────────────────────┤
│ • _localized(...) [29 موقعاً]│              │ • locale.languageCode == 'ar'│              │ • نصوص عربية مباشرة بملفات   │
│ • _conceptMapCopy [26 موقعاً]│              │   تحدد نصوصاً بديلة بالإنجليزية│             │   الشاشات لسطح المكتب        │
│ • _conceptMapText [5 مواقع]  │              │   مشتتة داخل الودجات         │              │   دون أي مفاتيح ترجمة        │
└──────────────────────────────┘              └──────────────────────────────┘              └──────────────────────────────┘
```

### جرد الملفات المتأثرة ومواقع الخلل بالتفصيل

| الملف المستهدف | النمط المكتشف | عدد الحالات | تفاصيل الخلل وتأثيره |
| :--- | :--- | :---: | :--- |
| [`lib/ui/screens/workspace/workspace_projects_ide_flutter_dart.dart`](file:///home/osm/flutter_projects/learn_gdscript/lib/ui/screens/workspace/workspace_projects_ide_flutter_dart.dart) | تعريف واستدعاء `_localized(context, ar, en)` | **29** استدعاء | تمرير نصوص عربية وإنجليزية خام داخل كل استدعاء بالودجات، مما يلغي الاستفادة من ARB ويصعب التدقيق. |
| [`lib/ui/screens/concept_map/desktop_concept_map_sm_2_flutter_dart.dart`](file:///home/osm/flutter_projects/learn_gdscript/lib/ui/screens/concept_map/desktop_concept_map_sm_2_flutter_dart.dart) | تعريف واستدعاء `_conceptMapCopy(context, ar, en)` | **26** استدعاء + **6** شرطيات | تكرار تمرير النصوص الإنجليزية والعربية في كل عنصر (أزرار SM-2، مستويات الإتقان، نسب الاسترجاع). |
| [`lib/ui/screens/concept_map/concept_map_screen.dart`](file:///home/osm/flutter_projects/learn_gdscript/lib/ui/screens/concept_map/concept_map_screen.dart) | تعريف واستدعاء `_conceptMapText(locale, ar, en)` | **5** استدعاءات | نصوص زر إعادة المحاولة ورسائل الحالة الفارغة والتحميل. |
| [`lib/ui/screens/learning_path/desktop_learning_path_flutter_dart.dart`](file:///home/osm/flutter_projects/learn_gdscript/lib/ui/screens/learning_path/desktop_learning_path_flutter_dart.dart) | نصوص عربية صلبة بدون ترجمة | **123** سطراً | شارات الوحدات، أزرار إخفاء/عرض الدروس، تفاصيل الوحدة، إحصائيات التقدّم، ولوحة الإتقان. |
| [`lib/ui/screens/settings/desktop_settings_flutter_dart.dart`](file:///home/osm/flutter_projects/learn_gdscript/lib/ui/screens/settings/desktop_settings_flutter_dart.dart) | نصوص عربية صلبة لخيارات الإعدادات | **48** سطراً | عناوين أقسام الإعدادات، مسارات LSP، خطوط الواجهة، إشعار الحفظ، أحجام المسافات. |
| [`lib/ui/screens/home/desktop_home_dashboard.dart`](file:///home/osm/flutter_projects/learn_gdscript/lib/ui/screens/home/desktop_home_dashboard.dart) | نصوص عربية صلبة بالبطاقات التفاعلية | **36** سطراً | بطاقة التحدي السريع، بطاقة المراجعة الذكية SM-2، ملخص الإحصائيات (أسطر الكود، الأوسمة). |
| [`lib/ui/screens/workspace/workspace_screen.dart`](file:///home/osm/flutter_projects/learn_gdscript/lib/ui/screens/workspace/workspace_screen.dart) | شرطيات `languageCode == 'ar'` | **4** مواقع | حوار التعديلات غير المحفوظة، أزرار ووصف مساحة العمل المباشرة. |
| [`lib/ui/screens/review/review_screen.dart`](file:///home/osm/flutter_projects/learn_gdscript/lib/ui/screens/review/review_screen.dart) | نصوص عربية صلبة | **8** أسطر | عناوين المراجعة الذكية، عدد البطاقات المستحقة، الحالة الفارغة، وتحديث الجدولة. |
| [`lib/ui/screens/capstone/capstone_screen.dart`](file:///home/osm/flutter_projects/learn_gdscript/lib/ui/screens/capstone/capstone_screen.dart) | نصوص عربية صلبة | **7** أسطر | عنوان المشروع التكاملي وأسماء المراحل الست. |
| [`lib/ui/screens/lesson/widgets/lesson_callout_card.dart`](file:///home/osm/flutter_projects/learn_gdscript/lib/ui/screens/lesson/widgets/lesson_callout_card.dart) | شرطيات `isEnglish` لعناوين الحاويات | **4** مواقع | تحذير رسمي، توصية فضلى، معلومة هندسية، القاعدة الذهبية. |
| [`lib/ui/screens/lesson/lesson_documentation_section.dart`](file:///home/osm/flutter_projects/learn_gdscript/lib/ui/screens/lesson/lesson_documentation_section.dart) | شرطيات `isEnglish` لعناوين التوثيق | **3** مواقع | توثيق الدرس، المصادر، وبيان ترخيص توثيق Godot (CC BY 3.0). |
| [`lib/ui/screens/lesson/desktop_lesson_ide_flutter_dart.dart`](file:///home/osm/flutter_projects/learn_gdscript/lib/ui/screens/lesson/desktop_lesson_ide_flutter_dart.dart) | شرطيات `languageCode == 'ar'` | **3** مواقع | تلميح سحب فاصل اللوحتين، وحالة جاهزية محرك GDScript. |
| [`lib/ui/widgets/exercise/exercise_widget.dart`](file:///home/osm/flutter_projects/learn_gdscript/lib/ui/widgets/exercise/exercise_widget.dart) | شرطيات `languageCode == 'en'` | **3** مواقع | أزرار "تحقق من الإجابة" و "تشغيل". |
| [`lib/ui/screens/home/home_screen.dart`](file:///home/osm/flutter_projects/learn_gdscript/lib/ui/screens/home/home_screen.dart) | شرطيات `languageCode == 'ar'` | **2** موقعان | الاسم الافتراضي للمتعلم والوقت المقدر. |
| [`lib/ui/screens/learning_path/learning_path_screen.dart`](file:///home/osm/flutter_projects/learn_gdscript/lib/ui/screens/learning_path/learning_path_screen.dart) | شرطيات `languageCode == 'ar'` | **2** موقعان | شارة الأيام المتتالية وزر الدرس التالي. |
| [`lib/ui/screens/settings/settings_screen.dart`](file:///home/osm/flutter_projects/learn_gdscript/lib/ui/screens/settings/settings_screen.dart) | شرطية `languageCode == 'ar'` | **1** موقع | اسم اللغة المعروض في قائمة التبديل. |
| [`lib/ui/widgets/code_editor/code_editor_widget.dart`](file:///home/osm/flutter_projects/learn_gdscript/lib/ui/widgets/code_editor/code_editor_widget.dart) | شرطية `languageCode == 'ar'` | **1** موقع | نص الخطأ الافتراضي عند تعذر الفحص الدلالي. |

---

## 3. المعايير الهندسية وقواعد فصل المسؤوليات (Architectural Standards)

### أ. قاعدة الفصل بين نصوص الواجهة (UI Chrome) والمحتوى المنهجي (Curriculum Content)

لضمان دقة المعمارية، يجب التمييز الصارم بين نوعين من النصوص في النظام:

1. **نصوص الواجهة وإطارات التحكم (UI Chrome & Controls):**
   - تشمل: أسماء الأزرار، نصوص التلميحات (Tooltips)، عناوين القوائم والتبويبات، نصوص الحوارات، شارات الحالات، رسائل الأخطاء والفراغ.
   - **المصدر الحصري:** ملفات ARB (`lib/l10n/app_ar.arb` و `lib/l10n/app_en.arb`).
   - **طريقة الوصول:** حصرياً عبر `context.l10n.<keyName>` أو `AppLocalizations.of(context)!.<keyName>`.
   - **المنع الصارم:** يُمنع منعاً باتاً إنشاء دوال محلية مثل `_localized` أو تمرير نصوص مباشرة داخل الودجت.

2. **المحتوى التعليمي والبيانات الديناميكية (Domain Models & Curriculum Data):**
   - تشمل: محتوى الدروس (Markdown)، نصوص التمارين، التلميحات التعليمية، بيانات المفاهيم في قاعدة البيانات، وعناوين الأوسمة.
   - **المصدر:** ملفات JSON للأصول أو جداول SQLite.
   - **طريقة الوصول:** كائن `LocalizedText` باستدعاء دالة `resolve(locale)`، لأنها كيانات بيانات ديناميكية مسندة من قاعدة البيانات أو الأصول وليست نصوصاً ثابتة بالواجهة.

```text
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           هيكلية استدعاء النصوص المعتمدة                        │
├──────────────────────────────────────┬──────────────────────────────────────────┤
│ نوع المحتوى                          │ الآلية المعتمدة                           │
├──────────────────────────────────────┼──────────────────────────────────────────┤
│ عناصر وتحكم الشاشات (UI Labels)     │ context.l10n.<key>                       │
│ رسائل الحوارات والتنبيهات (Dialogs)  │ context.l10n.<key>                       │
│ الصيغ المتغيرة والجموع (Plurals/ICU) │ context.l10n.<key>(param1, count)        │
│ محتوى الدروس والأصول المنهجية       │ entity.title.resolve(locale)             │
│ الأنماط الممنوعة كلياً               │ _localized(...), locale.languageCode==   │
└──────────────────────────────────────┴──────────────────────────────────────────┘
```

### ب. صياغة المفاتيح وقواعد ICU للجموع والمتغيرات

عند إضافة مفاتيح جديدة لملفات ARB:

1. **التسمية الجملية (camelCase):** تبدأ بحرف صغير مع وصف دقيق مسبوق بنطاق الشاشة (مثل: `workspaceFileCount`, `conceptMapRecallRate`).
2. **البيانات الوصفية (Metadata `@key`):** كتابة وصف واضح وتحديد أنواع المتغيرات (مثل `int`, `String`).
3. **التعامل مع صيغ الجمع:** استخدام صيغ ICU لضبط الجمع باللغتين العربية والإنجليزية:

```json
"workspaceIndexedFilesCount": "{count, plural, =0{لا توجد ملفات مفهرسة} =1{ملف واحد مفهرس} =2{ملفان مفهرسان} few{{count} ملفات مفهرسة} many{{count} ملفاً مفهرساً} other{{count} ملف مفهرس}}",
"@workspaceIndexedFilesCount": {
  "description": "Number of indexed files in the workspace",
  "placeholders": {
    "count": {"type": "int"}
  }
}
```

---

## 4. قاموس المفاتيح ونصوص ARB المستهدفة (Key Dictionary & Translations)

سيتم إضافة المفاتيح التالية لملفي `app_en.arb` و `app_ar.arb`:

### 1. نطاق مساحة العمل والمحرر (Workspace & IDE)

| اسم المفتاح (Key) | النص الإنجليزي (app_en.arb) | النص العربي (app_ar.arb) | الوصف والمعاملات |
| :--- | :--- | :--- | :--- |
| `workspaceIndexedFilesCount` | `{count, plural, =0{0 indexed files} =1{1 indexed file} other{{count} indexed files}}` | `{count, plural, =0{لا توجد ملفات} =1{ملف واحد مفهرس} =2{ملفان مفهرسان} few{{count} ملفات مفهرسة} many{{count} ملفاً مفهرساً} other{{count} ملف مفهرس}}` | عدد الملفات المفهرسة (`count: int`) |
| `workspaceSettings` | `Workspace settings` | `إعداد مساحة العمل` | زر إعدادات مساحة العمل |
| `workspaceReindex` | `Reindex` | `إعادة الفهرسة` | زر إعادة فهرسة الملفات |
| `workspaceEngineReady` | `GDScript engine ready` | `محرك GDScript جاهز` | حالة جاهزية المحرك |
| `workspaceEngineUnavailable` | `GDScript engine unavailable` | `محرك GDScript غير متاح` | حالة تعذر المحرك |
| `workspaceFilesTab` | `Files` | `الملفات` | تبويب شجرة الملفات |
| `workspaceSearchTab` | `Search` | `البحث` | تبويب البحث الشامل |
| `workspaceSearchProjectFiles` | `Search project files` | `بحث في ملفات المشروع` | نص تلميح حقل البحث |
| `workspaceMatchingFiles` | `Matching files` | `الملفات المطابقة` | عنوان نتائج البحث |
| `workspaceSaveFile` | `Save file` | `حفظ الملف` | تلميح زر حفظ الملف |
| `workspaceFileInfoTitle` | `File information` | `معلومات الملف` | عنوان حوار تفاصيل الملف |
| `workspaceNoFileOpen` | `No file is open` | `لا يوجد ملف مفتوح` | نص حالة عدم فتح ملف |
| `workspaceFileLinesCount` | `Lines: {count}` | `الأسطر: {count}` | عدد أسطر الملف (`count: int`) |
| `workspaceFileSizeCharacters` | `Size: {count} characters` | `الحجم: {count} محرف` | حجم الملف بالمحارف (`count: int`) |
| `workspaceOutputTab` | `Output` | `المخرجات` | تبويب لوحة المخرجات |
| `workspaceProblemsTab` | `Problems` | `المشكلات` | تبويب تشخيصات الكود |
| `workspaceCopyOutput` | `Copy output` | `نسخ المخرجات` | زر نسخ المخرجات |
| `workspaceClearOutput` | `Clear output` | `مسح المخرجات` | زر مسح المخرجات |
| `workspaceEngineStatusReady` | `Ready` | `جاهز` | شارة الحالة جاهز |
| `workspaceEngineStatusUnavailable` | `Unavailable` | `غير متاح` | شارة الحالة غير متاح |
| `workspaceExecutionRunning` | `Running...` | `جارٍ التنفيذ...` | حالة جاري تشغيل الكود |
| `workspaceEmptyOutput` | `No output yet. Run the script to see results.` | `لا توجد مخرجات بعد. شغّل السكربت لعرضها.` | حالة المخرجات الفارغة |
| `workspaceNoProblems` | `No problems found for open file.` | `لا توجد مشكلات للملف المفتوح.` | حالة عدم وجود أخطاء بالكود |
| `workspaceSearchFilterPlaceholder` | `Search for a file or script...` | `ابحث عن ملف أو سكربت...` | تلميح حقل تصفية الملفات |
| `workspaceStatusBarCoordinates` | `Ln {line}, Col {column}` | `السطر {line}، العمود {column}` | إحداثيات المؤشر (`line: int, column: int`) |
| `workspaceUnsavedChangesWarning` | `There are unsaved changes. Do you want to close and discard them?` | `هناك تعديلات غير محفوظة. هل تريد إغلاق الملف والتخلص منها؟` | حوار تأكيد إغلاق الملف |
| `workspaceDirectInspectAction` | `Direct analysis and editing inside the app` | `تحليل وتحرير مباشر داخل التطبيق` | وصف ميزة مساحة العمل |

### 2. نطاق خريطة المفاهيم ونظام التكرار المتباعد (Concept Map & SM-2)

| اسم المفتاح (Key) | النص الإنجليزي (app_en.arb) | النص العربي (app_ar.arb) | الوصف والمعاملات |
| :--- | :--- | :--- | :--- |
| `conceptMapHeroTitle` | `Concept Map & SM-2 Spaced Repetition` | `خريطة المفاهيم وخوارزمية التكرار المتباعد SM-2` | العنوان الرئيسي للخريطة |
| `conceptMapHeroSubtitle` | `Track your progress through the knowledge tree and strengthen memory with spaced repetition.` | `تتبع تقدمك في شجرة المعرفة وثبّت المفاهيم البرمجية في الذاكرة طويلة المدى.` | الوصف الإرشادي للخريطة |
| `conceptMapQuickReviewSession` | `Quick Review Session` | `جلسة مراجعة سريعة` | عنوان بطاقة المراجعة |
| `conceptMapRecallRate` | `Recall: {rate}%` | `معدل الاسترجاع: {rate}%` | نسبة استرجاع الذاكرة (`rate: int`) |
| `conceptMapDueCardsToday` | `{count, plural, =0{No cards due today} =1{1 card due today} other{{count} cards due today}}` | `{count, plural, =0{لا توجد بطاقات مستحقة اليوم} =1{بطاقة واحدة مستحقة اليوم} =2{بطاقتان مستحقتان اليوم} few{{count} بطاقات مستحقة اليوم} many{{count} بطاقة مستحقة اليوم} other{{count} بطاقة مستحقة اليوم}}` | عدد البطاقات المستحقة |
| `conceptMapStartReviewAction` | `Start review now` | `بدء المراجعة الآن` | زر إطلاق المراجعة |
| `conceptMapBackToMap` | `Back to map` | `العودة للخريطة` | زر العودة لشجرة المفاهيم |
| `conceptMapDueTodayBadge` | `Due today` | `مستحق اليوم` | شارة بطاقة مستحقة |
| `conceptMapRemainingCards` | `Remaining cards: {count}` | `البطاقات المتبقية: {count}` | عداد البطاقات المتبقية (`count: int`) |
| `conceptMapSm2RatingAgain` | `Again` | `إعادة` | تقييم SM-2: إعادة |
| `conceptMapSm2RatingHard` | `Hard` | `صعب` | تقييم SM-2: صعب |
| `conceptMapSm2RatingGood` | `Good` | `جيد` | تقييم SM-2: جيد |
| `conceptMapSm2RatingEasy` | `Easy` | `سهل` | تقييم SM-2: سهل |
| `conceptMapRevealAnswer` | `Reveal answer` | `كشف الإجابة` | زر إظهار جواب البطاقة |
| `conceptMapOverviewHeading` | `Concept overview:` | `شرح المفهوم:` | عنوان قسم شرح المفهوم |
| `conceptMapCodeExampleHeading` | `Code example:` | `مثال برمجي:` | عنوان قسم الكود التوضيحي |
| `conceptMapStatusHeading` | `Concept status` | `حالة المفهوم` | ترويسة حالة المفهوم |
| `conceptMapLastReviewedDate` | `Last reviewed: {date}` | `آخر مراجعة: {date}` | تاريخ آخر مراجعة (`date: String`) |
| `conceptMasteryLocked` | `Locked` | `مقفل` | حالة الإتقان: مقفل |
| `conceptMasteryLearning` | `Learning` | `قيد التعلم` | حالة الإتقان: قيد التعلم |
| `conceptMasteryReviewing` | `Reviewing` | `قيد المراجعة` | حالة الإتقان: قيد المراجعة |
| `conceptMasteryMastered` | `Mastered` | `متقن` | حالة الإتقان: متقن |
| `conceptMapEmptyState` | `No concepts are available yet.` | `لا توجد مفاهيم متاحة حالياً.` | حالة الخريطة الفارغة |
| `conceptMapRetryAction` | `Retry` | `إعادة المحاولة` | زر إعادة محاولة التحميل |

### 3. نطاق تفضيلات النظام وإعدادات سطح المكتب (Desktop Settings)

| اسم المفتاح (Key) | النص الإنجليزي (app_en.arb) | النص العربي (app_ar.arb) | الوصف والمعاملات |
| :--- | :--- | :--- | :--- |
| `settingsSavedSuccessToast` | `All preferences saved successfully and synced with Godot 4.3 ✓` | `تم حفظ كافة التفضيلات بنجاح وتمت مزامنتها مع محرك Godot 4.3 ✓` | إشعار نجاح حفظ التفضيلات |
| `settingsPreferencesSections` | `Preference sections` | `أقسام التفضيلات` | ترويسة أقسام الإعدادات |
| `settingsTabCodeEditor` | `Code editor & fonts` | `محرر الأكواد والخطوط` | تبويب إعدادات المحرر |
| `settingsTabLspEngine` | `LSP server & engine path` | `خادم LSP ومسار المحرك` | تبويب خادم اللغة |
| `settingsTabAppearanceTheme` | `Appearance & visual theme` | `المظهر والسمة البصرية` | تبويب سمات المظهر |
| `settingsTabAccountAcademic` | `Account & learning progress` | `الحساب والمسار الأكاديمي` | تبويب الحساب والمسار |
| `settingsDesktopTitle` | `Desktop Settings & Engine Environment` | `الإعدادات وتفضيلات النظام وبيئة المحرك` | ترويسة الشاشة الكبيرة |
| `settingsSaveShortcutAction` | `Save changes (Ctrl+S) ↵` | `حفظ التغييرات (Ctrl+S) ↵` | زر حفظ الإعدادات |
| `settingsEditorPrefsTitle` | `GDScript Editor Preferences` | `تفضيلات محرر الكود (GDScript Editor)` | ترويسة محرر الأكواد |
| `settingsEditorPrefsSubtitle` | `Customize font size, tab spacing, and auto-completion behavior.` | `تخصيص مقاس الخط، التباعد، وسلوك الإكمال التلقائي في بيئة التطوير.` | وصف محرر الأكواد |
| `settingsEditorFontSize` | `Editor font size ({size} px):` | `مقاس خط المحرر البرمجي ({size} px):` | مقاس الخط (`size: int`) |
| `settingsEditorFontSizeHint` | `Applied to the JetBrains Mono font dedicated to GDScript.` | `يتم تطبيق المقاس على خط JetBrains Mono المخصص لكتابة GDScript.` | تلميح الخط البرمجي |
| `settingsEditorTabSize` | `Tab size:` | `مسافة الإزاحة (Tab Size):` | عنوان المسافة البادئة |
| `settingsEditorTabSizeStandard` | `The official standard in GDScript 2.0 is 4 spaces.` | `المعيار الرسمي في GDScript 2.0 هو 4 مسافات مسافية.` | المعيار الموصى به |
| `settingsTabSpacesCount` | `{count, plural, =1{1 space} other{{count} spaces}}` | `{count, plural, =1{مسافة واحدة} =2{مسافتان} few{{count} مسافات} other{{count} مسافة}}` | خيارات المسافات في القائمة |
| `settingsTabSpacesRecommended` | `4 spaces (Recommended)` | `4 مسافات (موصى به)` | خيار 4 مسافات المعتمد |
| `settingsShowLineNumbersTitle` | `Show line numbers` | `إظهار أرقام الأسطر (Line Numbers)` | خيار إظهار الأرقام |
| `settingsShowLineNumbersSubtitle` | `Display line numbers column for easier tracing and diagnostics.` | `عرض عمود الأرقام على يمين المحرر لسهولة التتبع والتشخيص.` | وصف أرقام الأسطر |
| `settingsHighlightActiveLineTitle` | `Highlight active line` | `إبراز السطر النشط (Highlight Active Line)` | خيار تظليل السطر |
| `settingsHighlightActiveLineSubtitle` | `Highlight the background of the line where cursor is placed.` | `تظليل خلفية السطر الذي يقف عليه المؤشر بلون مغاير.` | وصف تظليل السطر |
| `settingsAutoCloseBracketsTitle` | `Auto-close brackets and quotes` | `إغلاق الأقواس وعلامات التنصيص تلقائياً` | الإغلاق التلقائي |
| `settingsAutoCloseBracketsSubtitle` | `Automatically complete (), [], {}, and "" as you type.` | `إكمال الأقواس () و [] و {} وعلامات "" فور كتابتها.` | وصف الإغلاق التلقائي |
| `settingsLspSectionTitle` | `Language Server Protocol & Godot 4.3` | `خادم اللغة LSP ومحرك Godot 4.3` | ترويسة إعدادات LSP |
| `settingsLspSectionSubtitle` | `Manage local connection bridge, engine paths, and JSON-RPC 2.0.` | `إدارة جسر الاتصال المحلي ومسارات تشغيل المحرك وبروتوكول JSON-RPC 2.0.` | وصف إعدادات LSP |
| `settingsOpenDiagnosticsLog` | `Open live diagnostics log ↵` | `فتح سجل التشخيصات المباشر ↵` | زر فتح التشخيصات |
| `settingsGodotExecutablePath` | `Godot executable path:` | `مسار المحرك التنفيذي (Godot Executable Path):` | حقل مسار ملف Godot |
| `settingsLspPort` | `LSP connection port:` | `منفذ الاتصال المحلي (LSP Port):` | حقل منفذ خادم اللغة |
| `settingsStrictTypingTitle` | `Enforce strict typing warnings` | `فرض تحذيرات الأنواع غير الصارمة (Strict Typing)` | خيار النوع الصارم |
| `settingsStrictTypingSubtitle` | `Raise instant warnings when dynamic Variant variables lack explicit type.` | `إطلاق تحذيرات فورية عند كتابة متغيرات Variant ديناميكية بدون تصريح نوع صريح.` | وصف النوع الصارم |
| `settingsAutoStartLspTitle` | `Automatically start LSP server on launch` | `بدء تشغيل خادم LSP تلقائياً عند فتح الأكاديمية` | خيار التشغيل التلقائي |
| `settingsAutoStartLspSubtitle` | `Initialize and launch local bridge in background upon application start.` | `تهيئة وإطلاق جسر الاتصال في الخلفية بمجرد تشغيل الواجهة.` | وصف التشغيل التلقائي |
| `settingsAppearanceSectionTitle` | `Appearance & Visual Theme` | `المظهر والسمة البصرية` | ترويسة مظهر الواجهة |
| `settingsAppearanceSectionSubtitle` | `Customize color schemes to match official Godot editor interface.` | `تخصيص نسق الألوان بما يطابق واجهة محرك Godot الرسمية وتفضيلات شاشتك.` | وصف المظهر |
| `settingsActiveThemeLabel` | `Active theme:` | `السمة النشطة:` | تسمية السمة الحالية |
| `settingsDarkThemeGodotDesc` | `Dark theme with official Godot blue and dark grey tones #0F141B.` | `الوضع الداكن المعتمد بدرجات الأزرق والرمادي الداكن #0F141B.` | وصف السمة المعتمدة |
| `settingsArabicFontTitle` | `Arabic UI font:` | `خط الواجهة العربي:` | تسمية خط الواجهة |
| `settingsArabicFontSubtitle` | `High-clarity accredited font for technical software interfaces.` | `خط معتمد عالي الوضوح للغة العربية في البرمجيات التقنية.` | وصف خط IBM Plex |

### 4. نطاق مسار التعلم ولوحة الإتقان (Learning Path)

| اسم المفتاح (Key) | النص الإنجليزي (app_en.arb) | النص العربي (app_ar.arb) | الوصف والمعاملات |
| :--- | :--- | :--- | :--- |
| `learningPathAcademyBrand` | `Godot Academy` | `أكاديمية جودو` | شارة العلامة التعليمية |
| `learningPathCurriculumYear` | `2025 Curriculum` | `منهج 2025` | شارة إصدار المنهج |
| `learningPathCourseTab` | `Course Path` | `مسار المنهج` | تبويب مسار المنهج |
| `learningPathConceptMapTab` | `Concept Map` | `خريطة المفاهيم` | تبويب خريطة المفاهيم |
| `learningPathSmartReviewTab` | `Smart Review` | `مراجعة ذكية` | تبويب المراجعة الذكية |
| `learningPathNoLessonsYet` | `No lessons have been added to this path yet.` | `لا توجد دروس مضافة إلى هذا المسار بعد.` | نص المسار الفارغ |
| `learningPathStageFundamentals` | `Fundamentals` | `الأساسيات` | مرحلة الأساسيات |
| `learningPathStageJourneyStart` | `Start of the journey` | `بداية الرحلة` | وصف مرحلة الأساسيات |
| `learningPathStageLogicMaker` | `Logic Maker` | `صانع المنطق` | مرحلة صانع المنطق |
| `learningPathStageNextPhase` | `Next phase` | `المرحلة التالية` | وصف مرحلة المنطق |
| `learningPathStageEngineExpert` | `Engine Expert` | `خبير المحرك` | مرحلة خبير المحرك |
| `learningPathStageAdvancedPhase` | `Advanced phase` | `المرحلة المتقدمة` | وصف المرحلة المتقدمة |
| `learningPathUnitStatusDone` | `Completed` | `مكتملة` | شارة وحدة مكتملة |
| `learningPathUnitStatusCurrent` | `Current unit` | `الوحدة الحالية` | شارة الوحدة الحالية |
| `learningPathUnitStatusLocked` | `Locked` | `مغلقة` | شارة وحدة مغلقة |
| `learningPathCompletePrevious` | `Complete previous unit first` | `أكمل الوحدة السابقة` | تنبيه المتطلب السابق |
| `learningPathHideLessons` | `Hide lessons` | `إخفاء الدروس` | زر طي قائمة الدروس |
| `learningPathShowLessonsAction` | `Show lessons` | `عرض الدروس` | زر بسط قائمة الدروس |
| `learningPathLessonStatusDone` | `Completed` | `تم الإنجاز` | حالة الدرس: تم الإنجاز |
| `learningPathLessonStatusCurrent` | `Current lesson` | `الدرس الحالي` | حالة الدرس: الدرس الحالي |
| `learningPathLessonStatusSoon` | `Coming soon` | `قريباً` | حالة الدرس: قريباً |
| `learningPathMasteryDashboard` | `Mastery Dashboard & Statistics` | `لوحة الإتقان والإحصائيات` | عنوان لوحة الإحصائيات |

### 5. نطاق الشاشة الرئيسية ولوحة القيادة (Home Dashboard)

| اسم المفتاح (Key) | النص الإنجليزي (app_en.arb) | النص العربي (app_ar.arb) | الوصف والمعاملات |
| :--- | :--- | :--- | :--- |
| `dashboardDailyChallengeTitle` | `Daily Speed Challenge` | `تحدي اليوم السريع` | ترويسة بطاقة التحدي |
| `dashboardChallengeParticipants` | `{count, plural, =1{1 developer participated today} other{{count} developers participated today}}` | `{count, plural, =1{شارك مطور واحد اليوم} =2{شارك مطوران اليوم} few{شارك {count} مطورين اليوم} many{شارك {count} مطوراً اليوم} other{شارك {count} مطور اليوم}}` | عدد المشاركين بالتحدي |
| `dashboardChallengeStartAction` | `Take challenge (+{xp} XP)` | `خوض التحدي (+{xp} XP)` | زر خوض التحدي (`xp: int`) |
| `dashboardSmartReviewCardTitle` | `Smart Spaced Review (SM-2)` | `المراجعة الذكية (SM-2)` | ترويسة بطاقة المراجعة |
| `dashboardSmartReviewCardBody` | `You have {count} concept cards due for review today to consolidate long-term memory.` | `لديك {count} بطاقات مفاهيم مستحقة للمراجعة اليوم لتثبيت الذاكرة طويلة المدى.` | وصف بطاقة المراجعة (`count: int`) |
| `dashboardSmartReviewRetention` | `Recall rate {percent}%` | `معدل الاسترجاع {percent}%` | نسبة الاسترجاع (`percent: int`) |
| `dashboardSmartReviewDuration` | `~{minutes} mins` | `~{minutes} دقائق` | الوقت التقديري (`minutes: int`) |
| `dashboardStartQuickReview` | `Start quick review session` | `بدء جلسة المراجعة السريعة` | زر بدء المراجعة |
| `dashboardCodingStatsTitle` | `Your Programming Statistics` | `إحصائياتك البرمجية` | ترويسة إحصائيات المبرمج |
| `dashboardViewBadgesAction` | `Badges ↵` | `الأوسمة ↵` | رابط الانتقال للأوسمة |
| `dashboardStatsLinesWritten` | `GDScript lines written:` | `أسطر كود GDScript مكتوبة:` | تسمية أسطر الكود |
| `dashboardStatsLinesCount` | `{count, plural, =1{1 line} other{{count} lines}}` | `{count, plural, =1{سطر واحد} =2{سطران} few{{count} أسطر} many{{count} سطراً} other{{count} سطر}}` | عداد الأسطر |
| `dashboardStatsChallengesPassed` | `Challenges completed:` | `تحديات برمجية تم اجتيازها:` | تسمية التحديات المنجزة |
| `dashboardStatsChallengesCount` | `{count, plural, =1{1 challenge} other{{count} challenges}}` | `{count, plural, =1{تحدٍّ واحد} =2{تحديان} few{{count} تحديات} many{{count} تحدياً} other{{count} تحدٍّ}}` | عداد التحديات |
| `dashboardStatsBadgesEarned` | `Accredited badges earned:` | `أوسمة مكتسبة معتمدة:` | تسمية الأوسمة المكتسبة |
| `dashboardStatsBadgesRatio` | `{earned} of {total} badges` | `{earned} من {total} أوسمة` | نسبة الأوسمة (`earned: int, total: int`) |

### 6. نطاق قراءة الدرس والحاويات التوجيهية (Lesson Viewer & Callouts)

| اسم المفتاح (Key) | النص الإنجليزي (app_en.arb) | النص العربي (app_ar.arb) | الوصف والمعاملات |
| :--- | :--- | :--- | :--- |
| `calloutOfficialWarning` | `Official Warning` | `تحذير رسمي` | عنوان حاوية التحذير من المخاطر |
| `calloutBestPractice` | `Best Practice` | `توصية وممارسة فضلى` | عنوان حاوية أفضل الممارسات |
| `calloutTechnicalNote` | `Technical Note` | `معلومة هندسية` | عنوان حاوية الملاحظة الهندسية |
| `calloutGoldenRule` | `Golden Rule` | `القاعدة الذهبية` | عنوان حاوية القاعدة الذهبية |
| `lessonDocumentationHeader` | `Lesson documentation` | `توثيق الدرس` | ترويسة قسم التوثيق بالدرس |
| `lessonDocumentationSources` | `Sources` | `المصادر` | ترويسة مصادر التوثيق |
| `lessonDocumentationLicenseNotice` | `Based on Godot Engine Documentation, licensed under CC BY 3.0. This educational text is an independent adaptation and is not endorsed by Godot.` | `يستند هذا المحتوى إلى توثيق Godot Engine المرخّص بموجب CC BY 3.0. هذا إعداد تعليمي مستقل وليس معتمداً من Godot.` | بيان الترخيص والحقوق |
| `lessonSplitterDragTooltip` | `Drag to resize panes` | `اسحب لتغيير عرض اللوحتين` | تلميح مقبض تقسيم المحرر |

### 7. نطاق شاشات المراجعة، المشاريع، والودجات المشتركة

| اسم المفتاح (Key) | النص الإنجليزي (app_en.arb) | النص العربي (app_ar.arb) | الوصف والمعاملات |
| :--- | :--- | :--- | :--- |
| `reviewScreenTitle` | `Smart Review` | `المراجعة الذكية` | عنوان شاشة المراجعة |
| `reviewScreenTodayHeader` | `Today's Review` | `استعراض اليوم` | ترويسة بطاقات اليوم |
| `reviewDueItemsCount` | `{count, plural, =0{No due items} =1{1 due item} other{{count} due items}}` | `{count, plural, =0{لا توجد عناصر مستحقة} =1{عنصر واحد مستحق} =2{عنصران مستحقان} few{{count} عناصر مستحقة} many{{count} عنصراً مستحقاً} other{{count} عنصر مستحق}}` | عدد العناصر المستحقة |
| `reviewEmptyStateMessage` | `No reviews due today. Check back later.` | `لا توجد مراجعات مستحقة اليوم. عد لاحقاً.` | رسالة فراغ المراجعات |
| `reviewIntervalDays` | `Interval: {days} days` | `فاصل {days} يوم` | فترة التباعد بالأيام (`days: int`) |
| `reviewLessonReference` | `Lesson: {lessonId}` | `درس: {lessonId}` | رمز الدرس المرتبط |
| `reviewCardUpdatedNotice` | `Updated {title} → {date}` | `تم تحديث {title} → {date}` | إشعار نجاح جدولة البطاقة |
| `capstoneScreenTitle` | `Integrated Capstone Project` | `مشروع التطوير التكاملي` | عنوان شاشة المشروع الختامي |
| `exerciseActionCheckAnswer` | `Check answer` | `تحقق من الإجابة` | زر التحقق من حل التمرين |
| `exerciseActionRun` | `Run code` | `تشغيل الكود` | زر تشغيل كود التمرين |

---

## 5. خطة المراحل التنفيذية المتسلسلة (Phased Execution Roadmap)

تعتمد الخطة على **8 مراحل متتابعة** تُنفذ دون انقطاع، مع ضمان استقرار الاختبارات والتوليد الآلي لكود التعريب في كل مرحلة:

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                       مخطط سير مراحل التنفيذ المتتابعة                       │
└─────────────────────────────────────────────────────────────────────────────┘
  [المرحلة 0]  إثراء ملفات ARB (app_ar.arb و app_en.arb) وتشغيل flutter gen-l10n
      │
      ▼
  [المرحلة 1]  تعريب شاشات مساحة العمل وحذف دالة _localized
      │
      ▼
  [المرحلة 2]  تعريب خريطة المفاهيم ونظام SM-2 وحذف دالة _conceptMapCopy
      │
      ▼
  [المرحلة 3]  تعريب تفضيلات بيئة العمل ومحرر الأكواد (Desktop Settings)
      │
      ▼
  [المرحلة 4]  تعريب مسار التعلّم ولوحة الإتقان (Learning Path)
      │
      ▼
  [المرحلة 5]  تعريب لوحة التحكم الرئيسية (Home Dashboard)
      │
      ▼
  [المرحلة 6]  تعريب حاويات قراءة الدروس وتوثيق Godot (Lesson Callouts)
      │
      ▼
  [المرحلة 7]  تعريب شاشات المراجعة، المشاريع الختامية، والودجات المشتركة
      │
      ▼
  [المرحلة 8]  الفحص الشامل، التحليل الثابت (dart analyze)، واختبارات الودجات
```

---

### المرحلة 0: إثراء قاموس الترجمة ARB وتوليد كود Flutter المترجم (✅ مكتملة)

- **الهدف:** إضافة جميع المفاتيح المذكورة في [قسم قاموس المفاتيح](#4-قاموس-المفاتيح-ونصوص-arb-المستهدفة-key-dictionary--translations) إلى ملف `lib/l10n/app_en.arb` وملف `lib/l10n/app_ar.arb`.
- **حالة التنفيذ:** ✅ مكتملة بالكامل.
- **التنفيذ:**
  1. [x] كتابة كافة الإدخالات باللغة الإنجليزية في `app_en.arb` مع الـ Placeholders والـ Descriptions (تم الوصول إلى 502 مفتاح).
  2. [x] كتابة كافة المقابلات باللغة العربية في `app_ar.arb` مع معالجة صيغ ICU وتجنب الأقواس الخام غير المفرغة.
  3. [x] تنفيذ أمر التوليد بنجاح:

     ```bash
     /home/osm/.development/flutter/bin/flutter gen-l10n
     ```

  4. [x] التحقق من توليد الخصائص الجديدة داخل `lib/l10n/app_localizations.dart` و `app_localizations_ar.dart` و `app_localizations_en.dart`.

---

### المرحلة 1: شاشات مساحة العمل ومحرر المشاريع (Workspace & IDE) (✅ مكتملة)

- **الملفات المستهدفة:**
  - [`lib/ui/screens/workspace/workspace_projects_ide_flutter_dart.dart`](file:///home/osm/flutter_projects/learn_gdscript/lib/ui/screens/workspace/workspace_projects_ide_flutter_dart.dart)
  - [`lib/ui/screens/workspace/workspace_screen.dart`](file:///home/osm/flutter_projects/learn_gdscript/lib/ui/screens/workspace/workspace_screen.dart)
- **حالة التنفيذ:** ✅ مكتملة بالكامل مع اجتياز الفحص والتحليل والاختبارات بنجاح.
- **خطوات التنفيذ:**
  1. [x] حذف تعريف دالة `_localized` كلياً من `workspace_projects_ide_flutter_dart.dart`.
  2. [x] استبدال كافة استدعاءات `_localized(context, '...', '...')` البالغ عددها 29 استدعاءً بخصائص `context.l10n.<keyName>`.
  3. [x] استبدال دمج الأرقام اليدوي باستدعاء دالة الجمع: `context.l10n.workspaceIndexedFilesCount(_countFiles(data.fileTree))`.
  4. [x] استبدال إحداثيات السطر والعمود بالصيغة القياسية: `context.l10n.workspaceStatusBarCoordinates(cursorLine, cursorCol)`.
  5. [x] تنظيف `workspace_screen.dart` من شرطيات `languageCode == 'ar'` واستبدالها بمفاتيح `workspaceUnsavedChangesWarning` و `workspaceDirectInspectAction` و `openWorkspace`.
  6. [x] تشغيل التحليل الثابت واختبارات الودجات واجتيازها جميعاً بدون أخطاء.

---

### المرحلة 2: خريطة المفاهيم ونظام التكرار المتباعد (Concept Map & SM-2)

- **الملفات المستهدفة:**
  - [`lib/ui/screens/concept_map/desktop_concept_map_sm_2_flutter_dart.dart`](file:///home/osm/flutter_projects/learn_gdscript/lib/ui/screens/concept_map/desktop_concept_map_sm_2_flutter_dart.dart)
  - [`lib/ui/screens/concept_map/concept_map_screen.dart`](file:///home/osm/flutter_projects/learn_gdscript/lib/ui/screens/concept_map/concept_map_screen.dart)
  - [`test/ui/concept_map_screen_test.dart`](file:///home/osm/flutter_projects/learn_gdscript/test/ui/concept_map_screen_test.dart)
- **خطوات التنفيذ:**
  1. حذف دالة `_conceptMapCopy` من السطر 1575 في `desktop_concept_map_sm_2_flutter_dart.dart`.
  2. حذف دالة `_conceptMapText` من السطر 345 في `concept_map_screen.dart`.
  3. استبدال الـ 26 استدعاءً في `desktop_concept_map_sm_2_flutter_dart.dart` بـ `context.l10n`.
  4. إعادة كتابة دالة `_masteryLabel` لترجع القيمة المترجمة مباشرة من `context.l10n`:

     ```dart
     String _masteryLabel(BuildContext context, ConceptMasteryLevel mastery) =>
         switch (mastery) {
           ConceptMasteryLevel.locked => context.l10n.conceptMasteryLocked,
           ConceptMasteryLevel.learning => context.l10n.conceptMasteryLearning,
           ConceptMasteryLevel.reviewing => context.l10n.conceptMasteryReviewing,
           ConceptMasteryLevel.mastered => context.l10n.conceptMasteryMastered,
         };
     ```

  5. مواءمة اختبار `test/ui/concept_map_screen_test.dart` ليتطابق مع المفاتيح المترجمة الصادرة من `l10n`.

---

### المرحلة 3: شاشة التفضيلات وبيئة المحرك (Desktop Settings)

- **الملفات المستهدفة:**
  - [`lib/ui/screens/settings/desktop_settings_flutter_dart.dart`](file:///home/osm/flutter_projects/learn_gdscript/lib/ui/screens/settings/desktop_settings_flutter_dart.dart)
  - [`lib/ui/screens/settings/settings_screen.dart`](file:///home/osm/flutter_projects/learn_gdscript/lib/ui/screens/settings/settings_screen.dart)
- **خطوات التنفيذ:**
  1. استبدال الـ 48 سطراً التي تحتوي على نصوص عربية صلبة في `desktop_settings_flutter_dart.dart` باستدعاءات `context.l10n`.
  2. استبدال عناصر القائمة المنسدلة لمسافات الإزاحة (DropdownMenuItems) لتستدعي `context.l10n.settingsTabSpacesCount(2)` و `context.l10n.settingsTabSpacesRecommended` و `context.l10n.settingsTabSpacesCount(8)`.
  3. ربط نصوص رسالة إشعار الحفظ برمز المفتاح `settingsSavedSuccessToast`.
  4. تنظيف تبديل اللغة في `settings_screen.dart` ليعتمد على الترجمة الرسمية لاسم اللغة.

---

### المرحلة 4: مسار التعلّم ولوحة الإتقان (Learning Path)

- **الملفات المستهدفة:**
  - [`lib/ui/screens/learning_path/desktop_learning_path_flutter_dart.dart`](file:///home/osm/flutter_projects/learn_gdscript/lib/ui/screens/learning_path/desktop_learning_path_flutter_dart.dart)
  - [`lib/ui/screens/learning_path/learning_path_screen.dart`](file:///home/osm/flutter_projects/learn_gdscript/lib/ui/screens/learning_path/learning_path_screen.dart)
- **خطوات التنفيذ:**
  1. استبدال نصوص شارات المراحل والوحدات: 'الأساسيات'، 'صانع المنطق'، 'خبير المحرك'، 'مكتملة'، 'الوحدة الحالية'، 'مغلقة' بمفاتيح `l10n`.
  2. استبدال زر طي وبسط الدروس: `isExpanded ? context.l10n.learningPathHideLessons : context.l10n.learningPathShowLessonsAction`.
  3. استبدال شارة الأيام المتتالية وزر الدرس التالي في `learning_path_screen.dart` بمفاتيح `context.l10n.dashboardStreak` و `context.l10n.nextLesson`.

---

### المرحلة 5: لوحة التحكم والشاشة الرئيسية (Home Dashboard)

- **الملفات المستهدفة:**
  - [`lib/ui/screens/home/desktop_home_dashboard.dart`](file:///home/osm/flutter_projects/learn_gdscript/lib/ui/screens/home/desktop_home_dashboard.dart)
  - [`lib/ui/screens/home/home_screen.dart`](file:///home/osm/flutter_projects/learn_gdscript/lib/ui/screens/home/home_screen.dart)
  - [`test/widget_test.dart`](file:///home/osm/flutter_projects/learn_gdscript/test/widget_test.dart)
- **خطوات التنفيذ:**
  1. استبدال نصوص بطاقة التحدي السريع في السطور 1076-1165 بخصائص `context.l10n`.
  2. استبدال نصوص بطاقة المراجعة الذكية SM-2 في السطور 1206-1271 بخصائص `context.l10n`.
  3. استبدال عناوين الإحصائيات البرمجية في السطور 1320-1360 بخصائص `context.l10n`.
  4. إزالة الشرطيات `locale.languageCode == 'ar' ? 'متعلّم' : 'Learner'` من `home_screen.dart` وتوحيدها عبر `context.l10n.dashboardWelcomeBack`.
  5. التأكد من نجاح اختبار تخطيط الشاشة الإنجليزية `testWidgets('home dashboard fits narrow and wide English layouts')` في `widget_test.dart`.

---

### المرحلة 6: شاشات وعناصر قراءة الدرس (Lesson Viewer & Callouts)

- **الملفات المستهدفة:**
  - [`lib/ui/screens/lesson/widgets/lesson_callout_card.dart`](file:///home/osm/flutter_projects/learn_gdscript/lib/ui/screens/lesson/widgets/lesson_callout_card.dart)
  - [`lib/ui/screens/lesson/lesson_documentation_section.dart`](file:///home/osm/flutter_projects/learn_gdscript/lib/ui/screens/lesson/lesson_documentation_section.dart)
  - [`lib/ui/screens/lesson/desktop_lesson_ide_flutter_dart.dart`](file:///home/osm/flutter_projects/learn_gdscript/lib/ui/screens/lesson/desktop_lesson_ide_flutter_dart.dart)
- **خطوات التنفيذ:**
  1. تحديث دالة استخراج عناوين الحاويات في `lesson_callout_card.dart` لاستدعاء `context.l10n` بدلاً من الشرطية `isEnglish ? ... : ...`:
     - `CalloutType.warning`: `context.l10n.calloutOfficialWarning`
     - `CalloutType.tip`: `context.l10n.calloutBestPractice`
     - `CalloutType.note`: `context.l10n.calloutTechnicalNote`
     - `CalloutType.goldenRule`: `context.l10n.calloutGoldenRule`
  2. تعريب نصوص `lesson_documentation_section.dart` عبر `context.l10n.lessonDocumentationHeader` و `context.l10n.lessonDocumentationSources` و `context.l10n.lessonDocumentationLicenseNotice`.
  3. تعريب تلميح مقبض التقسيم وحالة المحرك في `desktop_lesson_ide_flutter_dart.dart`.

---

### المرحلة 7: شاشات المراجعة، المشاريع الختامية، والودجات المشتركة

- **الملفات المستهدفة:**
  - [`lib/ui/screens/review/review_screen.dart`](file:///home/osm/flutter_projects/learn_gdscript/lib/ui/screens/review/review_screen.dart)
  - [`lib/ui/screens/capstone/capstone_screen.dart`](file:///home/osm/flutter_projects/learn_gdscript/lib/ui/screens/capstone/capstone_screen.dart)
  - [`lib/ui/widgets/exercise/exercise_widget.dart`](file:///home/osm/flutter_projects/learn_gdscript/lib/ui/widgets/exercise/exercise_widget.dart)
  - [`lib/ui/widgets/code_editor/code_editor_widget.dart`](file:///home/osm/flutter_projects/learn_gdscript/lib/ui/widgets/code_editor/code_editor_widget.dart)
- **خطوات التنفيذ:**
  1. استبدال كافة النصوص الصلبة في `review_screen.dart` بـ `context.l10n`.
  2. استبدال عنوان شاشة المشروع التكاملي وأسماء مراحله في `capstone_screen.dart`.
  3. استبدال شرطية زر "تحقق من الإجابة" في `exercise_widget.dart` بـ `context.l10n.exerciseActionCheckAnswer`.
  4. استبدال نص رسالة خطأ المحرر الافتراضية في `code_editor_widget.dart` بمفتاح معتمد.

---

### المرحلة 8: الفحص الشامل، التحليل الثابت، واختبارات الودجات

- **التحليل الثابت:**
  تشغيل فاحص دارت للتأكد من انعدام أي تحذيرات أو أخطاء استيراد:

  ```bash
  /home/osm/.development/flutter/bin/dart analyze
  ```

- **حزمة الاختبارات الآلية:**
  تشغيل اختبارات واجهة المستخدم للتأكد من خلو المشروع من أي انحدار (Regression):

  ```bash
  /home/osm/.development/flutter/bin/flutter test test/ui/
  /home/osm/.development/flutter/bin/flutter test test/widget_test.dart
  ```

---

## 6. آليات منع الانحدار والفحص الآلي (Regression Guard & Linting)

لمنع عودة كتابة نصوص صلبة أو إنشاء دوال مساعدة التفافية مستقبلاً، يتم اعتماد آليتين رقابيتين:

### أ. سكريبت الفحص الآلي المستمر (`tool/check_ui_localization.dart`)

سكريبت خفيف يتم تضمينه في دورة التطوير والـ CI للتحقق من خلو مجلد `lib/ui/` من:

1. أي دوال تبدأ بـ `_localized` أو `_copy` أو `_text` تستقبل نصوصاً عربية وإنجليزية.
2. أي استعلامات `languageCode == 'ar'` أو `languageCode == 'en'` داخل ملفات الودجات لاختيار نصوص واجهة مستخدم.
3. التنبيه عند وجود نصوص عربية مباشرة خارج تعليقات الأكواد وبطاقات الماركداون.

### ب. اختبارات توافق اللغات الثنائية (Bilingual Layout Testing)

إلزام كل اختبار شاشة باختبار حالتي `Locale('ar')` و `Locale('en')` والتحقق من أن النصوص المعروضة مستمدة من `AppLocalizations` بدقة دون حدوث أي تجاوز في المساحات (RenderFlex Overflow).

---

## 7. معايير القبول والاعتماد (Definition of Done)

تعتبر خطة تحسينات الشاشات مكتملة ومعتمدة عند تحقيق المعايير التالية بنسبة 100%:

- [ ] **صفر دوال التفافية:** حذف تام لجميع دوال `_localized` و `_conceptMapCopy` و `_conceptMapText` في المشروع بالكامل.
- [ ] **صفر شرطيات لغة للنصوص:** عدم وجود أي فحص شرطي لـ `languageCode` لغرض اختيار نص واجهة.
- [ ] **اكتمال ملفات ARB:** تطابق تام بين مفاتيح `app_ar.arb` ومفاتيح `app_en.arb` مع توثيق وصفي لكل مفتاح وصيغ ICU للجموع.
- [ ] **نجاح توليد الأكواد:** تشغيل `flutter gen-l10n` بنجاح وتوليد كافة خصائص `AppLocalizations`.
- [ ] **اعتماد الامتداد القياسي:** استخدام `context.l10n.<key>` في كافة الودجات المستهدفة.
- [ ] **اجتياز التحليل والاختبارات:** خلو المشروع من أخطاء `dart analyze` واجتياز كافة اختبارات الودجات باللغتين العربية والإنجليزية.
