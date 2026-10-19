# النصوص وتنسيق السلاسل النصية في GDScript (Strings & String Formatting)

> **المصادر الرسمية:**
>
> - [Godot Engine — String Class Reference](https://docs.godotengine.org/en/stable/classes/class_string.html)
> - [Godot Engine — GDScript Basics: Format Strings](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_format_string.html)

تعتبر السلاسل النصية (**`String`**) في Godot 4 مصفوفة من محارف Unicode مشفرة بنظام UTF-8، وتزخر بأكثر من 80 ميثود مدمجة عالية الأداء لمعالجة النصوص، والتحقق منها، وإجراء عمليات المسارات والتنسيق.

---

## 1. تعريف السلاسل النصية ومحارف الهروب (Escape Sequences)

### أ. أنواع علامات التنصيص

```gdscript
# علامات تنصيص مزدوجة أو مفردة
var str1 = "مرحباً بالعالم"
var str2 = 'نص بعلامات مفردة'

# سلاسل متعددة الأسطر (Multiline Strings)
var multi = """
السطر الأول
السطر الثاني
السطر الثالث
"""
```

### ب. محارف الهروب الخاصة (Escape Characters)

| الرمز | المعنى | مثال |
| :--- | :--- | :--- |
| `\n` | سطر جديد (Newline) | `"Line 1\nLine 2"` |
| `\t` | مسافة جدولية (Tab) | `"Col 1\tCol 2"` |
| `\\` | خط مائل عكسي (Backslash) | `"C:\\Games\\Godot"` |
| `\"` | علامة تنصيص مزدوجة داخل نص مزدوج | `"قال: \"مرحباً\""` |
| `\'` | علامة تنصيص مفردة | `'It\'s ok'` |
| `\r` | إرجاع السطر (Carriage Return) | - |
| `\uXXXX` | محرف يونيكود بنظام Hexadecimal ذو 4 خانات | `"\u00A9"` (علامة ©) |
| `\UXXXXXXXX` | محرف يونيكود بـ 8 خانات | `"\U0001F600"` (رمز التعبير 😀) |

---

## 2. تنسيق النصوص باستخدام عامل التنسيق `%` (Printf-style Formatting)

يعتبر العامل `%` أسرع وأقوى طريقة لدمج الأرقام والنصوص في سلاسل منسقة بدقة رياضية:

### أ. الرموز الأساسية للتنسيق

```gdscript
# %s: نص عادي (String)
# %d: عدد صحيح ذو إشارة (Signed Integer)
# %f: عدد عشري (Float)
# %x / %X: عدد بالنظام الست عشري (Hexadecimal)
# %c: محرف من رقم الكود (Character)

var player_name = "فارس"
var health = 85
var ratio = 0.7485

# تمرير قيمة مفردة
var msg = "اللاعب: %s" % player_name

# تمرير قيم متعددة كمصفوفة داخل [...]
var info = "اللاعب: %s | الصحة: %d | النسبة: %0.2f%%" % [player_name, health, ratio * 100]
print(info) # اللاعب: فارس | الصحة: 85 | النسبة: 74.85%
```

### ب. التحديد المتقدم للأرقام العشرية والمحاذاة والحشو

```gdscript
# 1. تحديد عدد الخانات العشرية (%0.Nf)
print("النقاط: %0.2f" % 12.3456)  # النقاط: 12.35 (تقريب تلقائي)
print("النقاط: %0.0f" % 12.8)     # النقاط: 13

# 2. الحشو بالأصفار (Padding with Zeros) - مفيد للوقت والنقاط
var score = 42
print("النتيجة: %06d" % score)    # النتيجة: 000042 (6 خانات تبدأ بأصفار)

# 3. المحاذاة والمسافات (Width & Alignment)
print("|%10s|" % "يمين")         # |      يمين| (محاذاة لليمين بعرض 10)
print("|%-10s|" % "يسار")        # |يسار      | (محاذاة لليسار بعرض 10)

# 4. الألوان ورموز Hexadecimal
print("اللون Hex: #%06X" % 0xFF55AA) # اللون Hex: #FF55AA
```

---

## 3. التنسيق باستخدام القواميس: `String.format()`

طريقة ممتازة عند الرغبة في تعويض المتغيرات بالاسم عبر قاموس (`Dictionary`):

```gdscript
# استبدال المفاتيح بالاسم باستخدام الأقواس المعقوفة {key}
var template = "مرحباً {name}، لقد جمعت {gold} قطعة ذهبية في المستوى {level}."

var data = {
    "name": "سعد",
    "gold": 250,
    "level": 5
}

var result = template.format(data)
print(result) # مرحباً سعد، لقد جمعت 250 قطعة ذهبية في المستوى 5.
```

كما تدعم الدالة الترتيب بالأرقام:

```gdscript
var equation = "{0} + {1} = {2}".format([10, 20, 30])
print(equation) # 10 + 20 = 30
```

---

## 4. ميثودات فحص النصوص والتحقق منها (Inspection & Validation)

| الميثود | الوصف | مثال | النتيجة |
| :--- | :--- | :--- | :--- |
| `length()` | إرجاع عدد المحارف | `"Godot".length()` | `5` |
| `is_empty()` | هل النص فارغ تماماً؟ | `"".is_empty()` | `true` |
| `contains(what)` | هل يحتوي على النص المحدد؟ | `"Hero".contains("er")` | `true` |
| `begins_with(text)` | هل يبدأ بالنص المحدد؟ | `"res://icon.png".begins_with("res://")` | `true` |
| `ends_with(text)` | هل ينتهي بالنص المحدد؟ | `"icon.png".ends_with(".png")` | `true` |
| `find(what, from=0)` | البحث عن أول موقع لنص (-1 إذا لم يوجد) | `"banana".find("na")` | `2` |
| `rfind(what)` | البحث العكسي من النهاية | `"banana".rfind("na")` | `4` |
| `count(what)` | عدد مرات تكرار نص داخل النص | `"banana".count("a")` | `3` |
| `match(pattern)` | مطابقة بنمط الرموز البديلة (`*` و `?`) | `"file_10.png".match("file_*.png")` | `true` |
| `is_valid_int()` | هل يمكن تحويل النص لعدد صحيح بأمان؟ | `"123".is_valid_int()` | `true` |
| `is_valid_float()` | هل يمكن تحويل النص لعدد عشري بأمان؟ | `"3.14".is_valid_float()` | `true` |
| `validate_node_name()` | تنظيف النص وإزالة أي محارف تمنع استخدامه كاسم عقدة | `"Player/Arm:1".validate_node_name()` | `"Player_Arm_1"` |

---

## 5. ميثودات التعديل والتقطيع والتحويل (Manipulation & Splitting)

```gdscript
# 1. إزالة الفراغات والمسافات البيضاء
var raw = "   مرحباً بك   \n"
print(raw.strip_edges()) # "مرحباً بك"

# 2. تغيير حالة الأحرف (للغات اللاتينية)
var code = "player_jump_speed"
print(code.to_upper())       # "PLAYER_JUMP_SPEED"
print(code.to_pascal_case()) # "PlayerJumpSpeed"
print(code.to_camel_case())  # "playerJumpSpeed"

# 3. الاستبدال (Replace)
var text = "أنا أحب محرك Unity"
var new_text = text.replace("Unity", "Godot")
print(new_text) # "أنا أحب محرك Godot"

# 4. التقطيع إلى مصفوفة (Split)
var csv_line = "أحمد,25,مبرمج,الرياض"
var parts = csv_line.split(",")
print(parts) # ["أحمد", "25", "مبرمج", "الرياض"]

# 5. الدمج من مصفوفة إلى نص (Join)
var words = ["محرك", "الألعاب", "Godot"]
var sentence = " ".join(words)
print(sentence) # "محرك الألعاب Godot"

# 6. أخذ أجزاء من النص (Substrings)
var filename = "character_sheet"
print(filename.left(9))   # "character" (أول 9 محارف من اليسار)
print(filename.right(5))  # "sheet" (آخر 5 محارف من اليمين)
print(filename.substr(10, 5)) # "sheet" (بدءاً من الفهرس 10 وبطول 5)
```

---

## 6. ميثودات التعامل مع مسارات الملفات (Path Manipulation Methods)

تحتوي فئة `String` في Godot على دوال مدمجة فائقة السهولة للتعامل مع مسارات الملفات دون الحاجة لمكتبات مسارات خارجية:

```gdscript
var path = "res://assets/images/characters/hero.png"

# استخراج اسم الملف مع الامتداد
print(path.get_file())      # "hero.png"

# استخراج اسم الملف بدون امتداد
print(path.get_basename().get_file()) # "hero"

# استخراج الامتداد فقط
print(path.get_extension()) # "png"

# استخراج مسار المجلد الأب
print(path.get_base_dir())  # "res://assets/images/characters"

# دمج المسارات بأمان وبشكل صحيح (Path Join)
var folder = "res://levels"
var level_file = folder.path_join("level_01.tscn")
print(level_file)           # "res://levels/level_01.tscn"

# تبسيط وتنظيف المسارات
var messy = "res://assets/audio/../textures/./logo.png"
print(messy.simplify_path()) # "res://assets/textures/logo.png"
```
