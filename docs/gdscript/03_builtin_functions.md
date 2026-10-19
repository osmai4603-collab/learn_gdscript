# الدوال المدمجة في GDScript (Built-in Functions)

> **المصدر الرسمي:**
>
> - [@GDScript — Godot Engine](https://docs.godotengine.org/en/stable/classes/class_%40gdscript.html)
> - [@GlobalScope — Godot Engine](https://docs.godotengine.org/en/stable/classes/class_%40globalscope.html)

الدوال المدمجة في GDScript تنقسم إلى قسمين رئيسيين:

1. **`@GDScript`** — دوال وثوابت خاصة بلغة GDScript فقط
2. **`@GlobalScope`** — دوال متاحة عالمياً في كل لغات Godot

---

## القسم الأول: دوال @GDScript الأساسية

### 1. دوال التحميل والموارد

```gdscript
# preload — تحميل ثابت عند الترجمة (المسار يجب أن يكون ثابتاً)
const PlayerScene = preload("res://player.tscn")

# load — تحميل ديناميكي أثناء التشغيل
var texture = load("res://icon.png")
```

| الدالة | الوصف | القيمة المُرجعة |
| -------- | ------- | ----------------- |
| `preload(path: String)` | تحميل مورد عند وقت الترجمة (المسار ثابت) | `Resource` |
| `load(path: String)` | تحميل مورد ديناميكياً أثناء التشغيل | `Resource` |

---

### 2. دوال الطباعة والتصحيح

```gdscript
# طباعة بمعلومات المكدس
print_debug("الحالة الحالية: ", state)

# طباعة مكدس الاستدعاء
print_stack()

# الحصول على مكدس الاستدعاء كمصفوفة
var stack = get_stack()
for frame in stack:
    print(frame)
```

| الدالة | الوصف |
| -------- | ------- |
| `print_debug(...)` | طباعة مع تتبع مكدس الاستدعاء الكامل |
| `print_stack()` | طباعة مكدس الاستدعاء الحالي إلى وحدة الإخراج |
| `get_stack() -> Array[Dictionary]` | إرجاع مكدس الاستدعاء كمصفوفة قواميس |

---

### 3. دوال التحويل والفحص

```gdscript
# تحويل نوع
var result = convert(my_var, TYPE_INT)

# فحص نوع النسخة
if is_instance_of(node, Sprite2D):
    print("هذا كائن Sprite2D")

# التحقق من وجود نوع
if type_exists("CharacterBody2D"):
    print("النوع موجود!")
```

| الدالة | الوصف | القيمة المُرجعة |
| -------- | ------- | ----------------- |
| `convert(what, type)` | تحويل متغير من نوع إلى آخر | `Variant` |
| `is_instance_of(value, type)` | فحص ما إذا كانت القيمة نسخة من النوع المحدد | `bool` |
| `type_exists(type: StringName)` | فحص ما إذا كان اسم النوع موجوداً | `bool` |

---

### 4. دوال متنوعة أساسية

```gdscript
# الحصول على طول حاوية أو نص
var length = len("Hello")         # 5
var arr_len = len([1, 2, 3])      # 3

# إنشاء لون من قيم 8-بت (0-255)
var red = Color8(255, 0, 0)
var semi_transparent = Color8(255, 255, 255, 128)

# الحصول على حرف من رقم Unicode
var letter = char(65)  # "A"

# التأكيد (Assertion) — يتوقف في وضع التصحيح إذا كان الشرط خطأ
assert(health >= 0, "الصحة لا يمكن أن تكون سالبة!")

# إنشاء نطاق من الأرقام
var numbers = range(5)          # [0, 1, 2, 3, 4]
var evens = range(0, 10, 2)     # [0, 2, 4, 6, 8]
var countdown = range(5, 0, -1) # [5, 4, 3, 2, 1]
```

| الدالة | الوصف | القيمة المُرجعة |
| -------- | ------- | ----------------- |
| `len(var)` | إرجاع طول نص أو مصفوفة أو قاموس | `int` |
| `Color8(r8, g8, b8, a8=255)` | إنشاء لون من قيم 0-255 | `Color` |
| `char(code: int)` | إرجاع حرف من رقم Unicode | `String` |
| `assert(condition, message="")` | إيقاف التنفيذ إذا كان الشرط خطأ (وضع التصحيح فقط) | `void` |
| `range(...)` | إنشاء مصفوفة أرقام متتالية | `Array` |

---

### 5. دوال التسلسل (Serialization)

```gdscript
# تحويل كائن إلى قاموس
var dict = inst_to_dict(my_object)

# تحويل قاموس إلى كائن
var obj = dict_to_inst(dict)
```

| الدالة | الوصف | القيمة المُرجعة |
| -------- | ------- | ----------------- |
| `inst_to_dict(instance: Object)` | تحويل كائن إلى قاموس مُتسلسل | `Dictionary` |
| `dict_to_inst(dictionary: Dictionary)` | تحويل قاموس إلى كائن | `Object` |

---

### 6. ثوابت @GDScript المدمجة

| الثابت | القيمة | الوصف |
| -------- | -------- | ------- |
| `PI` | `3.14159265358979` | النسبة الثابتة π |
| `TAU` | `6.28318530717959` | PI × 2 (دورة كاملة بالراديان) |
| `INF` | ∞ | اللانهاية الموجبة |
| `NAN` | NaN | ليس رقماً (Not a Number) |

```gdscript
# استخدام الثوابت
var circumference = 2 * PI * radius
# أو ببساطة:
var circumference = TAU * radius

# التحقق من اللانهاية
if value == INF:
    print("القيمة لا نهائية!")

# التحقق من NAN
if is_nan(result):
    print("النتيجة ليست رقماً!")
```

---

## القسم الثاني: دوال @GlobalScope (متاحة عالمياً)

### 1. الدوال الرياضية (Mathematical Functions)

#### دوال المثلثات (Trigonometric)

| الدالة | الوصف | مثال |
| -------- | ------- | ------ |
| `sin(angle_rad)` | جيب الزاوية (بالراديان) | `sin(PI / 2)` → `1.0` |
| `cos(angle_rad)` | جيب تمام الزاوية | `cos(0)` → `1.0` |
| `tan(angle_rad)` | ظل الزاوية | `tan(PI / 4)` → `1.0` |
| `asin(value)` | جيب الزاوية العكسي | `asin(1.0)` → `PI/2` |
| `acos(value)` | جيب التمام العكسي | `acos(1.0)` → `0.0` |
| `atan(value)` | الظل العكسي | `atan(1.0)` → `PI/4` |
| `atan2(y, x)` | الظل العكسي ذو المتغيرين | `atan2(1, 1)` → `PI/4` |
| `sinh(x)` | الجيب الزائدي | - |
| `cosh(x)` | جيب التمام الزائدي | - |
| `tanh(x)` | الظل الزائدي | - |

#### دوال الأُس والجذور

| الدالة | الوصف | مثال |
| -------- | ------- | ------ |
| `pow(base, exp)` | الأُس | `pow(2, 3)` → `8` |
| `sqrt(x)` | الجذر التربيعي | `sqrt(16)` → `4.0` |
| `exp(x)` | e مرفوعة للأُس x | `exp(1)` → `2.718...` |
| `log(x)` | اللوغاريتم الطبيعي | `log(E)` → `1.0` |

#### دوال التقريب والتثبيت

```gdscript
# القيمة المطلقة
abs(-5)          # 5
abs(-3.7)        # 3.7

# التقريب
ceil(4.3)        # 5.0  (تقريب لأعلى)
floor(4.7)       # 4.0  (تقريب لأسفل)
round(4.5)       # 5.0  (تقريب لأقرب عدد)

# التثبيت (Clamping)
clamp(15, 0, 10)     # 10 (يُثبت القيمة بين الحد الأدنى والأقصى)
clampf(1.5, 0.0, 1.0)  # 1.0
clampi(15, 0, 10)      # 10

# المحاذاة (Snapping)
snapped(23, 5)    # 25 (يُقرب لأقرب مضاعف لـ 5)
snappedf(1.3, 0.5) # 1.5

# الإشارة
sign(-5)   # -1
sign(0)    # 0
sign(5)    # 1

# باقي القسمة الموجب دائماً
posmod(-7, 3)    # 2 (بدلاً من -1)
fposmod(-0.5, 1.0)  # 0.5
```

| الدالة | الوصف |
| -------- | ------- |
| `abs(x)` | القيمة المطلقة |
| `ceil(x)` | تقريب لأعلى |
| `floor(x)` | تقريب لأسفل |
| `round(x)` | تقريب لأقرب عدد |
| `clamp(value, min, max)` | تثبيت القيمة ضمن نطاق |
| `clampf(value, min, max)` | تثبيت عدد عشري |
| `clampi(value, min, max)` | تثبيت عدد صحيح |
| `snapped(value, step)` | محاذاة لأقرب مضاعف |
| `snappedf(value, step)` | محاذاة عدد عشري |
| `sign(x)` | إشارة العدد (-1, 0, 1) |
| `signf(x)` | إشارة عدد عشري |
| `signi(x)` | إشارة عدد صحيح |
| `posmod(x, y)` | باقي قسمة موجب دائماً |
| `fposmod(x, y)` | باقي قسمة عشري موجب |

---

### 2. دوال الاستيفاء وإعادة التعيين (Interpolation & Remapping)

```gdscript
# الاستيفاء الخطي (Linear Interpolation)
var mid = lerp(0.0, 100.0, 0.5)       # 50.0
var color = lerp(Color.RED, Color.BLUE, 0.5)  # لون بين الأحمر والأزرق

# استيفاء الزوايا
var angle = lerp_angle(0, PI, 0.5)     # PI/2

# الاستيفاء العكسي
var weight = inverse_lerp(0, 100, 50)  # 0.5

# إعادة التعيين (Remapping)
var mapped = remap(50, 0, 100, 0, 1)   # 0.5

# حركة سلسة
var smooth = smoothstep(0, 10, 5)       # 0.5 (منحنى ناعم)

# التحرك نحو هدف
var new_pos = move_toward(current, target, delta)

# دالة التسهيل
var eased = ease(0.5, 2.0)  # منحنى تسارع
```

| الدالة | الوصف |
| -------- | ------- |
| `lerp(from, to, weight)` | استيفاء خطي بين قيمتين |
| `lerpf(from, to, weight)` | استيفاء خطي للأعداد العشرية |
| `lerp_angle(from, to, weight)` | استيفاء خطي للزوايا |
| `inverse_lerp(from, to, value)` | الاستيفاء العكسي |
| `remap(value, istart, istop, ostart, ostop)` | إعادة تعيين قيمة من نطاق لآخر |
| `smoothstep(from, to, x)` | منحنى استيفاء ناعم (Hermite) |
| `move_toward(from, to, delta)` | تحريك قيمة نحو هدف بمقدار محدد |
| `ease(s, curve)` | دالة تسهيل |

---

### 3. دوال الحد الأقصى والأدنى (Min/Max)

```gdscript
var biggest = max(5, 10, 3)       # 10
var smallest = min(5, 10, 3)      # 3
var max_float = maxf(1.5, 2.7)    # 2.7
var min_int = mini(5, 3)          # 3
```

| الدالة | الوصف |
| -------- | ------- |
| `max(...)` | أكبر قيمة من مجموعة |
| `min(...)` | أصغر قيمة من مجموعة |
| `maxf(a, b)` | أكبر عدد عشري |
| `maxi(a, b)` | أكبر عدد صحيح |
| `minf(a, b)` | أصغر عدد عشري |
| `mini(a, b)` | أصغر عدد صحيح |

---

### 4. دوال تحويل الزوايا (Angle Conversion)

```gdscript
var radians = deg_to_rad(180)   # PI
var degrees = rad_to_deg(PI)    # 180.0
```

| الدالة | الوصف |
|--------|-------|
| `deg_to_rad(degrees)` | تحويل درجات إلى راديان |
| `rad_to_deg(radians)` | تحويل راديان إلى درجات |

---

### 5. دوال الأرقام العشوائية (Random Numbers)

```gdscript
# تهيئة مولد الأرقام العشوائية
randomize()

# عدد صحيح عشوائي 32-بت
var random_int = randi()

# عدد عشري عشوائي بين 0.0 و 1.0
var random_float = randf()

# عدد عشري في نطاق محدد
var damage = randf_range(10.0, 25.0)

# عدد صحيح في نطاق محدد
var dice = randi_range(1, 6)

# توزيع غاوسي (طبيعي)
var height = randfn(170.0, 10.0)  # متوسط 170، انحراف 10

# تعيين البذرة يدوياً
seed(12345)
```

| الدالة | الوصف | القيمة المُرجعة |
| -------- | ------- | ----------------- |
| `randomize()` | تهيئة المولد بالوقت الحالي | `void` |
| `randi()` | عدد صحيح عشوائي 32-بت | `int` |
| `randf()` | عدد عشري عشوائي [0.0, 1.0] | `float` |
| `randf_range(from, to)` | عدد عشري عشوائي في نطاق | `float` |
| `randi_range(from, to)` | عدد صحيح عشوائي في نطاق | `int` |
| `randfn(mean, deviation)` | عدد بتوزيع غاوسي | `float` |
| `seed(s: int)` | تعيين بذرة المولد العشوائي | `void` |

---

### 6. دوال تحويل وفحص الأنواع (Type Conversion & Checking)

```gdscript
# التحويل
var i = int(3.7)          # 3
var f = float(5)           # 5.0
var s = str(42)            # "42"
var b = bool(1)            # true

# فحص النوع
var type = typeof(my_var)  # مثال: TYPE_INT
var type_name = type_string(TYPE_INT)  # "int"

# فحص القيم الخاصة
is_nan(NAN)               # true
is_inf(INF)               # true
is_zero_approx(0.00001)   # false
is_equal_approx(0.1 + 0.2, 0.3)  # true (مقارنة عشرية آمنة!)
```

| الدالة | الوصف |
| -------- | ------- |
| `int(value)` | تحويل إلى عدد صحيح |
| `float(value)` | تحويل إلى عدد عشري |
| `str(value)` | تحويل إلى نص |
| `bool(value)` | تحويل إلى قيمة منطقية |
| `typeof(variable)` | إرجاع نوع المتغير كثابت `TYPE_*` |
| `type_string(type)` | إرجاع اسم النوع كنص |
| `is_nan(x)` | هل القيمة NAN؟ |
| `is_inf(x)` | هل القيمة لانهائية؟ |
| `is_zero_approx(x)` | هل القيمة قريبة من الصفر؟ |
| `is_equal_approx(a, b)` | هل القيمتان متساويتان تقريباً؟ |

---

### 7. دوال الطباعة (Print Functions)

```gdscript
# طباعة عادية
print("Hello World!")
print("العمر: ", age, " السرعة: ", speed)

# طباعة بدون سطر جديد (في نفس السطر)
printt("Col1", "Col2", "Col3")   # مفصولة بـ Tab
prints("A", "B", "C")            # مفصولة بمسافة
printraw("بدون سطر جديد")

# طباعة منسقة غنية
print_rich("[color=red]خطأ![/color] حدث خلل")

# طباعة تحذيرية وأخطاء
push_warning("هذا تحذير")
push_error("هذا خطأ")
printerr("طباعة إلى stderr")
```

| الدالة | الوصف |
| -------- | ------- |
| `print(...)` | طباعة إلى وحدة الإخراج |
| `prints(...)` | طباعة بفاصل مسافة |
| `printt(...)` | طباعة بفاصل Tab |
| `printraw(...)` | طباعة بدون سطر جديد |
| `print_rich(...)` | طباعة بتنسيق BBCode |
| `printerr(...)` | طباعة إلى stderr |
| `push_warning(message)` | إصدار تحذير |
| `push_error(message)` | إصدار خطأ |

---

### 8. دوال التجزئة (Hashing)

```gdscript
var h = hash("my_string")         # تجزئة عامة
```

| الدالة | الوصف |
|--------|-------|
| `hash(var)` | إرجاع قيمة تجزئة للمتغير |

---

### 9. دوال مساعدة أخرى

```gdscript
# التفاف القيم (Wrapping)
var w = wrap(12, 0, 10)    # 2 (يلتف عند الحدود)
var wf = wrapf(1.2, 0.0, 1.0)  # 0.2

# الحصول على ضعف عدد ضمن نطاق
var nearest_po2 = nearest_po2(5)  # 8 (أقرب أُس لـ 2)

# تحويل بايت لصيغة مقروءة
var var_bytes = var_to_bytes(my_var)
var original = bytes_to_var(var_bytes)

# تحويل إلى/من نص
var json_str = var_to_str({"key": "value"})
var parsed = str_to_var(json_str)
```

| الدالة | الوصف |
| -------- | ------- |
| `wrap(value, min, max)` | التفاف القيمة ضمن نطاق |
| `wrapf(value, min, max)` | التفاف عدد عشري |
| `wrapi(value, min, max)` | التفاف عدد صحيح |
| `nearest_po2(value)` | أقرب أُس لـ 2 |
| `var_to_bytes(var)` | تحويل متغير إلى بايتات |
| `bytes_to_var(bytes)` | تحويل بايتات إلى متغير |
| `var_to_str(var)` | تحويل متغير إلى نص |
| `str_to_var(string)` | تحويل نص إلى متغير |
