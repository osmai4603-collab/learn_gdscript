# الكلمات المحجوزة في GDScript (Reserved Keywords)

> **المصدر الرسمي:** [GDScript Reference - Godot Engine](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html#keywords)

الكلمات المحجوزة هي كلمات خاصة تستخدمها اللغة في بناء الجمل البرمجية، ولا يمكن استخدامها كأسماء للمتغيرات أو الدوال أو الأصناف.

---

## 1. كلمات التحكم بالتدفق (Control Flow)

| الكلمة | الوصف | مثال |
| -------- | ------- | ------ |
| `if` | بداية شرط | `if x > 5:` |
| `elif` | شرط بديل (else if) | `elif x == 3:` |
| `else` | الحالة الافتراضية إذا لم تتحقق الشروط | `else:` |
| `for` | حلقة تكرارية | `for i in range(10):` |
| `while` | حلقة تكرارية شرطية | `while is_alive:` |
| `break` | الخروج من الحلقة فوراً | `break` |
| `continue` | تخطي التكرار الحالي والانتقال للتالي | `continue` |
| `match` | مطابقة الأنماط (بديل switch-case) | `match value:` |
| `when` | تُستخدم في سياق مطابقة الأنماط المتقدمة | `when condition:` |
| `pass` | عبارة فارغة لا تفعل شيئاً (placeholder) | `pass` |
| `return` | الخروج من الدالة مع إرجاع قيمة اختياريًا | `return result` |

---

## 2. كلمات التصريح والبرمجة الكائنية (Declarations & OOP)

| الكلمة | الوصف | مثال |
| -------- | ------- | ------ |
| `var` | تصريح متغير | `var health = 100` |
| `const` | تصريح ثابت (قيمة لا تتغير) | `const MAX_SPEED = 200` |
| `func` | تصريح دالة | `func _ready():` |
| `class` | تصريح صنف داخلي (inner class) | `class Enemy:` |
| `class_name` | تسجيل السكربت كنوع عالمي قابل لإعادة الاستخدام | `class_name Player` |
| `extends` | تحديد الوراثة من صنف أساسي | `extends CharacterBody2D` |
| `is` | فحص النوع | `if node is Sprite2D:` |
| `as` | تحويل النوع (Type Casting) | `var sprite = node as Sprite2D` |
| `self` | مرجع للنسخة الحالية من الصنف | `self.position` |
| `super` | استدعاء دالة الصنف الأب | `super._ready()` |
| `enum` | تعريف مجموعة ثوابت رقمية مسماة | `enum State {IDLE, RUN, JUMP}` |
| `static` | تصريح دالة أو متغير ثابت (يمكن الوصول إليه بدون إنشاء نسخة) | `static func get_max():` |
| `signal` | تعريف إشارة (Signal) مخصصة | `signal health_changed(new_health)` |

---

## 3. كلمات غير متزامنة وتحميل الموارد (Async & Loading)

| الكلمة | الوصف | مثال |
| -------- | ------- | ------ |
| `await` | إيقاف التنفيذ مؤقتاً حتى اكتمال إشارة أو coroutine | `await get_tree().create_timer(1.0).timeout` |
| `preload` | تحميل مورد بشكل ثابت عند وقت الترجمة | `const Scene = preload("res://scene.tscn")` |
| `load` | تحميل مورد ديناميكياً أثناء التشغيل | `var texture = load("res://icon.png")` |

---

## 4. كلمات العمليات المنطقية (Logical Operator Keywords)

| الكلمة | الوصف | البديل الرمزي | مثال |
| -------- | ------- | --------------- | ------ |
| `and` | العطف المنطقي (AND) | `&&` | `if a and b:` |
| `or` | الفصل المنطقي (OR) | `\|\|` | `if a or b:` |
| `not` | النفي المنطقي (NOT) | `!` | `if not is_dead:` |
| `in` | فحص العضوية | - | `if item in inventory:` |

---

## 5. كلمات خاصة بالقيم (Special Values)

| الكلمة | الوصف | مثال |
| -------- | ------- | ------ |
| `true` | القيمة المنطقية "صحيح" | `var is_alive = true` |
| `false` | القيمة المنطقية "خطأ" | `var is_dead = false` |
| `null` | قيمة فارغة / لا شيء | `var target = null` |

---

## 6. كلمات محجوزة أخرى

| الكلمة | الوصف | مثال |
| -------- | ------- | ------ |
| `breakpoint` | نقطة توقف للتصحيح (debugger breakpoint) | `breakpoint` |
| `void` | تحديد أن الدالة لا تُرجع قيمة | `func shoot() -> void:` |
| `trait` | (محجوزة للاستخدام المستقبلي) | - |
| `namespace` | (محجوزة للاستخدام المستقبلي) | - |
| `yield` | (كانت تُستخدم في Godot 3، استُبدلت بـ `await`) | - |

---

## 7. أسماء الأنواع المدمجة (محجوزة أيضاً)

أسماء جميع الأنواع المدمجة في Godot تُعامل ككلمات محجوزة ولا يمكن تجاوزها:

### الأنواع الأساسية

`bool`, `int`, `float`, `String`, `StringName`, `NodePath`

### الحاويات

`Array`, `Dictionary`, `PackedByteArray`, `PackedInt32Array`, `PackedInt64Array`,
`PackedFloat32Array`, `PackedFloat64Array`, `PackedStringArray`,
`PackedVector2Array`, `PackedVector3Array`, `PackedColorArray`, `PackedVector4Array`

### أنواع الرياضيات والهندسة

`Vector2`, `Vector2i`, `Vector3`, `Vector3i`, `Vector4`, `Vector4i`,
`Rect2`, `Rect2i`, `Transform2D`, `Transform3D`, `Basis`,
`Quaternion`, `AABB`, `Color`, `Plane`, `Projection`

### أنواع المرجع الأساسية

`Variant`, `Object`, `Resource`, `RefCounted`, `RID`, `Callable`, `Signal`

---

## 8. التعليقات التوضيحية (Annotations) - تبدأ بـ `@`

التعليقات التوضيحية ليست كلمات محجوزة تقليدية، لكنها محجوزة في سياقها الخاص:

| التعليق التوضيحي | الوصف |
| ------------------ | ------- |
| `@tool` | تشغيل السكربت داخل المحرر |
| `@onready` | تهيئة المتغير بعد دخول الشجرة |
| `@export` | تصدير المتغير ليظهر في المفتش (Inspector) |
| `@export_range` | تصدير متغير مع نطاق محدد |
| `@export_enum` | تصدير كقائمة اختيارات |
| `@export_file` | تصدير كمسار ملف |
| `@export_dir` | تصدير كمسار مجلد |
| `@export_multiline` | تصدير نص متعدد الأسطر |
| `@export_color_no_alpha` | تصدير لون بدون شفافية |
| `@export_node_path` | تصدير مسار عقدة |
| `@export_flags` | تصدير كأعلام بت |
| `@export_group` | تجميع خصائص مُصدَّرة |
| `@export_subgroup` | مجموعة فرعية للخصائص |
| `@export_category` | تصنيف للخصائص |
| `@icon` | تعيين أيقونة مخصصة للسكربت |
| `@warning_ignore` | تجاهل تحذير محدد |
| `@static_unload` | السماح بتفريغ السكربت الثابت |
