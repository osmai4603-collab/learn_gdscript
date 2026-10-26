# تحليل الألوان المكتوبة مباشرة في الواجهات

## النطاق والمنهجية

يرصد هذا التحليل الألوان المحددة مباشرة في ملفات الواجهة تحت `lib/ui/`، بما
يشمل الشاشات وتخطيطات الواجهة والمكوّنات المشتركة التي ترسم داخلها. شمل الحصر
قيم `Color(0x...)` وألوان Flutter المسماة من `Colors.*`. لم تُحتسب الألوان
المأخوذة من `Theme.of(context)` أو `ColorScheme`، ولم تُفحص ملفات تعريف الثيم
تحت `lib/core/theme/` باعتبارها خارج نطاق الألوان المكتوبة مباشرة في الشاشات.

النتيجة: **562 ظهوراً لقيم hex، تمثل 53 قيمة فريدة، في 14 ملفاً**، إضافة إلى
**23 ظهوراً لألوان Flutter المسماة** في الواجهات. تكرار القيمة لا يعني بالضرورة
تكرار الدور؛ فقد تُستخدم الدرجة نفسها للخلفية أو النص أو الحد حسب العنصر.

## القيم المباشرة

الأعداد في الجدول هي عدد مرات كتابة قيمة `Color(0x...)` في ملفات الواجهة.
القيم ذات ثمانية أرقام تتضمن قناة ألفا في أول بايت؛ مثل `#22000000` لأسود
شفافيته منخفضة.

| المجموعة البصرية | القيمة | مرات الظهور |
|---|---:|---:|
| شفافية وظلال | `#18000000` | 1 |
| شفافية وظلال | `#22000000` | 1 |
| شفافية وظلال | `#33000000` | 2 |
| خلفيات داكنة وأسطح | `#FF090F15` | 8 |
| خلفيات داكنة وأسطح | `#FF0A0D12` | 8 |
| خلفيات داكنة وأسطح | `#FF0F141B` | 14 |
| خلفيات داكنة وأسطح | `#FF11161D` | 2 |
| خلفيات داكنة وأسطح | `#FF131922` | 22 |
| خلفيات داكنة وأسطح | `#FF171C23` | 19 |
| خلفيات داكنة وأسطح | `#FF1B2027` | 17 |
| خلفيات داكنة وأسطح | `#FF1E2632` | 3 |
| خلفيات داكنة وأسطح | `#FF1E2837` | 5 |
| خلفيات داكنة وأسطح | `#FF1F2630` | 9 |
| خلفيات داكنة وأسطح | `#FF252A32` | 24 |
| حدود وفواصل | `#FF28323F` | 40 |
| حدود وفواصل | `#FF30353D` | 10 |
| حدود وفواصل | `#FF40484F` | 3 |
| نصوص ودرجات محايدة | `#FF5B6878` | 1 |
| نصوص ودرجات محايدة | `#FF64748B` | 21 |
| نصوص ودرجات محايدة | `#FF8A919A` | 22 |
| نصوص ودرجات محايدة | `#FF94A3B8` | 42 |
| نصوص ودرجات محايدة | `#FFC0C7D0` | 15 |
| نصوص ودرجات محايدة | `#FFCBD5E1` | 4 |
| نصوص ودرجات محايدة | `#FFDEE2EC` | 19 |
| نصوص ودرجات محايدة | `#FFE2E8F0` | 46 |
| أزرق وسماوي | `#FF002C46` | 2 |
| أزرق وسماوي | `#FF003350` | 3 |
| أزرق وسماوي | `#FF38BDF8` | 26 |
| أزرق وسماوي | `#FF478CBF` | 39 |
| أزرق وسماوي | `#FF5397CA` | 1 |
| أزرق وسماوي | `#FF91CDFF` | 24 |
| أخضر | `#FF089B0D` | 1 |
| أخضر | `#FF14532D` | 8 |
| أخضر | `#FF22C55E` | 21 |
| أخضر | `#FF2ECC71` | 1 |
| أخضر | `#FF4ADE80` | 1 |
| أخضر | `#FF4AE183` | 16 |
| أخضر | `#FF6BFE9C` | 1 |
| أخضر | `#FF86EFAC` | 1 |
| برتقالي وذهبي | `#FF301400` | 2 |
| برتقالي وذهبي | `#FF4F2500` | 1 |
| برتقالي وذهبي | `#FF78350F` | 1 |
| برتقالي وذهبي | `#FFD97706` | 1 |
| برتقالي وذهبي | `#FFDB7619` | 3 |
| برتقالي وذهبي | `#FFF39C12` | 1 |
| برتقالي وذهبي | `#FFF59E0B` | 12 |
| برتقالي وذهبي | `#FFFB923C` | 6 |
| برتقالي وذهبي | `#FFFFB783` | 21 |
| برتقالي وذهبي | `#FFFCD34D` | 1 |
| بنفسجي | `#FFA855F7` | 6 |
| بنفسجي | `#FFCAA7FF` | 2 |
| أحمر ووردي | `#FFEF4444` | 1 |
| أحمر ووردي | `#FFFFB4AB` | 1 |

