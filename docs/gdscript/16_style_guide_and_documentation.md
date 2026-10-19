# دليل الأسلوب القياسي ونظام التوثيق في GDScript (Style Guide & Documentation System)

> **المصادر الرسمية:**
>
> - [Godot Docs — GDScript Style Guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html)
> - [Godot Docs — GDScript Documentation Comments](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_documentation_comments.html)

يوفر مجتمع ومطورو محرك Godot دليلاً رسمياً موحداً لكتابة كود GDScript نظيف، قابل للقراءة، ومطابق للمعايير القياسية العالمية.

---

## 1. قواعد التسمية القياسية (Naming Conventions)

| العنصر البرمجي | النمط القياسي (Casing) | مثال صحيح |
| :--- | :--- | :--- |
| **ملفات السكربت والمشاهد** | `snake_case.gd` | `player_controller.gd`, `main_menu.tscn` |
| **الأصناف (Classes) والعقد** | `PascalCase` | `class_name InventoryManager`, `CharacterBody2D` |
| **المتغيرات والخصائص** | `snake_case` | `var movement_speed: float = 200.0` |
| **الدوال (Functions)** | `snake_case` | `func take_damage(amount: int) -> void:` |
| **الثوابت (Constants)** | `CONSTANT_CASE` | `const MAX_INVENTORY_SLOTS = 20` |
| **أسماء التعدادات (Enums)** | `PascalCase` | `enum GameState { IDLE, RUN, JUMP }` |
| **عناصر التعدادات** | `CONSTANT_CASE` | `GameState.IDLE`, `GameState.RUN` |
| **الإشارات (Signals)** | `snake_case` (صيغة الماضي أو الحدث) | `signal health_changed`, `signal level_completed` |
| **الأعضاء والدوال الخاصة** | تبدأ بـ `_` (Leading Underscore) | `var _internal_timer: float`, `func _cleanup()` |

---

## 2. المسافات والتنسيق (Formatting & Indentation)

- **المسافات البادئة (Indentation)**: المعيار الرسمي المعتمد في Godot هو استخدام **علامة الجدولة (Tabs)** للمسافات البادئة (وليس المسافات العادية Spaces)، مع استخدام المسافات العادية فقط لمحاذاة النصوص داخل نفس السطر.
- **علامات التنصيص**: تُفضل علامات التنصيص المزدوجة `""` لجميع النصوص، وتُستخدم العلامات المفردة `''` فقط عندما يحتوي النص نفسه على علامات تنصيص مزدوجة لتجنب محارف الهروب.
- **الفواصل الفارغة بين الأسطر**:
  - سطران فارغان بين الدوال الكبيرة والأصناف.
  - سطر فارغ واحد للفصل بين مجموعات المتغيرات المنطقية.

---

## 3. الترتيب المعياري لمكونات ملف السكربت (Canonical Script Structure Order)

للحفاظ على اتساق المشاريع وتسهيل قراءة الكود بين الفرق البرمجية، حدد الدليل الرسمي الترتيب الصارم لعناصر ملف السكربت:

```gdscript
# 1. معامل تشغيل المحرر (إن وجد)
@tool

# 2. تفريغ الذاكرة الثابتة (إن وجد)
@static_unload

# 3. اسم الصنف وأيقونته
class_name Player
@icon("res://assets/player_icon.svg")

# 4. الوراثة
extends CharacterBody2D

# 5. التوثيق البرمجي للصنف (Doc Comments)
## يمثل الشخصية الرئيسية في اللعبة ويتحكم بالحركة وتلقي الضرر.

# 6. الإشارات (Signals)
signal health_changed(new_health: int)
signal died

# 7. التعدادات (Enums)
enum State { IDLE, RUN, JUMP, ATTACK }

# 8. الثوابت (Constants)
const GRAVITY = 980.0
const JUMP_FORCE = -400.0

# 9. المتغيرات الثابتة (Static Variables)
static var player_count: int = 0

# 10. المتغيرات المصدرة للمفتش (@export)
@export_group("الحركة والسرعة")
@export var speed: float = 300.0
@export var acceleration: float = 1200.0

# 11. المتغيرات العامة العادية
var current_health: int = 100
var current_state: State = State.IDLE

# 12. المتغيرات الخاصة (تبدأ بـ _)
var _velocity_smoothing: float = 0.1
var _is_invulnerable: bool = false

# 13. متغيرات الجاهزية والتأجيل (@onready)
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# 14. دوال دورة الحياة الافتراضية المدمجة (_init, _ready, _process, إلخ)
func _init() -> void:
    player_count += 1

func _ready() -> void:
    current_health = 100

func _physics_process(delta: float) -> void:
    _handle_movement(delta)

# 15. الدوال العامة المخصصة
func heal(amount: int) -> void:
    current_health = mini(current_health + amount, 100)
    health_changed.emit(current_health)

# 16. الدوال الخاصة المساعدة (تبدأ بـ _)
func _handle_movement(delta: float) -> void:
    velocity.y += GRAVITY * delta
    move_and_slide()

# 17. الأصناف الداخلية (Subclasses / Inner Classes)
class WeaponData:
    var damage: int = 10
```

