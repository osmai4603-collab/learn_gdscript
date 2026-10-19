# الدوال ككائنات مستقلة، دوال اللامبدا والإغلاقات في GDScript (Callable, Lambdas & Closures)

> **المصادر الرسمية:**
>
> - [Godot Docs — GDScript Basics: Lambda Functions](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html#lambda-functions)
> - [Godot Engine — Callable Class Reference](https://docs.godotengine.org/en/stable/classes/class_callable.html)
> - [Godot Engine — Functional Programming & Collections](https://docs.godotengine.org/en/stable/classes/class_array.html)

في **Godot 4**، أصبحت الدوال كائنات من الدرجة الأولى (**First-Class Citizens**). هذا يعني أنه يمكن تخزين الدوال في متغيرات، وتمريرها كمعاملات لدوال أخرى، وإرجاعها كقيم، واستدعاؤها ديناميكياً باستخدام نوع البيانات المدمج **`Callable`**.

---

## 1. دوال اللامبدا والدوال مجهولة الاسم (Lambda / Anonymous Functions)

دالة اللامبدا هي دالة تُعرّف بدون الحاجة لتسجيلها كدالة صنف رسمية. تبدأ بالكلمة المحجوزة `func` متبوعة بقائمة المعاملات ونوع الإرجاع وجسم الدالة:

### أ. الصيغة الأساسية للـ Lambda

```gdscript
# دالة لامبدا بسيطة في سطر واحد
var add = func(a: int, b: int) -> int: return a + b

# استدعاء الدالة عبر .call()
var sum = add.call(10, 20)
print(sum) # 30
```

### ب. دوال لامبدا متعددة الأسطر

```gdscript
var calculate_grade = func(score: float) -> String:
    if score >= 90.0:
        return "ممتاز"
    elif score >= 75.0:
        return "جيد جداً"
    elif score >= 50.0:
        return "ناجح"
    else:
        return "راسب"

print(calculate_grade.call(82.5)) # جيد جداً
```

### ج. دوال اللامبدا المسماة محلياً (Named Lambdas)

يمكن اختيارياً إعطاء اللامبدا اسماً داخلياً يفيد في أمرين:

1. إظهار الاسم بوضوح في تتبع الأخطاء (Stack Trace).
2. استدعاء الدالة لنفسها بالتكرار الذاتي (Recursion):

```gdscript
# دالة حساب المضروب (Factorial) بالتكرار الذاتي
var factorial = func fact(n: int) -> int:
    if n <= 1:
        return 1
    return n * fact.call(n - 1)

print(factorial.call(5)) # 120
```

---

## 2. الإغلاقات وحبس النطاق (Closures & Variable Capturing)

تمتلك دوال اللامبدا في GDScript 4 ميزة **الإغلاق (Closure)**، مما يعني أنها تستطيع قراءة واستخدام المتغيرات المعرفة في النطاق الخارجي (Enclosing Scope) وقت إنشائها.

### أ. التقاط المتغيرات الخارجية

```gdscript
func make_greeter(prefix: String) -> Callable:
    # تلتقط اللامبدا المتغير prefix من دالة make_greeter
    return func(name: String) -> String:
        return prefix + "، " + name + "!"

var welcome = make_greeter("أهلاً وسهلاً")
var farewell = make_greeter("وداعاً")

print(welcome.call("زيد"))  # أهلاً وسهلاً، زيد!
print(farewell.call("زيد")) # وداعاً، زيد!
```

### ب. سلوك التقاط المتغيرات (Capture Semantics)

- المتغيرات الأولية (`int`, `float`, `String`, إلخ) يتم التقاطها **بالقيمة (By Value)** عند لحظة إنشاء دالة اللامبدا.
- الكائنات والمصفوفات والقواميس يتم التقاط مراجعها (**By Reference**)، وأي تعديل على محتواها الداخلي ينعكس داخل اللامبدا وخارجها:

```gdscript
var scores = [10, 20]

var add_score = func(val: int):
    scores.append(val)

add_score.call(30)
print(scores) # [10, 20, 30]
```

---

## 3. نوع البيانات `Callable` وواجهته البرمجية

يمثل كائن `Callable` مؤشراً قابلاً للاستدعاء لأي دالة، سواء كانت:

1. دالة عادية في صنف أو عقدة (`self.my_method` أو `Callable(self, "my_method")`).
2. دالة مدمجة في المحرك.
3. دالة لامبدا مجهولة أو مسمّاة.

### أهم دوال وميثودات كائن `Callable`

| الدالة | الوصف |
| :--- | :--- |
| `call(...) -> Variant` | استدعاء الدالة فوراً مع تمرير المعاملات. |
| `call_deferred(...) -> void` | تأجيل استدعاء الدالة حتى وقت الخمول (Idle Time) في نهاية الإطار الحالي. |
| `callv(arguments: Array) -> Variant` | استدعاء الدالة مع تمرير المعاملات كمصفوفة. |
| `bind(...) -> Callable` | إنشاء نسخة `Callable` جديدة مع ربط وسائط مسبقة في نهاية قائمة المعاملات. |
| `bindv(arguments: Array) -> Callable` | نفس `bind` ولكن بتمرير الوسائط كمصفوفة. |
| `unbind(argcount: int) -> Callable` | إنشاء نسخة تتجاهل عدداً محدداً من المعاملات من النهاية عند استدعائها. |
| `is_valid() -> bool` | التحقق من أن الكائن المستهدف ما زال حياً وأن الدالة موجودة. |
| `is_null() -> bool` | هل كائن `Callable` فارغ أو غير معين. |
| `is_custom() -> bool` | هل هو دالة مخصصة (مثل Lambda أو دالة مربوطة عبر `bind`) أم ميثود محرك أصلي. |
| `get_object() -> Object` | إرجاع مرجع الكائن صاحب الدالة (إذا لم تكن Lambda). |
| `get_method() -> StringName` | إرجاع اسم الدالة المربوطة. |

### أمثلة عملية على ميثودات `Callable`

```gdscript
func print_info(title: String, score: int, is_winner: bool):
    print(title, " | النتيجة: ", score, " | فوز: ", is_winner)

func _ready():
    # إنشاء مؤشر للدالة
    var fn: Callable = self.print_info
    
    # ربط المعامل الأخير (is_winner = true) مسبقاً
    var winner_fn: Callable = fn.bind(true)
    
    # الآن عند الاستدعاء نمرر أول معاملين فقط
    winner_fn.call("اللاعب 1", 100) # اللاعب 1 | النتيجة: 100 | فوز: true
```

---

## 4. البرمجة الوظيفية ومعالجة الحاويات (Higher-Order Functions)

تدعم مصفوفات Godot 4 نمط البرمجة الوظيفية باستخدام `Callable` و `Lambda` لمعالجة البيانات بسلاسة وسرعة:

### أ. التحويل والتخطيط (`map`)

تطبيق دالة على كل عنصر لإنتاج مصفوفة جديدة بنفس الطول:

```gdscript
var numbers = [1, 2, 3, 4, 5]
var doubled = numbers.map(func(n: int) -> int: return n * 2)
print(doubled) # [2, 4, 6, 8, 10]
```

### ب. التصفية والفلترة (`filter`)

استخراج العناصر التي تحقق شرطاً معيناً:

```gdscript
var scores = [45, 80, 92, 30, 65]
var passing = scores.filter(func(s: int) -> bool: return s >= 50)
print(passing) # [80, 92, 65]
```

### ج. التجميع والتقليص (`reduce`)

دمج عناصر المصفوفة في قيمة واحدة تراكمية:

```gdscript
var prices = [10, 25, 40, 5]
# دالة التجميع تأخذ القيمة التراكمية (accum) والقيمة الحالية (current)
var total = prices.reduce(func(accum: int, current: int) -> int: return accum + current, 0)
print(total) # 80
```

### د. الترتيب المخصص (`sort_custom`)

ترتيب عناصر المصفوفة وفق معيار مخصص:

```gdscript
var players = [
    {"name": "سعد", "score": 150},
    {"name": "خالد", "score": 300},
    {"name": "منى", "score": 220}
]

# ترتيب تنازلي حسب النقاط
players.sort_custom(func(a, b) -> bool:
    return a["score"] > b["score"]
)

for p in players:
    print(p["name"], ": ", p["score"])
# خالد: 300
# منى: 220
# سعد: 150
```

### هـ. الفحص الشامل (`any` و `all`)

```gdscript
var health_levels = [100, 85, 0, 90]

# هل يوجد لاعب مهزوم؟
var has_dead = health_levels.any(func(h: int) -> bool: return h <= 0)
print(has_dead) # true

# هل جميع اللاعبين على قيد الحياة؟
var all_alive = health_levels.all(func(h: int) -> bool: return h > 0)
print(all_alive) # false
```