## ألوان Flutter المسماة

هذه المراجع ليست قيماً hex مكتوبة في المصدر؛ إنها ثوابت جاهزة من Flutter:

| الثابت | مرات الظهور | ملاحظة |
|---|---:|---|
| `Colors.black` | 3 | أسود |
| `Colors.redAccent` | 1 | أحمر بارز |
| `Colors.transparent` | 8 | شفاف، لا يضيف لون تعبئة مرئياً |
| `Colors.white` | 11 | أبيض |

## الملفات التي تحتوي ألوان hex مباشرة

الأعداد التالية تخص مرات كتابة قيم hex في كل ملف، لا عدد الألوان الفريدة
المستخدمة فيه.

| الملف | مرات الظهور |
|---|---:|
| [app_shell_sidebar.dart](../lib/ui/layouts/app_shell_sidebar.dart) | 4 |
| [desktop_concept_map_sm_2_flutter_dart.dart](../lib/ui/screens/concept_map/desktop_concept_map_sm_2_flutter_dart.dart) | 76 |
| [desktop_home_dashboard.dart](../lib/ui/screens/home/desktop_home_dashboard.dart) | 166 |
| [home_screen.dart](../lib/ui/screens/home/home_screen.dart) | 6 |
| [desktop_learning_path_flutter_dart.dart](../lib/ui/screens/learning_path/desktop_learning_path_flutter_dart.dart) | 21 |
| [learning_path_screen.dart](../lib/ui/screens/learning_path/learning_path_screen.dart) | 19 |
| [desktop_lesson_complete_flutter_dart.dart](../lib/ui/screens/lesson/desktop_lesson_complete_flutter_dart.dart) | 11 |
| [desktop_lesson_ide_flutter_dart.dart](../lib/ui/screens/lesson/desktop_lesson_ide_flutter_dart.dart) | 18 |
| [onboarding_screen.dart](../lib/ui/screens/onboarding/onboarding_screen.dart) | 81 |
| [desktop_settings_flutter_dart.dart](../lib/ui/screens/settings/desktop_settings_flutter_dart.dart) | 62 |
| [workspace_projects_ide_flutter_dart.dart](../lib/ui/screens/workspace/workspace_projects_ide_flutter_dart.dart) | 94 |
| [academy_status_badge.dart](../lib/ui/widgets/academy_status_badge.dart) | 2 |
| [code_editor_run_overlay.dart](../lib/ui/widgets/code_editor/code_editor_run_overlay.dart) | 1 |
| [code_editor_widget.dart](../lib/ui/widgets/code_editor/code_editor_widget.dart) | 1 |

## خلاصة

- يغلب على الواجهات نمط داكن، مع مجموعة كبيرة من درجات الخلفية والأسطح
  والحدود المكتوبة داخل الملفات بدلاً من الرجوع إلى ألوان الثيم.
- أكثر القيم تكراراً هي `#FFE2E8F0` (46 مرة)، و`#FF94A3B8` (42 مرة)،
  و`#FF28323F` (40 مرة)، و`#FF478CBF` (39 مرة).
- توجد درجات متقاربة متعددة للأزرق والسماوي والأخضر والبرتقالي؛ لذلك فإن
  تعديل الهوية أو دعم ثيم بديل قد يتطلب مراجعة هذه المواضع مباشرة.
- الألوان التي تمر عبر متغير محلي مثل `_PathColors` لا تُعد ظهوراً جديداً
  لقيمة لون؛ يُحتسب تعريف `Color(0x...)` نفسه فقط، وتُستبعد مراجع الـTheme.
