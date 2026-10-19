# مصادر GDScript الرسمية

هذا دليل مختصر لأهم صفحات GDScript الرسمية المنشورة ضمن توثيق Godot Engine. الروابط أدناه تشير إلى نسخة **stable** باللغة الإنجليزية؛ وقد يتغير محتواها مع صدور إصدارات Godot جديدة. إذا كان المشروع يستخدم إصداراً محدداً، فاختر إصدار المحرك المطابق من محدد الإصدارات في موقع التوثيق.

## بوابة التوثيق

- [قسم GDScript في توثيق Godot](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/index.html) — فهرس رئيسي يجمع صفحات اللغة، ويُعد نقطة البداية للعثور على المرجع والمواضيع المتخصصة.
- [قسم البرمجة النصية في Godot](https://docs.godotengine.org/en/stable/tutorials/scripting/index.html) — نظرة عامة على البرمجة في المحرك؛ يضع GDScript إلى جانب اللغات المدعومة الأخرى، ويضم موضوعات مشتركة مثل دورة حياة العقد والتصحيح.

## مرجع اللغة وواجهاتها

- [مرجع GDScript الأساسي](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html) — المرجع الأوسع لصياغة اللغة ومفاهيمها، بما فيها الكلمات المحجوزة، المتغيرات والثوابت، الأنواع، الدوال، الأصناف، الإشارات، التحكم بالتدفق والتعابير.
- [مقدمة إلى اللغات الديناميكية في GDScript](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_advanced.html) — تشرح طبيعة الأنواع الديناميكية وكيفية كتابة GDScript بفعالية؛ مفيدة خصوصاً لمن ينتقل من لغة ذات أنواع ساكنة.
- [مرجع الصنف المدمج `@GDScript`](https://docs.godotengine.org/en/stable/classes/class_%40gdscript.html) — مرجع API للدوال والثوابت والمعاملات (annotations) المتاحة مباشرة في سكربتات GDScript.

## ميزات اللغة وممارسات الكتابة

- [الأنواع الساكنة في GDScript](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/static_typing.html) — يشرح التصريح بالأنواع والاستدلال عليها، وأنواع المتغيرات والمعاملات وقيم الإرجاع، وفوائد الأنواع في اكتشاف الأخطاء والإكمال التلقائي.
- [الخصائص المصدّرة](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_exports.html) — يشرح استخدام `@export` لإظهار خصائص السكربت وتحريرها في المحرر وحفظ قيمها مع المشاهد أو الموارد.
- [تعليقات توثيق GDScript](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_documentation_comments.html) — يشرح صيغة `##` لكتابة توثيق السكربت وأعضائه، والوسوم المستخدمة لتوليد التوثيق وإظهار الشروح.
- [دليل أسلوب GDScript](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html) — توصيات Godot للتسمية، وترتيب عناصر السكربت، والتنسيق والمسافات البادئة؛ هدفه توحيد القراءة لا فرض قواعد نحوية.
- [نظام التحذيرات في GDScript](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/warning_system.html) — يشرح التحذيرات التي تساعد على اكتشاف أخطاء محتملة، وكيفية ضبطها أو تجاهل تحذير بعينه.
- [تنسيق السلاسل النصية في GDScript](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_format_string.html) — يشرح قوالب التنسيق باستخدام `%` و`String.format()`، مع الإشارة إلى جمع السلاسل النصية.

## مصدر التوثيق نفسه

- [مستودع توثيق Godot الرسمي — صفحات GDScript](https://github.com/godotengine/godot-docs/tree/master/tutorials/scripting/gdscript) — ملفات المصدر التي تُبنى منها صفحات التوثيق أعلاه. يفيد هذا الرابط عند مراجعة تعديلات التوثيق أو المساهمة فيها؛ أما للاستخدام اليومي فنسخة الموقع أسهل في القراءة.

## اختيار المصدر المناسب

للبدء، اقرأ [مرجع GDScript الأساسي](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html)، ثم ارجع إلى صفحات الميزة المحددة عند الحاجة. استخدم مرجع `@GDScript` للتحقق من تفاصيل دالة أو معامل مدمج، ودليل الأسلوب لتنسيق الشيفرة. ولتفاصيل أصناف المحرك الأخرى مثل `Node` أو `Array`، ابحث عن الصنف في [مرجع أصناف Godot](https://docs.godotengine.org/en/stable/classes/index.html).
