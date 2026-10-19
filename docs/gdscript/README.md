# موسوعة ومراجع لغة GDScript في محرك Godot 4 (الموسوعة الشاملة)

مرحباً بك في التوثيق الشامل والمتكامل للغة **GDScript 2.0** المستخرج والموثق مباشرة من **المصادر الرسمية لمحرك Godot 4**.

تم تنظيم التوثيق في **16 ملفاً متخصصاً ومستقلاً** لتغطية كافة أركان ومواصفات اللغة، بدءاً من النحو التأسيسي والكلمات المحجوزة، مروراً بالبرمجة الوظيفية وإدارة الذاكرة، ووصولاً إلى التحليل الساكن وأكواد تحذيرات المترجم ودليل الأسلوب القياسي.

---

## 📚 فهرس ملفات التوثيق الشاملة

| # | اسم الملف | المحتوى والمواضيع المغطاة |
| :---: | :--- | :--- |
| **01** | [01_keywords.md](01_keywords.md) | **الكلمات المحجوزة (Reserved Keywords):** قائمة كاملة بجميع الكلمات المحجوزة في Godot 4 مصنفة حسب الاستخدام (التحكم، التصريح، البرمجة الكائنية، غير المتزامنة، العمليات المنطقية، الكلمات المحجوزة للمستقبل). |
| **02** | [02_operators.md](02_operators.md) | **العمليات الرياضية والمنطقية (Operators):** العمليات الحسابية، الإسناد، المقارنة، العمليات المنطقية، العمليات البتية (Bitwise)، معاملات الفحص والتحويل (`is` و `as`)، وأسبقية العمليات (Precedence). |
| **03** | [03_builtin_functions.md](03_builtin_functions.md) | **الدوال المدمجة الأساسية (Built-in Functions):** توثيق شامل لدوال نطاق `@GDScript` ونطاق `@GlobalScope`، متضمنة دوال الرياضيات، التوليد العشوائي، النصوص، الألوان، الزوايا والمثلثات، والتصحيح. |
| **04** | [04_data_types.md](04_data_types.md) | **أنواع البيانات والتعدادات (Data Types & Enums):** الأنواع الأولية، الكائنات الرياضية والهندسية (Vector2/3/4, Transform)، الحاويات (Array, Dictionary)، التحديد الصارم للأنواع (Static Typing)، ودليل شامل للتعامل مع التعدادات (`enums`). |
| **05** | [05_control_flow.md](05_control_flow.md) | **التحكم بالتدفق والشروط (Control Flow):** الشروط `if/elif/else`، العامل الثلاثي، مطابقة الأنماط المتقدمة `match` وحراس الشروط `when`، حلقات `for` و `while`، والتحكم بالحلقات `break` و `continue`. |
| **06** | [06_classes_and_oop.md](06_classes_and_oop.md) | **الأصناف والبرمجة الكائنية (Classes & OOP):** `class_name`، الوراثة `extends`، الأصناف الداخلية، دوال البناء `_init`، استدعاء الأب عبر `super`، دوال دورة الحياة، والخصائص المخصصة (Getters/Setters). |
| **07** | [07_annotations.md](07_annotations.md) | **المعاملات والملاحظات (Annotations):** جميع المعاملات في Godot 4: عائلة `@export` بمختلف أنواعها وتفرعاتها (الملفات، المجلدات، الأعلام، التخزين `@export_storage`، والتخصيص)، `@onready`، تشغيل السكربت بالمحرر `@tool`، الأيقونات `@icon`، واللعب الجماعي `@rpc`. |
| **08** | [08_signals_and_events.md](08_signals_and_events.md) | **الإشارات والأحداث (Signals & Events):** تعريف الإشارات بنوع محدد، إطلاقها عبر `.emit()`، ربطها بدوال عادية أو Lambdas، تمرير معلمات إضافية عبر `.bind()`، والانتظار عبر `await`. |
| **09** | [09_async_and_coroutines.md](09_async_and_coroutines.md) | **البرمجة غير المتزامنة (Async & Coroutines):** استبدال `yield` بـ `await` في Godot 4، انتظار المؤقتات، إطارات الرسم والفيزياء، طلبات الشبكة، وأفضل الممارسات لتجنب الأخطاء. |
| **10** | [10_callable_lambdas_and_closures.md](10_callable_lambdas_and_closures.md) | **الدوال ككائنات، دوال اللامبدا والإغلاقات (Callable & Closures):** الدوال ككائنات من الدرجة الأولى، دوال اللامبدا المجهولة والمسماة للتكرار الذاتي، آليات حبس النطاق وحبس المتغيرات بالقيمة والمرجع، واجهة كائن `Callable` الكاملة، ودوال البرمجة الوظيفية (`map`, `filter`, `reduce`, `sort_custom`, `any`, `all`). |
| **11** | [11_memory_management_and_resources.md](11_memory_management_and_resources.md) | **إدارة الذاكرة والموارد المخصصة (Memory & Resources):** التسلسل الهرمي لكائنات `Object` مقابل `RefCounted` و `Resource`، التحرير اليدوي (`free`/`queue_free`) ومخاطر Dangling Pointers، فحص `is_instance_valid`، المراجع الضعيفة `WeakRef` وتفادي الدورات المفرغة، وإنشاء وحفظ وتحميل وتكرار الموارد المخصصة (`.tres`). |
| **12** | [12_scene_tree_and_nodes_integration.md](12_scene_tree_and_nodes_integration.md) | **التكامل مع شجرة المشهد والعقد (SceneTree Integration):** صيغ الاختصار النحوية للعقد (`$` و `%"UniqueName"` و `&` و `^`)، الترتيب الدقيق لدورة حياة العقد (Bottom-Up في `_ready`)، نظام الإشعارات المنخفضة `_notification`، تفريخ المشاهد برمجياً عبر `PackedScene`، ونظام المجموعات (Groups). |
| **13** | [13_compiler_warnings_and_static_analysis.md](13_compiler_warnings_and_static_analysis.md) | **تحذيرات المترجم والتحليل الساكن (Compiler Warnings):** مكاسب أداء التحديد الصارم للأنواع (Static Typing Performance)، قواعد التجاوز عبر `@warning_ignore`، والفهرس المصنف الكامل لأكثر من 35 كود تحذير رسمي مع أسبابها وطرق علاجها البرمجية النظيفة. |
| **14** | [14_strings_and_formatting.md](14_strings_and_formatting.md) | **النصوص وتنسيق السلاسل النصية (Strings & Formatting):** محارف الهروب، تنسيق الطباعة المتقدم عبر العامل `%` (Printf-style) بالأرقام العشرية والحشو والمحاذاة، التنسيق عبر القواميس بـ `String.format()`، والفهرس الكامل لميثودات فحص النصوص والتحقق وتقطيع المسارات (`path_join`, `get_file`, إلخ). |
| **15** | [15_global_constants_and_enums.md](15_global_constants_and_enums.md) | **الثوابت والتعدادات العالمية (Global Enums & Constants):** الفهرس الشامل لتعدادات النطاق العام `@GlobalScope`، متضمناً قائمة أكواد الأخطاء والحالات `Error`، أحداث لوحة المفاتيح والماوس والأزرار (`Key`, `MouseButton`)، المحاذاة والاتجاهات، تعدادات فحص الانعكاس `Variant.Type`، والثوابت الرياضية (`PI`, `TAU`, `INF`, `NAN`). |
| **16** | [16_style_guide_and_documentation.md](16_style_guide_and_documentation.md) | **دليل الأسلوب القياسي ونظام التوثيق (Style Guide & Doc Comments):** المعايير الرسمية للتسمية والمسافات البادئة (Tabs vs Spaces)، الترتيب الصارم لعناصر ملف السكربت (17 مرحلة معيارية)، نظام التعليقات التوثيقية `##`، وسوم التوثيق الرسمية (`@tutorial`, `@deprecated`, `@experimental`)، وتنسيقات BBCode. |

---

## 🔗 المصادر الرسمية المعتمدة في التوثيق

- [Godot Engine Official Documentation (Stable)](https://docs.godotengine.org/en/stable/)
- [GDScript Reference Manual](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html)
- [@GDScript Class Reference](https://docs.godotengine.org/en/stable/classes/class_%40gdscript.html)
- [@GlobalScope Class Reference](https://docs.godotengine.org/en/stable/classes/class_%40globalscope.html)
- [Godot Engine GitHub Source Code (GDScript Module)](https://github.com/godotengine/godot/tree/master/modules/gdscript)
