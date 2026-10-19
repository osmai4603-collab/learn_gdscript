# المعاملات والملاحظات في GDScript (Annotations in Godot 4)

> **المصدر الرسمي:**
>
> - [GDScript Reference — Annotations](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html#annotations)
> - [Godot @GDScript Annotations](https://docs.godotengine.org/en/stable/classes/class_%40gdscript.html#annotations)

في Godot 4، تم استبدال الكلمات السابقة مثل `export` و `onready` و `tool` بنظام المعاملات الحديث (Annotations) الذي يبدأ بعلامة `@`. تُستخدم هذه المعاملات لتعديل سلوك المتغيرات والدوال أو طريقة عرضها في محرر Godot.

---

## 1. معاملات التصدير إلى لوحة الخصائص (Inspector Exports)

تسمح لك معاملات التصدير بإظهار المتغيرات في لوحة المفتش (Inspector) في محرر Godot لتعديلها بسهولة دون الحاجة لتعديل الكود.

### أ. التصدير الأساسي (`@export`)

```gdscript
# تصدير متغير من أي نوع
@export var player_name: String = "Hero"
@export var speed: float = 300.0
@export var is_invincible: bool = false
@export var spawn_position: Vector2 = Vector2.ZERO
```

### ب. تصدير النطاق والخطوات (`@export_range`)

تُنشئ شريط تمرير (Slider) أو حقل أرقام محدد بنطاق:

```gdscript
# نطاق بين 0 و 100
@export_range(0, 100) var health: int = 100

# نطاق بأرقام عشرية مع قفزة (Step) محددة
@export_range(0.0, 1.0, 0.05) var volume: float = 0.8

# نطاق مع أس لوغاريتمي أو قيم سالبة
@export_range(1, 10, 1, "or_greater") var extra_lives: int = 3
```

### ج. تصدير القوائم والاختيارات (`@export_enum`)

تُنشئ قائمة منسدلة (Dropdown) في المحرر:

```gdscript
# قائمة خيارات بسيطة
@export_enum("سيف", "قوس", "عصا سحرية") var starter_weapon: String = "سيف"

# ربط الخيارات بقيم عددية
@export_enum("صغير:10", "متوسط:20", "كبير:30") var potion_size: int = 10
```

### د. تصدير الموارد والملفات والمجلدات

```gdscript
# تصدير مرجع لمورد معين
@export var custom_icon: Texture2D

# تصدير مسار لملف محدد داخل مجلد المشروع (res://)
@export_file("*.png", "*.jpg") var sound_file: String

# تصدير مسار مجلد داخل المشروع (res://)
@export_dir var levels_directory: String

# تصدير مسار ملف من أي مكان على نظام التشغيل (خارج المشروع)
@export_global_file("*.txt") var external_config_file: String

# تصدير مسار مجلد خارجي من نظام التشغيل
@export_global_dir var external_saves_directory: String
```

### هـ. تصدير النصوص والملاحظات والخصائص الخاصة

```gdscript
# حقل نصي كبير متعدد الأسطر
@export_multiline var dialog_text: String

# حقل نصي مع نص توضيحي مسبق وخافت (Placeholder)
@export_placeholder("أدخل اسم اللاعب هنا...") var player_nickname: String

# تصدير لون بدون قناة الشفافية (Alpha)
@export_color_no_alpha var background_color: Color

# تصدير منحنى تسهيل أُسي
@export_exp_easing var fade_curve: float
```

### و. تصدير الأعلام والطبقات (Bit Flags & Layers)

```gdscript
# قائمة أعلام مخصصة متعددة الاختيار (Bitmask Checkboxes)
@export_flags("سحر النار", "سحر الجليد", "سحر البرق", "سحر الرياح") var spell_elements: int

# طبقات الفيزياء والرسم ثنائية وثلاثية الأبعاد
@export_flags_2d_physics var collision_layers_2d: int
@export_flags_2d_render var visual_layers_2d: int
@export_flags_2d_navigation var nav_layers_2d: int

@export_flags_3d_physics var collision_layers_3d: int
@export_flags_3d_render var visual_layers_3d: int
@export_flags_3d_navigation var nav_layers_3d: int
```

### ز. معاملات التخزين والتخصيص المتقدمة (Godot 4.3+)

```gdscript
# @export_storage: حفظ وتخزين الخاصية في ملف المشهد (.tscn) دون إظهارها في لوحة المفتش
@export_storage var internal_saved_id: String = ""

# @export_custom: تخصيص نوع وتلميح وظهور الخاصية برمجياً بالكامل
@export_custom(PROPERTY_HINT_RANGE, "0,100,5") var custom_stepped_val: int
```

---

## 2. تنظيم وترتيب الخصائص في المفتش (Grouping & Categorization)

لتنظيم عشرات الخصائص المصدرة في تبويبات وأقسام أنيقة داخل Inspector:

```gdscript
extends CharacterBody2D

# 1. إنشاء تصنيف رئيسي (Category)
@export_category("بيانات الشخصية")
@export var character_name: String = "محارب"
@export var level: int = 1

# 2. إنشاء مجموعة قابلة للطي (Group)
# المعلمة الثانية تحذف البادئة المحددة من العرض لتنظيف الشكل
@export_group("الخصائص القتالية", "combat_")
@export var combat_attack: int = 15
@export var combat_defense: int = 10

# 3. مجموعة فرعية (Subgroup)
@export_subgroup("المهارات السحرية", "magic_")
@export var magic_mana: int = 50
@export var magic_spell: String = "كرة نار"
```

---

## 3. معامل التهيئة التلقائية عند الجاهزية (`@onready`)

يقوم بتأجيل تهيئة المتغير حتى تصبح العقدة جاهزة تماماً داخل شجرة المشهد (`_ready`):

```gdscript
extends Node2D

# جلب العقد الفرعية بأمان وسهولة
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = get_node("CollisionShape2D")
@onready var timer: Timer = %GameTimer # استخدام Unique Name للعقدة بواسطة %
```

---

## 4. وضع تشغيل السكربت داخل المحرر (`@tool`)

عند وضع `@tool` في السطر الأول من السكربت، يتم تنفيذ كود هذا السكربت **داخل محرر Godot نفسه** أثناء التصميم (Live Preview):

```gdscript
@tool
extends Node2D

@export var circle_color: Color = Color.BLUE:
    set(value):
        circle_color = value
        queue_redraw() # إعادة الرسم فوراً في المحرر

func _draw():
    draw_circle(Vector2.ZERO, 30.0, circle_color)
```

> **ملاحظة:** يمكن فحص ما إذا كان الكود يعمل في المحرر أو في اللعبة عبر:
> `if Engine.is_editor_hint():`

---

## 5. أيقونة الصنف المخصصة (`@icon`)

تحديد أيقونة مخصصة لصنفك تظهر بجانب اسمه في شجرة العقد ومستكشف الملفات:

```gdscript
class_name HealthBar
@icon("res://assets/icons/heart.svg")
extends ProgressBar
```

---

## 6. اللعب الجماعي والنداء عن بُعد (`@rpc`)

تُستخدم لتحديد صلاحيات وخصائص استدعاء الدوال عبر الشبكة (Multiplayer RPC):

```gdscript
# أي لاعب يمكنه استدعاء الدالة، ويتم استدعاؤها محلياً أيضاً، بطريقة موثوقة (TCP-like)
@rpc("any_peer", "call_local", "reliable")
func update_player_score(new_score: int):
    score = new_score
    print("النتيجة المحدثة: ", score)
```

خيارات `@rpc`:

- الأطراف: `"any_peer"`, `"authority"`
- التنفيذ: `"call_local"`, `"call_remote"`
- التوصيل: `"reliable"`, `"unreliable"`, `"unreliable_ordered"`

---

## 7. تجاهل تحذيرات المترجم (`@warning_ignore`)

لتجاوز تنبيهات أو تحذيرات محددة يطلقها المترجم لسطر كود مقصود:

```gdscript
# تجاهل تحذير عدم استخدام القيمة المُرجعة
@warning_ignore("return_value_discarded")
func _ready():
    my_signal.connect(_on_signal)

# تجاهل تحذير عدم استخدام معامل دالة
@warning_ignore("unused_parameter")
func _process(delta: float):
    pass
```

> [!NOTE]
> للاطلاع على الدليل الشامل لجميع أكواد التحذيرات المعتمدة وتصنيفاتها في محرك Godot 4، راجع ملف التوثيق: [13_compiler_warnings_and_static_analysis.md](file:///home/osm/flutter_projects/gdscript_editor/docs/gdscript/13_compiler_warnings_and_static_analysis.md).

---

## 8. إلغاء تحميل البيانات الثابتة (`@static_unload`)

```gdscript
@static_unload
class_name TemporaryHelper
extends RefCounted

static var cache_data = []
```

تضمن إعادة تعيين ومسح المتغيرات الثابتة (`static var`) من الذاكرة عندما لا يتبقى أي مراجع للسكربت في اللعبة.
