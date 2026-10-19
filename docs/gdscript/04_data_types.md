# أنواع البيانات في GDScript (Data Types & Variant)

> **المصدر الرسمي:**
>
> - [GDScript Reference — Data Types](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html#built-in-types)
> - [Godot Variant Documentation](https://docs.godotengine.org/en/stable/classes/class_variant.html)

تعتمد لغة GDScript على نظام الـ **Variant**، وهو نوع بيانات ديناميكي ومدمج في محرك Godot يمكنه تخزين أي نوع مدعوم. يدعم GDScript كلا الأسلوبين: **النوع الديناميكي (Dynamic Typing)** و**النوع الثابت الصارم (Static Typing)**.

---

## 1. الأنواع الأساسية (Primitive Types)

| النوع | الوصف | مثال | القيمة الافتراضية |
| :--- | :--- | :--- | :--- |
| `null` | يمثل عدم وجود قيمة أو كائن غير مهيأ | `var x = null` | `null` |
| `bool` | قيمة منطقية (`true` أو `false`) | `var is_active: bool = true` | `false` |
| `int` | عدد صحيح 64-بت ذو إشارة (Signed 64-bit Integer) | `var count: int = 42` | `0` |
| `float` | عدد عشري 64-بت مزدوج الدقة (Double precision) | `var speed: float = 3.14159` | `0.0` |
| `String` | سلسلة نصية مشفرة بـ UTF-8 | `var name: String = "Godot"` | `""` |
| `StringName` | معرّف نصي فريد لا يتغير (مُحسّن للذاكرة والمقارنات السريعة) | `var id: StringName = &"player_jump"` | `&""` |
| `NodePath` | مسار إلى عقدة داخل شجرة المشهد (SceneTree) | `var path: NodePath = ^"../Player/Sprite2D"` | `^""` |

### تفاصيل وإضافات

```gdscript
# تعريف النصوص والصيغ الخاصة
var regular_string = "Hello, World!"
var unique_string_name = &"node_name"      # بادئة & تعني StringName
var node_path = ^"Path/To/Child"          # بادئة ^ تعني NodePath

# النصوص متعددة الأسطر (Multiline String)
var multi = """
هذا نص
يمتد عبر عدة
أسطر بسهولة
"""
```

---

## 2. كائنات ومصفوفات المحرك الرياضية (Math & Geometry Types)

يوفر Godot أنواعاً رياضية وهندسية عالية الأداء مبنية بلغة C++ مباشرة:

### متجهات ثنائية وثلاثية ورباعية الأبعاد

| النوع | الوصف | مثال |
| :--- | :--- | :--- |
| `Vector2` | متجه ثنائي الأبعاد بأرقام عشرية (x, y) | `var pos = Vector2(100.5, 200.0)` |
| `Vector2i` | متجه ثنائي الأبعاد بأعداد صحيحة | `var grid_pos = Vector2i(5, 10)` |
| `Vector3` | متجه ثلاثي الأبعاد بأرقام عشرية (x, y, z) | `var velocity = Vector3(0, 9.8, -1.0)` |
| `Vector3i` | متجه ثلاثي الأبعاد بأعداد صحيحة | `var voxel = Vector3i(1, 0, -2)` |
| `Vector4` | متجه رباعي الأبعاد بأرقام عشرية (x, y, z, w) | `var v4 = Vector4(1, 2, 3, 4)` |
| `Vector4i` | متجه رباعي الأبعاد بأعداد صحيحة | `var v4i = Vector4i(1, 2, 3, 4)` |

### الأشكال الهندسية ومصفوفات التحويل

| النوع | الوصف | مثال |
| :--- | :--- | :--- |
| `Rect2` | مستطيل ثنائي الأبعاد (position, size) بأرقام عشرية | `var r = Rect2(0, 0, 32, 32)` |
| `Rect2i` | مستطيل ثنائي الأبعاد بأعداد صحيحة | `var ri = Rect2i(0, 0, 16, 16)` |
| `Transform2D` | مصفوفة تحويل 2D (تحتوي على التدوير والموضع والحجم) | `var t = Transform2D.IDENTITY` |
| `Plane` | مستوى في الفضاء ثلاثي الأبعاد بصيغة (Normal, Distance) | `var p = Plane(Vector3.UP, 0)` |
| `Quaternion` | رباعي لتمثيل التدوير ثلاثي الأبعاد بدقة وتجنب Gimbal Lock | `var q = Quaternion.IDENTITY` |
| `AABB` | صندوق محاذاة ثلاثي الأبعاد (Axis-Aligned Bounding Box) | `var box = AABB(Vector3.ZERO, Vector3.ONE)` |
| `Basis` | مصفوفة 3x3 لتمثيل التدوير والمقياس في الفضاء ثلاثي الأبعاد | `var b = Basis.IDENTITY` |
| `Transform3D` | تحويل ثلاثي الأبعاد كامل (Basis + Origin) | `var t3 = Transform3D.IDENTITY` |
| `Projection` | مصفوفة إسقاط 4x4 للكاميرات والرؤية المنظورية | `var proj = Projection.IDENTITY` |

---

## 3. أنواع المحرك العامة (Engine Types)

| النوع | الوصف | مثال |
| :--- | :--- | :--- |
| `Color` | لون بقيم RGBA عائمة بين 0.0 و 1.0 (أو رموز Hex) | `var c = Color(1.0, 0.0, 0.0, 1.0)` أو `Color.RED` |
| `RID` | معرّف فريد لمورد على الخادم المنخفض (Resource ID) | `var rid: RID = texture.get_rid()` |
| `Callable` | مؤشر إلى دالة قابلة للاستدعاء (تشمل الدوال العادية والـ Lambdas) | `var cb: Callable = self._on_event` |
| `Signal` | تمثيل كائن الإشارة لتوصيلها ومراقبتها | `var sig: Signal = button.pressed` |

---

## 4. الحاويات والمجموعات (Containers & Collections)

### أ. المصفوفات العامة (Array)

المصفوفات في GDScript ديناميكية الحجم، ويمكن أن تكون حرة (تحمل أي نوع) أو مخصصة النوع (Typed Array):

```gdscript
# مصفوفة حرة (Untyped Array)
var list = [1, "text", Vector2(0, 0), true]

# مصفوفة مقيدة بنوع محدد (Typed Array - ميزة قوية في Godot 4)
var scores: Array[int] = [10, 20, 30]
var enemies: Array[CharacterBody2D] = []

# دوال هامة للمصفوفات:
scores.append(40)          # إضافة في النهاية
scores.push_front(5)       # إضافة في البداية
scores.pop_back()          # استخراج وحذف الأخير
scores.sort()              # ترتيب تصاعدي
scores.erase(20)           # حذف عنصر بقيمته
print(scores.has(10))      # فحص وجود عنصر (true)
print(scores.size())       # طول المصفوفة
```

### ب. المصفوفات المدمجة والمحزومة (Packed Arrays)

مصفوفات متلاصقة في الذاكرة (Memory-packed) ذات كفاءة وسرعة استثنائية لكتل البيانات الكبيرة:

| النوع | نوع المحتوى |
| :--- | :--- |
| `PackedByteArray` | بايتات 8-بت غير مسبوقة بإشارة (`0` إلى `255`) |
| `PackedInt32Array` | أعداد صحيحة 32-بت |
| `PackedInt64Array` | أعداد صحيحة 64-بت |
| `PackedFloat32Array` | أعداد عشرية فردية الدقة 32-بت |
| `PackedFloat64Array` | أعداد عشرية مزدوجة الدقة 64-بت |
| `PackedStringArray` | مصفوفة نصوص سريعة |
| `PackedVector2Array` | مصفوفة متجهات 2D (شائعة في رسم الخطوط والمضلعات) |
| `PackedVector3Array` | مصفوفة متجهات 3D (شائعة في شبكات ونقاط الـ Mesh) |
| `PackedColorArray` | مصفوفة ألوان |
| `PackedVector4Array` | مصفوفة متجهات 4D |

### ج. القواميس (Dictionary)

أزواج من المفاتيح والقيم (Key-Value Pairs):

```gdscript
# قاموس عادي
var inventory = {
    "potions": 5,
    "gold": 120,
    "sword_equipped": true
}

# قواميس محددة النوع (Typed Dictionaries في Godot 4)
var dict: Dictionary[String, int] = {
    "apple": 3,
    "banana": 5
}

# الوصول والتعديل
inventory["gold"] += 50
print(inventory.get("shield", "غير موجود")) # الحصول مع قيمة افتراضية
inventory.erase("potions")                 # حذف مفتاح
print(inventory.keys())                    # قائمة المفاتيح
print(inventory.values())                  # قائمة القيم
```

---

## 5. التحديد الصارم للأنواع (Static Typing in GDScript)

يساعد التحديد الصارم للأنواع محرك Godot على اكتشاف الأخطاء أثناء الكتابة والتحرير، وزيادة سرعة تشغيل الكود بنسبة تصل إلى 20-30%.

### الصيغ المتاحة

```gdscript
# 1. التحديد الصريح
var health: int = 100
var max_speed: float = 250.0

# 2. الاستنتاج التلقائي للنوع (Inferred Typing) باستخدام :=
var ammo := 30           # يتم تحديد نوعه كـ int تلقائياً
var player_name := "Ali" # يتم تحديد نوعه كـ String تلقائياً

# 3. تحديد نوع معلمات الدوال ونوع القيمة المُرجعة
func calculate_damage(base: int, multiplier: float) -> int:
    return int(base * multiplier)

# 4. دالة لا تُرجع شيئاً (void)
func reset_game() -> void:
    health = 100
```

---

## 6. تحويل الأنواع والتحقق منها (Type Casting & Checking)

```gdscript
# التحقق من النوع باستخدام عامل `is`
if my_node is Sprite2D:
    print("العقدة عبارة عن كائن Sprite2D")

if value is int:
    print("قيمة عددية صحيحة")

# التحويل الآمن باستخدام `as` (يُرجع null إذا فشل التحويل لكائن)
var sprite = my_node as Sprite2D
if sprite:
    sprite.visible = true

# التحويل المباشر للأنواع الأساسية
var text_number = "123"
var num = int(text_number)      # تحويل لنص إلى int -> 123
var f_val = float("3.14")       # -> 3.14
var str_val = str(42)           # تحويل إلى نص -> "42"
```

---

## 7. التعدادات المخصصة (Enums) والتعامل معها بالتفصيل

الـ **Enum** في GDScript هو مجموعة من الثوابت العددية ذات الأسماء المعنوية، ويتم تخزينها والتعامل معها داخلياً كأعداد صحيحة (`int`) مدمجة في بنية تشبه القاموس (`Dictionary`).

---

### أ. أنواع تعريف الـ Enum

#### 1. تعداد مسمى (Named Enum)

ينشئ نوع بيانات جديد ومحدد، ويتم الوصول لعناصره عبر اسم التعداد:

```gdscript
enum State {
    IDLE,   # 0
    WALK,   # 1
    RUN,    # 2
    JUMP    # 3
}

# استخدام اسم التعداد كنوع صارم (Type Hinting)
var current_state: State = State.IDLE
```

#### 2. تعداد مجهول الاسم (Anonymous Enum)

توضع أسماء الثوابت في النطاق العام للسكربت مباشرة بدون بادئة:

```gdscript
enum {
    TILE_EMPTY, # 0
    TILE_GRASS, # 1
    TILE_WATER  # 2
}

func check_tile(tile_type: int):
    if tile_type == TILE_WATER:
        splash()
```

#### 3. تحديد قيم مخصصة للثوابت

```gdscript
enum DamageType {
    PHYSICAL = 100,
    FIRE = 200,
    ICE = 300,
    LIGHTNING # يأخذ تلقائياً 301
}
```

---

### ب. استخدام الـ Enum مع لوحة الخصائص (`@export`)

عند تصدير متغير من نوع Enum مسمى، يقوم محرك Godot تلقائياً بإنشاء **قائمة منسدلة (Dropdown Menu)** في لوحة المفتش (Inspector):

```gdscript
enum CharacterClass { WARRIOR, MAGE, ARCHER, ROGUE }

# يظهر في الـ Inspector كقائمة اختيار بأسماء الفئات
@export var player_class: CharacterClass = CharacterClass.WARRIOR
```

---

### ج. التعامل مع الـ Enum كقاموس (تحويل القيمة إلى نص والعكس)

في GDScript، يمتلك الـ Enum المسمى خصائص القاموس مثل `.keys()` و `.values()` و `.size()`:

```gdscript
enum Alignment { GOOD, NEUTRAL, EVIL }

func _ready():
    # 1. عدد عناصر التعداد
    print(Alignment.size()) # 3

    # 2. مصفوفة أسماء العناصر (Strings)
    print(Alignment.keys()) # ["GOOD", "NEUTRAL", "EVIL"]

    # 3. مصفوفة القيم العددية (ints)
    print(Alignment.values()) # [0, 1, 2]

    # 4. تحويل القيمة العددية إلى اسم النص المقابل (Reverse Lookup)
    var current: Alignment = Alignment.EVIL
    var state_name: String = Alignment.keys()[current]
    print("اسم الحالة: ", state_name) # "EVIL"

    # 5. جلب القيمة من نص
    var val: int = Alignment["GOOD"]
    print("القيمة: ", val) # 0
```

---

### د. استخدام الـ Enum داخل جمل التحكم `match`

تُعتبر الـ Enums أفضل طريقة لإدارة آلات الحالات (Finite State Machines):

```gdscript
func update_behavior(state: State):
    match state:
        State.IDLE:
            play_animation("idle")
            velocity = Vector2.ZERO
        State.WALK:
            play_animation("walk")
            speed = 100.0
        State.RUN:
            play_animation("run")
            speed = 250.0
        State.JUMP:
            play_animation("jump")
            apply_jump_force()
```

---

### هـ. رايات البتات باستخدام الـ Enum (Bit Flags)

يمكنك تعريف Enum كأقنعة بتية (Bitmasks) لدمج خيارات متعددة معاً باستخدام عمليات البت (`|` و `&`):

```gdscript
enum Abilities {
    NONE        = 0,
    DOUBLE_JUMP = 1 << 0, # 1
    DASH        = 1 << 1, # 2
    WALL_SLIDE  = 1 << 2, # 4
    SWIM        = 1 << 3  # 8
}

var unlocked_abilities: int = Abilities.DOUBLE_JUMP | Abilities.DASH

# فحص ما إذا كانت قدرة معينة مفعلة
func can_dash() -> bool:
    return (unlocked_abilities & Abilities.DASH) != 0

# إضافة قدرة جديدة
func unlock_swim():
    unlocked_abilities |= Abilities.SWIM

# إزالة قدرة
func lock_dash():
    unlocked_abilities &= ~Abilities.DASH
```

---

### و. الوصول إلى Enums من سكربتات وأصناف أخرى

إذا كان الصنف مسجلاً باستخدام `class_name`، يمكنك استخدام الـ Enum الخاص به في أي سكربت آخر في المشروع:

```gdscript
# في ملف Enemy.gd
class_name Enemy
extends CharacterBody2D

enum EnemyRank { MINION, ELITE, BOSS }

# في ملف GameController.gd أو أي ملف آخر
func spawn_enemy():
    var rank: Enemy.EnemyRank = Enemy.EnemyRank.BOSS
    print("الرتبة: ", rank)
```

---

### ز. التعدادات العامة المدمجة في المحرك (`@GlobalScope`)

يوفر محرك Godot مئات التعدادات المدمجة الجاهزة التي يمكن استخدامها مباشرة في أي مكان:

| التعداد المدمج | أمثلة على القيم | الاستخدام |
| :--- | :--- | :--- |
| `Key` | `KEY_ESCAPE`, `KEY_SPACE`, `KEY_ENTER` | أزرار لوحة المفاتيح |
| `MouseButton` | `MOUSE_BUTTON_LEFT`, `MOUSE_BUTTON_RIGHT` | أزرار الفأرة |
| `JoyButton` | `JOY_BUTTON_A`, `JOY_BUTTON_B` | أزرار أجهزة التحكم |
| `Error` | `OK`, `FAILED`, `ERR_FILE_NOT_FOUND` | رموز الأخطاء الناتجة عن العمليات |
| `HorizontalAlignment` | `HORIZONTAL_ALIGNMENT_LEFT`, `CENTER` | محاذاة النصوص |
| `Side` | `SIDE_LEFT`, `SIDE_TOP`, `SIDE_RIGHT`, `SIDE_BOTTOM` | اتجاهات الجوانب والهوامش |