---

## 4. نظام التعليقات التوثيقية المدمج في Godot 4 (`##`)

في Godot 4، تم تقديم نظام متكامل للتوثيق يستخرج التوثيق تلقائياً من الكود البرمجي ويعرضه داخل نافذة المساعدة بالمحرر (`F1`) وفي تلميحات الـ Inspector Tooltips:

### أ. كتابة التعليق التوثيقي

يُكتب التعليق التوثيقي باستخدام علامتي شباك **`##`** فوق العنصر المراد توثيقه مباشرة:

```gdscript
## صنف مخصص لإدارة محفظة العملات والعناصر في اللعبة.
## يدعم البيع والشراء والتحقق من الرصيد.
class_name EconomyManager
extends Node

## أقصى حد من الذهب يمكن حمله في المحفظة.
const MAX_GOLD: int = 999999

## يُطلق عندما يتغير رصيد الذهب.
## [param new_balance] يمثل الرصيد الجديد بعد التعديل.
signal balance_changed(new_balance: int)

## الرصيد الحالي المتاح للشخصية.
@export var current_gold: int = 500

## إضافة مبلغ مالي إلى رصيد المحفظة.
## يُرجع [code]true[/code] إذا تمت العملية بنجاح، أو [code]false[/code] إذا تجاوز الحد الأقصى.
func add_gold(amount: int) -> bool:
    if current_gold + amount > MAX_GOLD:
        return false
    current_gold += amount
    balance_changed.emit(current_gold)
    return true
```

---

## 5. وسوم التوثيق الرسمية (Official Doc Tags)

| الوسم | الوصف | مثال |
| :--- | :--- | :--- |
| `@tutorial: URL` | رابط لدرس تعليمي أو توثيق خارجي. | `## @tutorial: https://docs.godotengine.org` |
| `@tutorial(Title): URL` | رابط درس مع عنوان مخصص. | `## @tutorial(دليل الحركة): https://example.com/guide` |
| `@deprecated: Message` | تنبيه بأن الدالة أو الصنف مهمل وسيُحذف مستقبلاً. | `## @deprecated: استخدم [method heal_player] بدلاً منها.` |
| `@experimental: Message` | تنبيه بأن هذه الميزة تجريبية وقابلة للتغيير. | `## @experimental: نظام الطقس ما زال قيد التطوير.` |

---

## 6. وسوم التنسيق والروابط (BBCode in Doc Comments)

يمكنك استخدام وسوم BBCode داخل التعليقات التوثيقية لربط الدوال والأصناف وتنسيق الشرح:

- **`[code]my_code[/code]`**: عرض نص برمجي بخط أحادي المسافة.
- **`[b]عريض[/b]`** و **`[i]مائل[/i]`**: تنسيق الخط.
- **`[param name]`**: الإشارة إلى معامل دالة.
- **`[method func_name]`**: إنشاء رابط قابل للنقر لدالة أخرى.
- **`[member property_name]`**: إنشاء رابط لخاصية أو متغير.
- **`[signal signal_name]`**: إنشاء رابط لإشارة.
- **`[enum EnumName]`**: رابط لتعداد.
- **`[constant CONST_NAME]`**: رابط لثابت.
- **`[kbd]Ctrl + S[/kbd]`**: تمثيل اختصارات لوحة المفاتيح.
