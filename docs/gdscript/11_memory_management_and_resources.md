# إدارة الذاكرة والموارد المخصصة في GDScript (Memory Management & Custom Resources)

> **المصادر الرسمية:**
>
> - [Godot Docs — Object Memory Management](https://docs.godotengine.org/en/stable/tutorials/best_practices/what_are_godot_classes.html#memory-management)
> - [Godot Engine — RefCounted Class Reference](https://docs.godotengine.org/en/stable/classes/class_refcounted.html)
> - [Godot Engine — Custom Resources](https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html)
> - [Godot Engine — WeakRef Documentation](https://docs.godotengine.org/en/stable/classes/class_weakref.html)

تعتمد إدارة الذاكرة في GDScript ومحرك Godot على نموذج هجين يجمع بين **إدارة الذاكرة التلقائية بعداد المراجع (Reference Counting)** و**التحكم اليدوي المباشر بدورة حياة العقد (Manual / Tree Ownership)**.

---

## 1. التسلسل الهرمي لكائنات المحرك (The Class Hierarchy)

تنحدر جميع الكائنات في Godot من الصنف الأساسي `Object`:

```text
                 Object (إدارة يدوية للذاكرة)
                /      \
      RefCounted        Node (مرتبطة بشجرة المشهد)
          |                |
       Resource         Node2D / Node3D / Control
```

### المقارنة الجوهرية بين الأنواع الأساسية

| الخاصية | `Object` | `RefCounted` | `Resource` | `Node` |
| :--- | :--- | :--- | :--- | :--- |
| **إدارة الذاكرة** | يدوية تماماً | تلقائية (Reference Counting) | تلقائية (يرث `RefCounted`) | عبر شجرة المشهد (Tree Ownership) |
| **طريقة الحذف** | `free()` يدوياً | تُحذف تلقائياً عندما يصبح عدد المراجع 0 | تُحذف تلقائياً عند انتهاء مراجعها | `queue_free()` أو حذف العقدة الأب |
| **التخزين في ملفات** | لا | لا | نعم (`.tres` / `.res`) | نعم كجزء من المشهد (`.tscn`) |
| **الاستخدام الشائع** | كائنات داخلية منخفضة المستوى | هياكل بيانات، أدوات مساعدة، خوارزميات | بيانات اللعبة المشتركة، الإعدادات، الأصول | كائنات اللعبة المرئية، الشخصيات، الكاميرات |

---

## 2. إدارة الذاكرة التلقائية (`RefCounted`)

يرث أي سكربت لا يحدد `extends` صنف `RefCounted` افتراضياً:

```gdscript
#a سكربت بدون extends يعتبر RefCounted تلقائياً
class_name PlayerStats
# يعادل: extends RefCounted

var attack: int = 10
var defense: int = 5
```

### كيف يعمل عداد المراجع؟

1. عند إنشاء الكائن (`PlayerStats.new()`)، يصبح عداد المراجع له = 1.
2. عند إسناد الكائن إلى متغير أو تمريره لدالة أو حفظه بمصفوفة، يزيد العداد بمقدار 1.
3. عند خروج المتغير من نطاقه (Scope) أو استبدال قيمته بـ `null`، ينقص العداد بمقدار 1.
4. بمجرد وصول العداد إلى **0**، يقوم محرك Godot بتحرير الكائن ومسحه من الذاكرة فوراً وتلقائياً.

---

## 3. مشكلة المراجع الدائرية والمراجع الضعيفة (WeakRef)

### أ. فخ المراجع الدائرية (Cyclic References)

إذا أشار كائن `A` إلى كائن `B`، وفي نفس الوقت أشار كائن `B` إلى كائن `A`، فلن يصل عداد المراجع لأي منهما إلى الصفر أبداً، مما يسبب **تسريباً في الذاكرة (Memory Leak)**:

```gdscript
#a مثال يسبب تسريباً:
class NodeA extends RefCounted:
    var other: RefCounted

class NodeB extends RefCounted:
    var other: RefCounted

func create_leak():
    var a = NodeA.new()
    var b = NodeB.new()
    a.other = b
    b.other = a
    # عند الخروج من الدالة، سيبقى كل منهما ممسكاً بالآخر ولن يُحذف أي منهما!
```

### ب. الحل: استخدام المراجع الضعيفة (`WeakRef`)

المرجع الضعيف هو كائن يشير إلى كائن آخر **دون زيادة عداد المراجع الخاص به**:

```gdscript
var original_obj = RefCounted.new()

# إنشاء مرجع ضعيف
var weak_reference: WeakRef = weakref(original_obj)

# عند الحاجة للوصول للكائن:
var obj = weak_reference.get_ref()
if obj:
    print("الكائن ما زال حياً في الذاكرة!")
else:
    print("تم حذف الكائن من الذاكرة بالفعل")
```

---

## 4. التحقق من صلاحية الكائنات وحذفها بأمان (`Object` & `Node`)

### أ. الفرق بين `free()` و `queue_free()`

- **`free()`**: يحذف الكائن من الذاكرة فوراً في نفس السطر. إذا كانت العقدة في شجرة المشهد وتستقبل إشارات أو تنفذ كوداً، فقد يسبب استدعاء `free()` انهيار اللعبة (Crash).
- **`queue_free()`**: يُفضل دائماً مع العقد (`Node`). يطلب من المحرك جدولة حذف العقدة في نهاية الإطار الحالي بعد انتهاء جميع العمليات الجارية بأمان.

```gdscript
#a حذف رصاصة أو عدو بأمان عند انتهاء مهمته
func _on_hit():
    queue_free()
```

### ب. فحص سلامة الكائن عبر `is_instance_valid`

عند حذف كائن من الذاكرة، فإن المتغيرات التي كانت تشير إليه تتحول إلى مراجع ميتة (Dangling Pointers). فحص `if obj != null` **لا يكفي** لأنه قد لا يُرجع `false`. الطريقة الصحيحة والمضمونة رسمياً هي:

```gdscript
var target_enemy: Node2D = null

func attack():
    # الفحص الآمن قبل استدعاء أي دالة أو خاصية
    if is_instance_valid(target_enemy):
        target_enemy.take_damage(25)
    else:
        print("الهدف لم يعد موجوداً في اللعبة")
        target_enemy = null
```

---

## 5. نظام الموارد المخصصة (Custom Resources)

الموارد (`Resource`) هي كائنات ترث `RefCounted`، ومصممة خصيصاً لتخزين البيانات وحفظها على القرص بصيغة نصية (`.tres`) أو ثنائية (`.res`).

### أ. تعريف مورد مخصص

```gdscript
# ItemData.gd
class_name ItemData
extends Resource

@export var item_name: String = ""
@export var icon: Texture2D
@export_range(1, 99) var max_stack: int = 1
@export var buy_price: int = 10
@export var sell_price: int = 5
@export_multiline var description: String = ""
```

بمجرد حفظ هذا الملف مع `class_name ItemData`، يصبح هذا المورد نوعاً رسمياً متاحاً في نافذة "Create New Resource" ومفتش المحرر (Inspector).

### ب. إنشاء واستخدام المورد برمجياً

```gdscript
func create_sample_item() -> ItemData:
    var potion = ItemData.new()
    potion.item_name = "جرعة علاج"
    potion.max_stack = 20
    potion.buy_price = 50
    return potion
```

### ج. حفظ وتحميل الموارد من القرص

```gdscript
#a 1. حفظ المورد في ملف
func save_custom_item(item: ItemData, file_path: String) -> Error:
    var err: Error = ResourceSaver.save(item, file_path)
    if err == OK:
        print("تم حفظ المورد بنجاح في: ", file_path)
    else:
        printerr("فشل الحفظ بكود الخطأ: ", err)
    return err

# 2. تحميل المورد أثناء التشغيل
func load_custom_item(file_path: String) -> ItemData:
    if ResourceLoader.exists(file_path):
        var loaded_item = ResourceLoader.load(file_path) as ItemData
        return loaded_item
    return null
```

---

## 6. مشاركة الموارد وتكرارها (Shared vs Unique Resources)

> [!WARNING]
> الموارد في Godot تكون **مشتركة (Shared by default)**. إذا قمت بتحميل نفس المورد في 10 أعداء مختلفين، فإن تعديل خاصية في أحدهم سيغيرها في الـ 9 الباقين لأنهم يشاركون نفس النسخة في الذاكرة!

### أ. إنشاء نسخة فريدة ومستقلة (`duplicate`)

عندما تحتاج أن يمتلك كل عدو نسخته الخاصة المستقلة من المورد (مثلاً: لتعديل طاقته دون التأثير على الآخرين):

```gdscript
extends CharacterBody2D

@export var base_stats: ItemData
var stats: ItemData

func _ready():
    if base_stats:
        # إنشاء نسخة منفصلة فريدة تماماً
        # المعلمة true تعني تكرار الموارد الفرعية المضمنة أيضاً (Deep Copy)
        stats = base_stats.duplicate(true)
```

### ب. خيار "Local to Scene" للموارد

في محرر Godot، داخل خصائص أي مورد، يمكنك تفعيل خيار **"Local to Scene"**. هذا يجعل المشهد يقوم بإنشاء نسخة فريدة من المورد تلقائياً لكل نسخة مشهد يتم إنشاؤها في اللعبة.
