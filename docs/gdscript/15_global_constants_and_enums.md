# الثوابت والتعدادات العالمية المدمجة في GDScript (Global Constants & Enums)

> **المصادر الرسمية:**
>
> - [Godot Engine — @GlobalScope Documentation](https://docs.godotengine.org/en/stable/classes/class_%40globalscope.html)
> - [Godot Engine — Core Constants & Enums](https://docs.godotengine.org/en/stable/classes/class_%40globalscope.html#enumerations)

يحتوي النطاق العام (`@GlobalScope`) في محرك Godot 4 على مجموعة ضخمة من **التعدادات (Enums)** و**الثوابت القياسية** المتاحة مباشرة في أي سكربت GDScript دون الحاجة لاستيراد أي مكتبات.

---

## 1. تعداد أكواد الأخطاء والحالات (`Error`)

هو التعداد القياسي الذي تُرجعه دوال حفظ وتحميل الملفات، واتصالات الشبكة، وتحليل النصوص والـ JSON.

```gdscript
var file = FileAccess.open("res://save.dat", FileAccess.READ)
var err = FileAccess.get_open_error()

if err != OK:
    printerr("حدث خطأ في فتح الملف: ", error_string(err))
```

### أهم قيم تعداد `Error`

| الثابت | القيمة الرقمية | المعنى والوصف |
| :--- | :---: | :--- |
| `OK` | `0` | تمت العملية بنجاح تام وبدون أي أخطاء. |
| `FAILED` | `1` | فشل عام غير محدد. |
| `ERR_UNAVAILABLE` | `2` | الخدمة أو المورد غير متوفر. |
| `ERR_UNCONFIGURED` | `3` | الكائن غير مهيأ أو تنقصه إعدادات ضرورية. |
| `ERR_UNAUTHORIZED` | `4` | لا توجد صلاحيات كافية لتنفيذ العملية. |
| `ERR_PARAMETER_RANGE_ERROR` | `5` | معامل الدالة خارج النطاق المسموح. |
| `ERR_OUT_OF_MEMORY` | `6` | نفاد الذاكرة. |
| `ERR_FILE_NOT_FOUND` | `7` | لم يتم العثور على الملف المطلوب. |
| `ERR_FILE_BAD_PATH` | `9` | مسار الملف غير صحيح أو تالف. |
| `ERR_FILE_NO_PERMISSION` | `10` | لا توجد صلاحيات وصول للملف (Permission Denied). |
| `ERR_FILE_ALREADY_IN_USE` | `11` | الملف مفتوح ومستخدم من برنامج آخر. |
| `ERR_FILE_CANT_OPEN` | `12` | لا يمكن فتح الملف. |
| `ERR_FILE_CANT_WRITE` | `13` | فشلت الكتابة على الملف. |
| `ERR_FILE_CANT_READ` | `14` | فشلت القراءة من الملف. |
| `ERR_FILE_CORRUPT` | `16` | بيانات الملف تالفة. |
| `ERR_PARSE_ERROR` | `43` | خطأ في التحليل النحوي (مثل JSON تالف). |
| `ERR_TIMEOUT` | `24` | انتهت المهلة المحددة للعملية (Timeout). |
| `ERR_CONNECTION_ERROR` | `27` | فشل الاتصال بالشبكة. |

> [!TIP]
> يمكنك استخدام الدالة المدمجة `error_string(err)` لتحويل رقم الخطأ إلى نص توضيحي مقروء باللغة الإنجليزية تلقائياً.

---

## 2. تعدادات المدخلات والأزرار (Input Enums)

تُستخدم للتعامل مع أحداث لوحة المفاتيح والماوس وأذرع التحكم داخل دوال `_input(event)`:

### أ. أزرار الفأرة (`MouseButton`)

| الثابت | القيمة | الوصف |
| :--- | :---: | :--- |
| `MOUSE_BUTTON_NONE` | `0` | لا يوجد زر مضغوط |
| `MOUSE_BUTTON_LEFT` | `1` | زر الفأرة الأيسر (الرئيسي) |
| `MOUSE_BUTTON_RIGHT` | `2` | زر الفأرة الأيمن |
| `MOUSE_BUTTON_MIDDLE` | `3` | زر عجلة الفأرة (الأوسط) |
| `MOUSE_BUTTON_WHEEL_UP` | `4` | تدوير عجلة الفأرة للأعلى |
| `MOUSE_BUTTON_WHEEL_DOWN` | `5` | تدوير عجلة الفأرة للأسفل |

```gdscript
func _input(event):
    if event is InputEventMouseButton and event.pressed:
        if event.button_index == MOUSE_BUTTON_LEFT:
            print("نقرة بالزر الأيسر عند: ", event.position)
```

### ب. مفاتيح لوحة المفاتيح (`Key`)

| الثابت | المفتاح المقابل |
| :--- | :--- |
| `KEY_ESCAPE` | مفتاح الخروج (Esc) |
| `KEY_TAB` | مفتاح الانتقال (Tab) |
| `KEY_BACKSPACE` | مفتاح الحذف الخلفي |
| `KEY_ENTER` / `KEY_KP_ENTER` | مفتاح الإدخال (Enter / Numpad Enter) |
| `KEY_SPACE` | مفتاح المسافة |
| `KEY_LEFT`, `KEY_UP`, `KEY_RIGHT`, `KEY_DOWN` | مفاتيح الأسهم الأربعة |
| `KEY_SHIFT`, `KEY_CTRL`, `KEY_ALT` | مفاتيح التعديل |
| `KEY_A` إلى `KEY_Z` | الحروف الأبجدية |
| `KEY_0` إلى `KEY_9` | الأرقام |

```gdscript
func _unhandled_key_input(event: InputEvent):
    if event.is_pressed() and event.keycode == KEY_ESCAPE:
        toggle_pause_menu()
```

---

## 3. تعدادات الاتجاهات والمحاذاة والهندسة

تُستخدم في واجهات المستخدم (UI Control Nodes) ومصفوفات الرسم:

### أ. الجوانب والزوايا (`Side` & `Corner`)

```gdscript
# Side
SIDE_LEFT   = 0
SIDE_TOP    = 1
SIDE_RIGHT  = 2
SIDE_BOTTOM = 3

# Corner
CORNER_TOP_LEFT     = 0
CORNER_TOP_RIGHT    = 1
CORNER_BOTTOM_RIGHT = 2
CORNER_BOTTOM_LEFT  = 3
```

### ب. المحاذاة الأفقية والعمودية

```gdscript
# HorizontalAlignment
HORIZONTAL_ALIGNMENT_LEFT   # محاذاة لليسار
HORIZONTAL_ALIGNMENT_CENTER # توسيط أفقي
HORIZONTAL_ALIGNMENT_RIGHT  # محاذاة لليمين
HORIZONTAL_ALIGNMENT_FILL   # ملء كامل المساحة

# VerticalAlignment
VERTICAL_ALIGNMENT_TOP      # محاذاة للأعلى
VERTICAL_ALIGNMENT_CENTER   # توسيط رأسي
VERTICAL_ALIGNMENT_BOTTOM   # محاذاة للأسفل
VERTICAL_ALIGNMENT_FILL     # ملء رأسي
```

---

## 4. تعدادات فحص الانعكاس والأنواع (`Variant.Type`)

تُستخدم عند التعامل مع دوال فحص الأنواع الديناميكية مثل `typeof()`:

| الثابت | القيمة | النوع المقابل |
| :--- | :---: | :--- |
| `TYPE_NIL` | `0` | `null` |
| `TYPE_BOOL` | `1` | `bool` |
| `TYPE_INT` | `2` | `int` |
| `TYPE_FLOAT` | `3` | `float` |
| `TYPE_STRING` | `4` | `String` |
| `TYPE_VECTOR2` | `5` | `Vector2` |
| `TYPE_VECTOR2I` | `6` | `Vector2i` |
| `TYPE_RECT2` | `7` | `Rect2` |
| `TYPE_VECTOR3` | `9` | `Vector3` |
| `TYPE_COLOR` | `20` | `Color` |
| `TYPE_STRING_NAME` | `21` | `StringName` |
| `TYPE_NODE_PATH` | `22` | `NodePath` |
| `TYPE_RID` | `23` | `RID` |
| `TYPE_OBJECT` | `24` | `Object` / `Node` / `Resource` |
| `TYPE_CALLABLE` | `25` | `Callable` |
| `TYPE_SIGNAL` | `26` | `Signal` |
| `TYPE_DICTIONARY` | `27` | `Dictionary` |
| `TYPE_ARRAY` | `28` | `Array` |
| `TYPE_PACKED_BYTE_ARRAY` | `29` | `PackedByteArray` |

```gdscript
var value: Variant = Vector2(10, 20)

match typeof(value):
    TYPE_INT, TYPE_FLOAT:
        print("قيمة عددية")
    TYPE_VECTOR2:
        print("متجه ثنائي: ", value.x, ", ", value.y)
    TYPE_OBJECT:
        print("كائن مرجعي")
```

---

## 5. الثوابت الرياضية القياسية

| الثابت | القيمة الدقيقة | الوصف والرمز الرياضي |
| :--- | :--- | :--- |
| `PI` | `3.14159265358979323846` | النسبة الثابتة لمحيط الدائرة إلى قطرها ($\pi$). |
| `TAU` | `6.28318530717958647692` | ضعف النسبة الثابتة ($\tau = 2\pi$)، وتساوي دورة كاملة بالراديان (360 درجة). |
| `INF` | `inf` | اللانهاية الموجبة (Positive Infinity). |
| `NAN` | `nan` | قيمة غير عددية (Not a Number)، تنتج عن عمليات مثل `0.0 / 0.0` أو جذر عدد سالب. |
