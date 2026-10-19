# التكامل مع شجرة المشهد والعقد في GDScript (SceneTree & Nodes Integration)

> **المصادر الرسمية:**
>
> - [Godot Docs — SceneTree & Node Architecture](https://docs.godotengine.org/en/stable/getting_started/step_by_step/nodes_and_scenes.html)
> - [Godot Docs — Scene Unique Nodes](https://docs.godotengine.org/en/stable/tutorials/scripting/scene_unique_nodes.html)
> - [Godot Engine — Node Class Reference](https://docs.godotengine.org/en/stable/classes/class_node.html)
> - [Godot Engine — Object Notifications](https://docs.godotengine.org/en/stable/classes/class_object.html#constants)

تتميز لغة GDScript بأنها صُممت خصيصاً للتناغم المباشر مع محرك Godot وبنية **شجرة المشهد (SceneTree)** والعقد (**Nodes**)، حيث تحتوي اللغة على صيغ نحوية مدمجة (Syntactic Sugar) للتعامل مع العقد ومساراتها بأعلى كفاءة.

---

## 1. صيغ الاختصار النحوية للعقد (Node Shorthand Syntax)

توفر GDScript معاملات واختصارات سريعة كبديل مباشر ومختصر لدالة `get_node(...)`:

### أ. معامل الدولار (`$`) للوصول السريع

```gdscript
extends Node2D

func _ready():
    # يعادل: get_node("Sprite2D")
    $Sprite2D.visible = true

    # الوصول لعقدة فرعية أعمق في الشجرة
    $UI/HUD/ScoreLabel.text = "100"

    # الوصول لعقدة شقيقة أو الأب باستخدام علامات المسار
    $"../Player".position = Vector2.ZERO
    
    # عندما يحتوي اسم العقدة على مسافات أو رموز خاصة، يجب وضع علامات تنصيص:
    $"Left Arm/Hand".rotate(0.1)
```

### ب. العقد ذات الأسماء الفريدة (Scene Unique Nodes `%`)

في المشاريع الكبيرة، إذا قمت بتغيير ترتيب العقد في المشهد، فإن المسارات النسبية المكتوبة بـ `$` قد تنكسر وتسبب أخطاء.
لحل هذه المشكلة، يوفر Godot ميزة **Unique Name**. عند تفعيل خيار "Access as Unique Name" لأي عقدة في المشهد، تظهر علامة `%` بجانبها، وتستطيع الوصول إليها من أي سكربت داخل نفس المشهد أينما كان موقعها:

```gdscript
extends Node2D

func _ready():
    # الوصول المباشر للعقدة الفريدة بصرف النظر عن عمقها أو مكانها في الشجرة
    %PlayerHealthBar.value = 100
    %GameOverScreen.hide()

    # يمكن استخدامها مع @onready للتخزين المسبق:
    # @onready var health_bar: ProgressBar = %PlayerHealthBar
```

---

## 2. محددات السلاسل الحرفية الخاصة (`&` و `^`)

توفر لغة GDScript نوعين خاصين من السلاسل الحرفية ذات المعاملات البادئة:

### أ. الـ StringName الحرفي (`&"name"`)

نوع نصي فريد وغير قابل للتعديل (Immutable) يتم حفظه في جدول التجزئة الداخلي للمحرك، وتتم مقارنته عبر عنوان الذاكرة مباشرة بدلاً من مقارنة الحروف، مما يجعله فائق السرعة:

```gdscript
# بادئة & تنشئ كائن StringName مباشرة
var anim_name: StringName = &"walk_cycle"
var action: StringName = &"jump"

# استخدامها في مقارنات الإدخال والإشارات أسرع بكثير من String العادي
if event.is_action_pressed(&"ui_accept"):
    pass
```

### ب. الـ NodePath الحرفي (`^"path"`)

يمثل مساراً منظماً ومفهرساً بين العقد في شجرة المشهد:

```gdscript
# بادئة ^ تنشئ كائن NodePath مباشرة
var child_path: NodePath = ^"Weapons/Sword"
var parent_path: NodePath = ^".."

var sword_node = get_node(child_path)
```

---

## 3. الترتيب الدقيق لدورة حياة العقد (Lifecycle Execution Order)

يستدعي محرك Godot الدوال الافتراضية للعقد في ترتيب زمني صارم ومنظم:

```
[ إنشاء الكائن ] ----------> _init()  (أولاً للجميع عند الاستدعاء .new())
                               |
[ الإضافة للشجرة ] --------> _enter_tree()  (من الأعلى للأسفل: الأب أولاً ثم الأبناء)
                               |
[ اكتمال الجاهزية ] -------> _ready()  (من الأسفل للأعلى: الأبناء يكتملون أولاً ثم الأب)
                               |
[ حلقة اللعبة المستمرة ] ---> _process(delta) / _physics_process(delta)
                               |
[ الحذف والإزالة ] ---------> _exit_tree()  (عند مغادرة شجرة المشهد)
```

> [!IMPORTANT]
> **قاعدة ذهبية في `_ready()`**: يتم استدعاء `_ready()` من **الأسفل إلى الأعلى (Bottom-Up)**؛ أي أن جميع العقد الأبناء تصبح جاهزة تماماً قبل أن يُستدعى `_ready()` الخاص بالعقدة الأب. هذا يضمن أن الأب يستطيع الاعتماد على جهوزية جميع أبنائه بأمان داخل `_ready()`.

---

## 4. نظام الإشعارات المنخفضة (`_notification`)

توفر لغة GDScript دالة افتراضية خاصة لاستقبال إشعارات المحرك العامة بدون الحاجة للربط بإشارات منفصلة:

```gdscript
extends Node

func _notification(what: int) -> void:
    match what:
        NOTIFICATION_ENTER_TREE:
            print("دخلت العقدة شجرة المشهد")
            
        NOTIFICATION_READY:
            print("العقدة أصبحت جاهزة تماماً")
            
        NOTIFICATION_PAUSED:
            print("تم إيقاف اللعبة مؤقتاً")
            
        NOTIFICATION_UNPAUSED:
            print("تم استئناف اللعبة")
            
        NOTIFICATION_WM_CLOSE_REQUEST:
            print("اللاعب يحاول إغلاق نافذة اللعبة")
            # حفظ التقدم قبل الخروج
            save_game_state()
            get_tree().quit()
            
        NOTIFICATION_PREDELETE:
            print("العقدة على وشك التدمير والمسح من الذاكرة")
```

---

## 5. إنشاء وتفريخ المشاهد برمجياً (Scene Instantiation)

المشاهد في Godot تُحفظ كملفات `.tscn`، ويتم تمثيلها في الذاكرة ككائن `PackedScene`. لتفريخ مشهد داخل اللعبة:

```gdscript
extends Node2D

# 1. تحميل المشهد مسبقاً كـ PackedScene
const BULLET_SCENE: PackedScene = preload("res://scenes/bullet.tscn")

func shoot(spawn_pos: Vector2, shoot_direction: Vector2):
    # 2. إنشاء نسخة حية من المشهد (Instantiate)
    var bullet = BULLET_SCENE.instantiate() as Node2D
    
    # 3. تعديل خصائص النسخة قبل إضافتها
    bullet.position = spawn_pos
    bullet.rotation = shoot_direction.angle()
    
    # 4. إضافة النسخة إلى شجرة المشهد كعقدة ابن
    add_child(bullet)
```

---

## 6. نظام المجموعات (Node Groups)

تسمح المجموعات بتصنيف العقد برمجياً لاستدعاء دوالها معاً أو استهدافها بشكل جماعي بدون معرفة مساراتها:

```gdscript
# إضافة العقدة الحالية لمجموعة
func _ready():
    add_to_group("enemies")
    add_to_group("minimap_targets")

# استدعاء دالة جماعية على كل العقد الموجودة في المجموعة
func trigger_earthquake():
    # استدعاء دالة take_damage(50) على كل عقدة في مجموعة enemies
    get_tree().call_group("enemies", "take_damage", 50)

# جلب مصفوفة العقد الأعضاء في المجموعة
func get_alive_enemies_count() -> int:
    var all_enemies: Array[Node] = get_tree().get_nodes_in_group("enemies")
    return all_enemies.size()
```
