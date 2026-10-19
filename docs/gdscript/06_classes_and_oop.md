# البرمجة كائنية التوجه والأصناف في GDScript (Classes & OOP)

> **المصدر الرسمي:**
>
> - [GDScript Reference — Classes & OOP](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html#classes)
> - [Godot Engine — Scripting and Object-Oriented Principles](https://docs.godotengine.org/en/stable/tutorials/best_practices/what_are_godot_classes.html)

كل ملف سكربت (`.gd`) في Godot يمثل في حد ذاته **صنفاً غير مسمى (Unnamed Class)** بشكل افتراضي، ويرث عادة من صنف آخر مثل `Node` أو `Resource` أو `RefCounted`.

---

## 1. تعريف الأصناف والوراثة (`class_name` & `extends`)

### أ. تسجيل الصنف بنوع عالمي (`class_name`)

عند استخدام `class_name`، يصبح السكربت نوعاً عاماً (Global Type) معروفاً في المحرك، ويظهر كعقدة مخصصة في قائمة "Create New Node" ويمكن استخدامه كنوع بيانات صارم في السكربتات الأخرى:

```gdscript
# Player.gd
class_name Player
extends CharacterBody2D

@export var player_name: String = "Hero"
```

### ب. الوراثة (`extends`)

يحدد الصنف الأب الذي يرث منه هذا السكربت خصائصه ودواله:

```gdscript
# وراثة من صنف مدمج
extends Sprite2D

# أو وراثة من سكربت مخصص بالاسم العالمي
extends Player

# أو وراثة من ملف سكربت بمساره
extends "res://scripts/base_enemy.gd"
```

---

## 2. الأصناف الداخلية (Inner Classes)

يمكن تعريف أصناف إضافية داخل نفس السكربت باستخدام الكلمة `class`:

```gdscript
# main_game.gd
extends Node

# صنف داخلي
class InventoryItem:
    var item_id: String
    var quantity: int

    func _init(id: String, qty: int = 1):
        item_id = id
        quantity = qty

# إنشاء نسخ من الصنف الداخلي
func _ready():
    var potion = InventoryItem.new("potion_health", 5)
    print(potion.item_id, ": ", potion.quantity)
```

---

## 3. دالة البناء واستدعاء الصنف الأب (`_init` & `super`)

### أ. دالة البناء `_init()`

تُستدعى تلقائياً فور إنشاء كائن جديد بواسطة `MyClass.new()`:

```gdscript
class_name Weapon
extends RefCounted

var weapon_name: String
var damage: int

# دالة البناء مع معلمات اختيارية
func _init(name: String = "قبضة", dmg: int = 1):
    weapon_name = name
    damage = dmg
```

### ب. استدعاء دوال الصنف الأب باستخدام `super`

في Godot 4، يتم استخدام الكلمة المحجوزة `super` للوصول إلى دوال الصنف الأب:

```gdscript
class_name MagicWeapon
extends Weapon

var mana_cost: int

func _init(name: String, dmg: int, cost: int).(name, dmg): # طريقة Godot 3 (قديمة)
    pass

# في Godot 4 يتم استدعاء بناء الأب كالتالي:
func _init(name: String, dmg: int, cost: int):
    super(name, dmg) # تمرير المعلمات لدالة بناء الأب
    mana_cost = cost

func attack():
    super.attack() # استدعاء دالة attack الأصلية من الأب
    cast_spell()
```

---

## 4. دوال دورة حياة الكائنات في شجرة المشهد (Lifecycle Virtual Methods)

توفر عقد المحرك (Nodes) مجموعة من الدوال الافتراضية التي يستدعيها محرك Godot تلقائياً في مراحل محددة:

| الدالة | توقيت الاستدعاء | الوصف |
| :--- | :--- | :--- |
| `_enter_tree()` | عند دخول العقدة شجرة المشهد | مفيد لتهيئة التبعيات المرتبطة بالشجرة |
| `_ready()` | بعد دخول العقدة وجميع أبنائها للشجرة | أفضل مكان لتهيئة كود العقدة والبحث عن الأبناء |
| `_process(delta: float)` | مع كل إطار رسم (Frame) | لتحديث المنطق والحركة غير الفيزيائية |
| `_physics_process(delta)` | مع كل خطوة فيزيائية بمعدل ثابت | لحسابات الفيزياء وتصادمات الأجسام |
| `_input(event: InputEvent)` | عند استقبال أي حدث إدخال | لقراءة لوحة المفاتيح والماوس وشاشات اللمس |
| `_unhandled_input(event)` | أحداث الإدخال غير المعالجة بواسطة واجهة المستخدم | ممتاز لأزرار اللعبة والتحكم بالشخصية |
| `_exit_tree()` | عند إزالة العقدة من شجرة المشهد | لتنظيف الموارد وإلغاء الاشتراكات |

```gdscript
extends CharacterBody2D

func _ready() -> void:
    print("العقدة أصبحت جاهزة تماماً في الشجرة")

func _physics_process(delta: float) -> void:
    # حركة بمعدل فيزيائي ثابت (مثلاً 60 هرتز)
    velocity.y += 980.0 * delta
    move_and_slide()
```

---

## 5. الخصائص ودوال الوصول والتعديل (Properties & Getters/Setters)

يقدم Godot 4 بناء جملة أنيق وعصري ومباشر لخصائص الكائنات:

```gdscript
class_name HealthComponent
extends Node

# خاصية مع Getter و Setter مدمجين
var health: int = 100:
    get:
        return health
    set(new_value):
        var old_health = health
        health = clamp(new_value, 0, max_health)
        if health != old_health:
            health_changed.emit(health)

var max_health: int = 100

# صيغة السطر الواحد المختصرة (Inline)
var score: int = 0:
    set(v): score = max(0, v)
```

---

## 6. الأعضاء الثابتة (Static Members: `static func` & `static var`)

الأعضاء الثابتة تتبع الصنف نفسه ولا تتطلب إنشاء نسخة (`instance`) من الصنف للوصول إليها.

```gdscript
class_name MathUtils
extends RefCounted

# متغير ثابت مشترك بين جميع النسخ (ميزة في Godot 4.1+)
static var active_instances_count: int = 0

# دالة مساعدة ثابتة
static func add(a: float, b: float) -> float:
    return a + b

static func is_even(num: int) -> bool:
    return num % 2 == 0
```

### استخدام الأعضاء الثابتة من أي مكان

```gdscript
var result = MathUtils.add(10.5, 4.5)
print(result) # 15.0
```

---

## 7. المرجع الذاتي `self`

تشير الكلمة المحجوزة `self` إلى نسخة الكائن الحالية:

```gdscript
func set_target(target: Node2D):
    # استخدام self للتفريق بين المعلمة وخاصية الكائن إذا تشابهت الأسماء
    # أو لتمرير الكائن الحالي لمعالج آخر
    target.track(self)
```
