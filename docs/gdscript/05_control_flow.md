# التحكم بالتدفق والشروط والتكرار في GDScript (Control Flow)

> **المصدر الرسمي:**
>
> - [GDScript Reference — Control Flow](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html#control-flow)
> - [GDScript Reference — Pattern Matching](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html#match)

تعتمد لغة GDScript على المسافات البادئة (Indentation) لتحديد كتل الكود (Blocks)، تماماً مثل لغة Python.

---

## 1. الشروط: `if`, `elif`, `else`

تُستخدم لتنفيذ أجزاء معينة من الكود بناءً على شروط منطقية:

```gdscript
var health = 75

if health <= 0:
    print("اللاعب مهزوم")
elif health < 25:
    print("الصحة حرجة للغاية!")
elif health < 50:
    print("الصحة متوسطة")
else:
    print("الصحة ممتازة")
```

### العامل الشرطي الثلاثي (Ternary Operator)

يتيح كتابة الشروط البسيطة في سطر واحد وإرجاع قيمة:

```gdscript
# الصيغة: (قيمة إذا تحقق الشرط) if (الشرط) else (قيمة إذا لم يتحقق)
var status = "حي" if is_alive else "ميت"
var max_val = a if a > b else b
```

---

## 2. مطابقة الأنماط المتقدمة: `match`

تعتبر عبارة `match` في GDScript بديلاً أقوى بكثير من جملة `switch-case` التقليدية في اللغات الأخرى، حيث تدعم مطابقة القيمة، والأنماط، والمصفوفات، والقواميس، وحراس الشروط (`when`).

### أ. المطابقة البسيطة والمتعددة والرمز البديل (`_`)

```gdscript
var command = "start"

match command:
    "start":
        start_game()
    "quit", "exit":  # مطابقة عدة قيم لنفس النتيجة
        quit_game()
    _:               # الرمز البديل (Wildcard) يعادل Default
        print("أمر غير معروف")
```

### ب. ربط المتغيرات (Variable Binding)

يمكنك استخراج القيمة وتخزينها في متغير محلي جديد داخل كتلة المطابقة:

```gdscript
var data = 15

match data:
    1:
        print("واحد")
    var n: # يتم ربط أي قيمة أخرى بالمتغير n
        print("القيمة هي: ", n)
```

### ج. حراس الأنماط باستخدام `when` (Pattern Guards)

في Godot 4، يمكنك إضافة شرط منطقي إضافي للنمط باستخدام الكلمة المحجوزة `when`:

```gdscript
var score = 85

match score:
    var s when s >= 90:
        print("ممتاز - مرتبة الشرف")
    var s when s >= 75:
        print("جيد جداً")
    var s when s >= 50:
        print("ناجح")
    _:
        print("راسب")
```

### د. مطابقة المصفوفات (Array Patterns)

```gdscript
var coordinates = [10, 20]

match coordinates:
    [0, 0]:
        print("في نقطة الأصل")
    [var x, 0]:
        print("على محور X عند: ", x)
    [0, var y]:
        print("على محور Y عند: ", y)
    [var x, var y]:
        print("في الإحداثيات: ", x, ", ", y)
    [var first, ..]: # علامة .. تعني مطابقة باقي العناصر بأي طول
        print("أول عنصر هو: ", first)
```

### هـ. مطابقة القواميس (Dictionary Patterns)

```gdscript
var message = {"type": "attack", "damage": 25}

match message:
    {"type": "heal", "amount": var amt}:
        heal_player(amt)
    {"type": "attack", "damage": var dmg}:
        apply_damage(dmg)
    _:
        print("رسالة غير صالحة")
```

---

## 3. الحلقات التكرارية (Loops)

### أ. حلقة `for`: التكرار عبر المجالات والمجموعات

#### 1. التكرار عبر مجال أرقام باستخدام `range()`

```gdscript
# من 0 إلى 4 (5 مرات)
for i in range(5):
    print(i) # يطبع 0, 1, 2, 3, 4

# من 2 إلى 8 بخطوة افتراضية 1
for i in range(2, 9):
    print(i) # 2, 3, 4, 5, 6, 7, 8

# بقفزة مخصصة (Step)
for i in range(10, 0, -2):
    print(i) # 10, 8, 6, 4, 2
```

#### 2. التكرار عبر المصفوفات (Arrays)

```gdscript
var weapons = ["سيف", "قوس", "رمح"]

for weapon in weapons:
    print("السلاح المتاح: ", weapon)
```

#### 3. التكرار عبر القواميس (Dictionaries)

```gdscript
var inventory = {"خشب": 10, "حديد": 3, "ذهب": 1}

# التكرار عبر المفاتيح
for item in inventory:
    print(item, ": ", inventory[item])
```

#### 4. التكرار عبر النصوص (Strings)

```gdscript
for char in "Godot":
    print(char)
```

---

### ب. حلقة `while`: التكرار الشرطي

تستمر الحلقة في العمل طالما أن الشرط يُرجع `true`:

```gdscript
var count = 3

while count > 0:
    print("العد التنازلي: ", count)
    count -= 1

print("انطلاق!")
```

---

## 4. التحكم داخل الحلقات: `break` و `continue`

| الأمر | الوصف | مثال |
| :--- | :--- | :--- |
| `break` | إنهاء الحلقة فوراً والخروج منها | عند العثور على العنصر المطلوب |
| `continue` | تخطي الدورة الحالية والانتقال فوراً للدورة التالية | لتجاهل عناصر غير صالحة |

```gdscript
for i in range(10):
    if i == 3:
        continue # تخطي الرقم 3
    if i == 7:
        break    # إيقاف الحلقة تماماً عند الوصول للرقم 7
    print(i)
```

---

## 5. العبارة الفارغة `pass` والإرجاع `return`

### `pass`

تُستخدم كعنصر نائب (Placeholder) عندما تتطلب قواعد اللغة وجود سطر برمجي لكنك لا تريد تنفيذ أي أمر حالياً:

```gdscript
func _on_timer_timeout():
    pass # سيتم كتابة المنطق لاحقاً
```

### `return`

تُنهي تنفيذ الدالة فوراً، مع إرجاع قيمة اختيارية:

```gdscript
func get_bonus(level: int) -> int:
    if level < 5:
        return 0
    return level * 10
```
