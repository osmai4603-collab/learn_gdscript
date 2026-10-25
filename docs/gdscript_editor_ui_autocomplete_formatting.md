# GDScript Editor: Autocomplete, Formatting & Editor UI

> **حالة التطبيق:** تستخدم المحررات واجهات `gdscript_engine` مباشرةً للتلوين
> والتشخيص، ويُتاح الإكمال في محرر التمارين. لا يوجد حالياً منسّق كود متصل
> بالمحرك، ولذلك أزيل إجراء التنسيق من واجهة التطبيق. بقية إشارات LSP أدناه
> مرجع تقني تاريخي وليست وصفاً للتكامل الجاري.

## بحث شامل من المصادر الرسمية لـ Godot Engine

> **المصادر الرسمية:**
>
> - [CodeEdit Class Reference](https://docs.godotengine.org/en/stable/classes/class_codeedit.html)
> - [GDScript Style Guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html)
> - [Static Typing in GDScript](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/static_typing.html)
> - [GDScript Reference](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/index.html)
> - [GDToolkit (gdformat)](https://github.com/Scony/godot-gdscript-toolkit)

---

## جدول المحتويات

1. [نظام الـ Autocomplete (Code Completion)](#1-نظام-الـ-autocomplete-code-completion)
2. [نظام الـ Formatting (تنسيق الكود)](#2-نظام-الـ-formatting-تنسيق-الكود)
3. [واجهة المستخدم للمحرر (Editor UI)](#3-واجهة-المستخدم-للمحرر-editor-ui)
4. [نظام LSP (Language Server Protocol)](#4-نظام-lsp-language-server-protocol)
5. [التوثيق والتلميحات (Documentation & Tooltips)](#5-التوثيق-والتلميحات-documentation--tooltips)
6. [طي الكود (Code Folding)](#6-طي-الكود-code-folding)
7. [خريطة التطبيق لمشروعنا](#7-خريطة-التطبيق-لمشروعنا)

---

## 1. نظام الـ Autocomplete (Code Completion)

### 1.1 كيف يعمل داخلياً في Godot

نظام الـ autocomplete في Godot يعتمد على عدة طبقات معمارية:

#### الطبقة 1: GDScript Parser & Analyzer

- يحول النص الخام للسكربت إلى **tokens** (وحدات لغوية)
- يبني شجرة التحليل المجرد **AST (Abstract Syntax Tree)**
- يجري تحليلاً دلالياً **Semantic Analysis** لتغذية معلومات الأنواع إلى المحرر

#### الطبقة 2: Type Inference & Back-Parsing (استنتاج الأنواع)

بما أن GDScript لغة ديناميكية (duck typing)، يستخدم المحلل تقنية **تتبع الأصل**:

1. **عند كتابة نقطة `.`** بعد متغير أو تعبير:
   - يحاول المحلل تتبع المُعرِّف للخلف عبر شجرة التحليل
   - يبحث في: الكتل المحلية، الدوال، التعيينات، المصفوفات، القواميس، متغيرات الأعضاء

2. **الاعتماد على بيانات المحرك الوصفية (Engine Metadata):**
   - يستخدم نظام الانعكاس `ClassDB` المدمج في Godot
   - أصناف المحرك وأساليبه وخصائصه مُعرَّفة الأنواع بشكل متأصل
   - معاملات الدوال والأساليب الافتراضية وإشارات الحدث تكشف أنواعها

3. **تعزيز الكتابة الثابتة (Static Typing Boost):**
   - عند استخدام `var enemy: Enemy = ...` يعرف المحلل فوراً السياق الدقيق
   - يلغي الغموض تماماً ويعطي اقتراحات دقيقة

#### الطبقة 3: CodeEdit Node

العقدة المسؤولة عن عرض النص وأرقام الأسطر وقائمة الإكمال المنبثقة.

### 1.2 أنواع عناصر الإكمال (Completion Option Types)

```text
CodeEdit.KIND_CLASS         → أصناف (Classes)
CodeEdit.KIND_FUNCTION      → دوال (Functions/Methods)
CodeEdit.KIND_SIGNAL        → إشارات (Signals)
CodeEdit.KIND_VARIABLE      → متغيرات (Variables)
CodeEdit.KIND_MEMBER        → أعضاء (Members)
CodeEdit.KIND_ENUM          → تعدادات (Enums)
CodeEdit.KIND_CONSTANT      → ثوابت (Constants)
CodeEdit.KIND_NODE_PATH     → مسارات عُقد (Node Paths)
CodeEdit.KIND_FILE_PATH     → مسارات ملفات (File Paths)
CodeEdit.KIND_PLAIN_TEXT    → نص عادي (Plain Text)
```

### 1.3 واجهة برمجة الإكمال (Code Completion API)

#### الخصائص

```gdscript
code_completion_enabled: bool        # تفعيل/تعطيل نظام الإكمال
code_completion_prefixes: PackedStringArray  # المحارف التي تُفعّل الإكمال (مثل ".")
```

#### الأساليب الأساسية

```gdscript
#a إضافة خيار إكمال
add_code_completion_option(
    type: CodeCompletionKind,    # نوع العنصر (KIND_FUNCTION, KIND_VARIABLE, etc.)
    display_text: String,        # النص المعروض في القائمة
    insert_text: String,         # النص المُدرج عند الاختيار
    text_color: Color = Color(1, 1, 1),  # لون النص
    icon: Resource = null,       # أيقونة العنصر
    value: Variant = null,       # قيمة إضافية
    location: int = 1024         # الموقع/الأولوية
)

# تحديث خيارات الإكمال
update_code_completion_options(force: bool)

# تأكيد اختيار الإكمال
confirm_code_completion(replace: bool = false)

# إلغاء الإكمال
cancel_code_completion()

# طلب إكمال الكود
request_code_completion(force: bool = false)

# الحصول على خيارات الإكمال
get_code_completion_options() -> Array[Dictionary]

# الحصول على الخيار المحدد
get_code_completion_selected_index() -> int

# ضبط الخيار المحدد
set_code_completion_selected_index(index: int)
```

#### الإشارات (Signals)

```gdscript
#a يُطلق عند طلب إكمال الكود
signal code_completion_requested()
```

### 1.4 سياقات الإكمال (Completion Contexts)

يجب أن يتعرف نظام الإكمال على السياقات التالية:

| السياق | المُفعِّل | النتائج المتوقعة |
| -------- | --------- | ----------------- |
| بعد النقطة `.` | `object.` | أعضاء الكائن (دوال، متغيرات، إشارات) |
| بعد `extends` | `extends` | قائمة الأصناف المتاحة |
| بعد `var x:` | `:` | أنواع البيانات المتاحة |
| بعد `func(` | `(` | توقيعات المعاملات |
| بعد `$` | `$` | مسارات العُقد في الشجرة |
| بعد `@export` | `@` | الحواشي (Annotations) المتاحة |
| بعد `preload("` | `"` | مسارات الملفات |
| بعد `emit_signal("` | `"` | أسماء الإشارات المُعلنة |
| داخل `match` | | أنماط المطابقة |
| بعد `->` | `->` | أنواع الإرجاع |
| بداية السطر | | الكلمات المفتاحية، الأصناف، الدوال |

### 1.5 أفضل الممارسات لتحسين الإكمال

#### أ. استخدام الكتابة الثابتة

```gdscript
#a بدون تلميح نوع - الإكمال قد يعاني
var player = $Player

# مع كتابة ثابتة - إكمال فوري ودقيق
var player: Player = $Player
```

#### ب. إسقاط مراجع العُقد (Node Casting)

```gdscript
# الإسقاط باستخدام "as"
var enemy = $Enemy as Enemy
enemy.  # يعرض أساليب وخصائص Enemy
```

#### ج. تسجيل الأصناف المخصصة عبر `class_name`

```gdscript
class_name HealthComponent
extends Node

func take_damage(amount: int) -> void:
    pass
```

بعد التسجيل، كتابة `HealthComponent.` في أي مكان يُفعّل الإكمال.

### 1.6 خوارزمية ترتيب الاقتراحات

ترتيب الاقتراحات يعتمد على:

1. **تطابق البادئة (Prefix Match):** الأولوية العليا للنتائج المطابقة لما كتبه المستخدم
2. **القرب (Proximity):** المتغيرات المحلية أولاً، ثم أعضاء الصنف، ثم الأصناف العامة
3. **التكرار (Frequency):** العناصر المستخدمة بكثرة تظهر أولاً
4. **النوع (Type):** ترتيب حسب النوع (دوال، متغيرات، ثوابت...)
5. **الملاءمة السياقية (Contextual Relevance):** النتائج المناسبة للسياق الحالي

---

## 2. نظام الـ Formatting (تنسيق الكود)

### 2.1 دليل أسلوب GDScript الرسمي (Official Style Guide)

#### قواعد التنسيق الأساسية

##### المسافة البادئة (Indentation)

- **تُستخدم مسافات Tab (واحدة لكل مستوى)**
- لا تخلط بين Tab والمسافات أبداً
- كل كتلة كود متداخلة تزداد بمستوى واحد

```gdscript
#a ✅ صحيح
func _ready():
    var health = 100
    if health > 0:
        print("alive")

# ❌ خاطئ - مسافات بدلاً من tab أو مزيج
func _ready():
  var health = 100  # مسافتان بدلاً من tab
```

##### طول السطر (Line Length)

- الحد الأقصى: **100 حرف** (الموصى به رسمياً)
- يمكن تمديده إلى 120 حرفاً للحالات الاستثنائية

##### الأسطر الفارغة (Blank Lines)

```gdscript
#a سطران فارغان بين الدوال على مستوى الصنف
class_name Player
extends CharacterBody2D


var health: int = 100
var speed: float = 200.0


func _ready() -> void:
    pass


func _process(delta: float) -> void:
    pass


# سطر فارغ واحد داخل الدال للفصل المنطقي
func complex_function() -> void:
    var a = 1
    var b = 2

    if a > b:
        print("a is bigger")
```

##### المسافات حول العوامل (Operator Spacing)

```gdscript
#a ✅ صحيح
var x = 1 + 2
var y = "hello" + " world"
if x == y and z != w:
    pass

# ❌ خاطئ
var x=1+2
var y="hello"+" world"
if x==y and z!=w:
    pass
```

##### الفواصل والنقطتان (Commas & Colons)

```gdscript
#a ✅ مسافة بعد الفاصلة والنقطتين
func my_func(a: int, b: String, c: float) -> void:
    var dict = {key: "value", other: 123}

# ❌ بدون مسافات
func my_func(a:int,b:String,c:float)->void:
    var dict = {key:"value",other:123}
```

### 2.2 ترتيب عناصر الملف (File Structure Order)

```gdscript
# 1. @tool (إن وُجد)
@tool

# 2. class_name
class_name MyClass

# 3. extends
extends Node2D

# 4. Documentation comments (##)
## وصف الصنف هنا.

# 5. Signals
signal health_changed(new_health: int)
signal died

# 6. Enums
enum State { IDLE, WALKING, RUNNING }

# 7. Constants
const MAX_HEALTH: int = 100
const SPEED: float = 200.0

# 8. @export variables
@export var health: int = MAX_HEALTH
@export var armor: float = 0.0

# 9. Public variables
var current_state: State = State.IDLE
var velocity_multiplier: float = 1.0

# 10. Private variables (بادئة _)
var _internal_timer: float = 0.0
var _is_initialized: bool = false

# 11. @onready variables
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

# 12. Built-in virtual methods (بنفس ترتيب دورة الحياة)
func _init() -> void:
    pass

func _enter_tree() -> void:
    pass

func _ready() -> void:
    pass

func _process(delta: float) -> void:
    pass

func _physics_process(delta: float) -> void:
    pass

func _input(event: InputEvent) -> void:
    pass

func _unhandled_input(event: InputEvent) -> void:
    pass

# 13. Public methods
func take_damage(amount: int) -> void:
    pass

func heal(amount: int) -> void:
    pass

# 14. Private methods
func _update_health_bar() -> void:
    pass

# 15. Signal handlers (callbacks)
func _on_body_entered(body: Node2D) -> void:
    pass

# 16. Inner classes
class InnerHelper:
    var data: int = 0
```

### 2.3 اتفاقيات التسمية (Naming Conventions)

| العنصر | الأسلوب | مثال |
| -------- | --------- | ------ |
| الملفات | `snake_case` | `player_controller.gd` |
| الأصناف | `PascalCase` | `class_name PlayerController` |
| العُقد | `PascalCase` | `CharacterBody2D` |
| الدوال | `snake_case` | `func get_health()` |
| المتغيرات | `snake_case` | `var player_health` |
| الثوابت | `CONSTANT_CASE` | `const MAX_SPEED = 100` |
| التعدادات (اسم) | `PascalCase` | `enum PlayerState` |
| التعدادات (قيم) | `CONSTANT_CASE` | `IDLE, WALKING, RUNNING` |
| الإشارات | `snake_case` (ماضي) | `signal health_changed` |
| الخاص (private) | `_snake_case` | `var _internal_value` |

### 2.4 قواعد المسافة البادئة التلقائية (Auto-Indent Rules)

الكلمات المفتاحية التي تزيد المسافة البادئة بمستوى واحد:

```text
الكلمات التي تفتح كتلة جديدة (تزيد indent):
├── if / elif / else
├── for / while
├── match / case (pattern)
├── func
├── class / class_name
├── signal (multi-line)
├── enum (multi-line body)
├── @export (multi-line)
├── var (مع setter/getter)
└── الأقواس المفتوحة: (, [, {

الكلمات التي تنقص indent (Dedent triggers):
├── elif → نفس مستوى if
├── else → نفس مستوى if
├── pass → ينهي الكتلة
├── return → ينهي الكتلة
├── break → ينهي الكتلة
├── continue → ينهي الكتلة
└── الأقواس المغلقة: ), ], }
```

#### قواعد Auto-Indent التفصيلية

```gdscript
#a القاعدة 1: بعد ":" في نهاية السطر → زيادة indent
func my_function():
    ← يزداد هنا

# القاعدة 2: بعد فتح قوس → زيادة indent
var my_array = [
    ← يزداد هنا
    1, 2, 3,
]

# القاعدة 3: elif/else → نفس مستوى if
if condition:
    do_something()
elif other_condition:  ← نفس مستوى if
    do_other()
else:                  ← نفس مستوى if
    default()

# القاعدة 4: continuation line (السطر المتابع)
var result = very_long_function_name(
    argument_1,    ← محاذاة مع فتح القوس أو indent إضافي
    argument_2,
)

# القاعدة 5: match/case patterns
match value:
    1:
        print("one")    ← مستويان من match
    2:
        print("two")
    _:
        print("default")
```

### 2.5 أداة gdformat (GDToolkit)

#### التثبيت

```bash
#a لـ Godot 4
pip install "gdtoolkit==4.*"

# لـ Godot 3
pip install "gdtoolkit==3.*"
```

#### الاستخدام

```bash
#a تنسيق ملف واحد
gdformat script.gd

# تنسيق عدة ملفات
gdformat player.gd enemy.gd

# فحص بدون تعديل (للـ CI/CD)
gdformat --check path/to/file.gd

# تنسيق كل ملفات المشروع
gdformat $(find . -name '*.gd')
```

#### قواعد gdformat المُطبَّقة

- **طول السطر:** 100 حرف (قابل للتعديل)
- **المسافة البادئة:** Tab واحد لكل مستوى
- **المسافات حول العوامل:** إلزامية
- **الفاصلة المتأخرة (Trailing Comma):** في القوائم متعددة الأسطر
- **الأسطر الفارغة:** توحيد المسافات بين الدوال والمتغيرات

---

## 3. واجهة المستخدم للمحرر (Editor UI)

### 3.1 مكونات CodeEdit الأساسية

`CodeEdit` يرث من `TextEdit` ويضيف ميزات البرمجة:

```text
CodeEdit (العقدة الرئيسية)
├── Text Area (منطقة النص)
│   ├── Syntax Highlighting (تلوين بناء الجملة)
│   ├── Code Completion Popup (قائمة الإكمال)
│   ├── Parameter Hints (تلميحات المعاملات)
│   └── Selection & Cursor (التحديد والمؤشر)
│
├── Gutters (الأعمدة الجانبية)
│   ├── Line Numbers (أرقام الأسطر)
│   ├── Fold Indicators (مؤشرات الطي)
│   ├── Breakpoint Indicators (نقاط التوقف)
│   ├── Bookmark Indicators (العلامات المرجعية)
│   └── Executing Line (السطر المُنفَّذ)
│
├── Minimap (الخريطة المصغرة)
│
└── Scrollbars (أشرطة التمرير)
```

### 3.2 خصائص CodeEdit التفصيلية

#### Auto Brace Completion (إكمال الأقواس التلقائي)

```gdscript
code_edit.auto_brace_completion_enabled = true

# إضافة أزواج أقواس مخصصة
code_edit.add_auto_brace_completion_pair("(", ")")
code_edit.add_auto_brace_completion_pair("[", "]")
code_edit.add_auto_brace_completion_pair("{", "}")
code_edit.add_auto_brace_completion_pair("\"", "\"")
code_edit.add_auto_brace_completion_pair("'", "'")
```

#### Auto Indent (المسافة البادئة التلقائية)

```gdscript
code_edit.auto_indent_enabled = true

# إضافة بادئات مخصصة
code_edit.add_auto_indent_prefix(":")   # بعد النقطتين
```

#### Line Numbers & Gutters (أرقام الأسطر والأعمدة)

```gdscript
#a عرض أرقام الأسطر
code_edit.gutters_draw_line_numbers = true
code_edit.line_numbers_zero_padded = false  # ترقيم بدون أصفار

# عرض مؤشرات الطي
code_edit.gutters_draw_fold_gutter = true

# إضافة عمود جانبي مخصص
code_edit.add_gutter(at: int = -1)
code_edit.set_gutter_type(gutter: int, type: GutterType)
code_edit.set_gutter_name(gutter: int, name: String)
code_edit.set_gutter_width(gutter: int, width: int)
code_edit.set_gutter_clickable(gutter: int, clickable: bool)
code_edit.set_gutter_draw(gutter: int, draw: bool)
```

#### أنواع الأعمدة الجانبية (Gutter Types)

```text
TextEdit.GUTTER_TYPE_STRING  → نص
TextEdit.GUTTER_TYPE_ICON    → أيقونة
TextEdit.GUTTER_TYPE_CUSTOM  → رسم مخصص
```

### 3.3 نظام Syntax Highlighting (تلوين بناء الجملة)

يعتمد على `CodeHighlighter` resource:

```gdscript
var highlighter = CodeHighlighter.new()

# ألوان الكلمات المفتاحية
highlighter.add_keyword_color("var", Color("#FF7085"))
highlighter.add_keyword_color("func", Color("#66C2FF"))
highlighter.add_keyword_color("class", Color("#66C2FF"))
highlighter.add_keyword_color("extends", Color("#66C2FF"))
highlighter.add_keyword_color("class_name", Color("#66C2FF"))
highlighter.add_keyword_color("if", Color("#FF7085"))
highlighter.add_keyword_color("elif", Color("#FF7085"))
highlighter.add_keyword_color("else", Color("#FF7085"))
highlighter.add_keyword_color("for", Color("#FF7085"))
highlighter.add_keyword_color("while", Color("#FF7085"))
highlighter.add_keyword_color("match", Color("#FF7085"))
highlighter.add_keyword_color("return", Color("#FF7085"))
highlighter.add_keyword_color("pass", Color("#FF7085"))
highlighter.add_keyword_color("break", Color("#FF7085"))
highlighter.add_keyword_color("continue", Color("#FF7085"))
highlighter.add_keyword_color("signal", Color("#66C2FF"))
highlighter.add_keyword_color("const", Color("#FF7085"))
highlighter.add_keyword_color("enum", Color("#66C2FF"))
highlighter.add_keyword_color("static", Color("#FF7085"))

# الأنواع المدمجة
highlighter.add_keyword_color("int", Color("#A3FFB0"))
highlighter.add_keyword_color("float", Color("#A3FFB0"))
highlighter.add_keyword_color("String", Color("#A3FFB0"))
highlighter.add_keyword_color("bool", Color("#A3FFB0"))
highlighter.add_keyword_color("Vector2", Color("#A3FFB0"))
highlighter.add_keyword_color("Vector3", Color("#A3FFB0"))
highlighter.add_keyword_color("Array", Color("#A3FFB0"))
highlighter.add_keyword_color("Dictionary", Color("#A3FFB0"))

# القيم الخاصة
highlighter.add_keyword_color("true", Color("#A3FFB0"))
highlighter.add_keyword_color("false", Color("#A3FFB0"))
highlighter.add_keyword_color("null", Color("#A3FFB0"))
highlighter.add_keyword_color("self", Color("#FF7085"))
highlighter.add_keyword_color("super", Color("#FF7085"))

# مناطق الألوان (النصوص والتعليقات)
highlighter.add_color_region("\"", "\"", Color("#FFE484"))      # نصوص بعلامات مزدوجة
highlighter.add_color_region("'", "'", Color("#FFE484"))        # نصوص بعلامات مفردة
highlighter.add_color_region("\"\"\"", "\"\"\"", Color("#FFE484"))  # نصوص متعددة الأسطر
highlighter.add_color_region("#", "", Color("#CDCFD280"), true)  # تعليقات (سطر واحد)
highlighter.add_color_region("##", "", Color("#CDCFD280"), true) # تعليقات توثيقية

# ألوان الأعضاء والدوال
highlighter.member_variable_color = Color("#E0E0E0")
highlighter.function_color = Color("#57B3FF")
highlighter.number_color = Color("#A3FFB0")
highlighter.symbol_color = Color("#BADFFF")

code_edit.syntax_highlighter = highlighter
```

### 3.4 نافذة الإكمال المنبثقة (Completion Popup)

#### هيكل نافذة الإكمال

```text
┌─────────────────────────────────────┐
│ 🔵 func  get_health() → int        │  ← دالة
│ 🟢 var   player_name: String       │  ← متغير
│ 🟡 const MAX_SPEED: float          │  ← ثابت
│ 🟣 signal died()                    │  ← إشارة
│ 🔴 class Enemy extends Node        │  ← صنف
│ 📁 enum  State { IDLE, ... }       │  ← تعداد
├─────────────────────────────────────┤
│ Documentation: Returns health...    │  ← وصف مختصر
└─────────────────────────────────────┘
```

#### كل عنصر في القائمة يحتوي على

```text
CompletionOption {
    kind: CodeCompletionKind    // نوع العنصر
    display_text: String        // النص المعروض
    insert_text: String         // النص المُدرج عند الاختيار
    icon: Texture2D             // أيقونة العنصر
    text_color: Color           // لون النص
    description: String         // وصف مختصر (في tooltip)
    value: Variant              // قيمة إضافية
    location: int               // أولوية الترتيب
    default_value: String       // القيمة الافتراضية (للمعاملات)
}
```

### 3.5 تلميحات المعاملات (Parameter Hints)

عند كتابة `(` بعد اسم دالة:

```text
func_name(
    ┌──────────────────────────────┐
    │ param1: int, param2: String  │  ← تلميح المعاملات
    │ ▲ المعامل الحالي مُظلل        │
    └──────────────────────────────┘
)
```

### 3.6 نقاط التوقف والعلامات (Breakpoints & Bookmarks)

```gdscript
#a نقاط التوقف
code_edit.set_line_as_breakpoint(line: int, breakpointed: bool)
code_edit.is_line_breakpointed(line: int) -> bool
code_edit.get_breakpointed_lines() -> PackedInt32Array
code_edit.clear_breakpointed_lines()
signal breakpoint_toggled(line: int)

# العلامات المرجعية
code_edit.set_line_as_bookmarked(line: int, bookmarked: bool)
code_edit.is_line_bookmarked(line: int) -> bool
code_edit.get_bookmarked_lines() -> PackedInt32Array
code_edit.clear_bookmarked_lines()

# السطر المُنفَّذ
code_edit.set_line_as_executing(line: int, executing: bool)
code_edit.is_line_executing(line: int) -> bool
code_edit.get_executing_lines() -> PackedInt32Array
code_edit.clear_executing_lines()
```

### 3.7 Minimap (الخريطة المصغرة)

```gdscript
# تفعيل الخريطة المصغرة
code_edit.minimap_draw = true
code_edit.minimap_width = 80  # العرض بالبكسل
```

---

## 4. نظام LSP (Language Server Protocol)

### 4.1 البنية المعمارية

```text
┌────────────────────────────┐
│    GDScript LSP Server     │
│  (GDScriptLanguageProtocol)│
├────────────────────────────┤
│ ► Autocompletion           │
│ ► Diagnostics              │
│ ► Go to Definition         │
│ ► Find All References      │
│ ► Symbol Search            │
│ ► Hover Documentation      │
│ ► Signature Help           │
│ ► Code Actions             │
│ ► Rename Symbol            │
│ ► Document Formatting      │
└────────────────────────────┘
        │
        │ TCP (Port 6008)
        ▼
┌────────────────────────────┐
│   External Editors         │
│ VS Code (Godot Tools)      │
│ Sublime Text               │
│ Neovim                     │
│ JetBrains Rider            │
│ Zed                        │
└────────────────────────────┘
```

### 4.2 قدرات LSP

| القدرة | الوصف |
| -------- | ------- |
| `textDocument/completion` | إكمال الكود |
| `textDocument/hover` | عرض التوثيق عند التحويم |
| `textDocument/signatureHelp` | تلميحات توقيع الدوال |
| `textDocument/definition` | الانتقال للتعريف |
| `textDocument/references` | إيجاد كل المراجع |
| `textDocument/documentSymbol` | رموز الوثيقة |
| `textDocument/formatting` | تنسيق الوثيقة |
| `textDocument/publishDiagnostics` | أخطاء وتحذيرات فورية |
| `textDocument/rename` | إعادة تسمية الرمز |
| `textDocument/codeAction` | إجراءات الكود |
| `workspace/symbol` | البحث في رموز المشروع |

---

## 5. التوثيق والتلميحات (Documentation & Tooltips)

### 5.1 تعليقات التوثيق (`##`)

```gdscript
##a صنف يمثل صحة اللاعب ويدير الضرر والشفاء.
##
## يتتبع هذا المكوّن القيمة الحالية والحد الأقصى للصحة،
## ويُصدر إشارات عند تغيّر الصحة أو موت الكيان.
class_name HealthComponent
extends Node

## يُصدر عند تغيّر قيمة الصحة.
## [br]
## [param new_health] قيمة الصحة الجديدة بعد التغيير.
signal health_changed(new_health: int)

## الحد الأقصى للصحة.
const MAX_HEALTH: int = 100

## الصحة الحالية.
@export var current_health: int = MAX_HEALTH

## يُطبّق ضرراً على الكيان.
## [br]
## [param amount] كمية الضرر المُطبَّقة.
## [br]
## [b]ملاحظة:[/b] لا يمكن أن تنخفض الصحة تحت الصفر.
## [codeblock]
## health.take_damage(25)
## [/codeblock]
func take_damage(amount: int) -> void:
    current_health = max(0, current_health - amount)
    health_changed.emit(current_health)
```

### 5.2 علامات BBCode للتوثيق

```text
[b]نص غامق[/b]
[i]نص مائل[/i]
[code]كود مضمن[/code]
[codeblock]
    كتلة كود متعددة الأسطر
[/codeblock]
[br]         → سطر جديد
[param x]    → يُبرز اسم المعامل
[member x]   → رابط لعضو
[method x]   → رابط لدالة
[signal x]   → رابط لإشارة
[constant x] → رابط لثابت
[enum x]     → رابط لتعداد
[url=...]text[/url] → رابط خارجي
```

### 5.3 هيكل Tooltip عند التحويم

```text
┌─────────────────────────────────────────┐
│ func take_damage(amount: int) -> void   │  ← التوقيع
├─────────────────────────────────────────┤
│ يُطبّق ضرراً على الكيان.               │  ← الوصف
│                                         │
│ Parameters:                             │
│   amount: int - كمية الضرر              │  ← المعاملات
│                                         │
│ ملاحظة: لا يمكن أن تنخفض الصحة تحت 0  │  ← ملاحظات
│                                         │
│ Defined in: health_component.gd:25      │  ← الموقع
└─────────────────────────────────────────┘
```

---

## 6. طي الكود (Code Folding)

### 6.1 الطي التلقائي للكتل

يعرض المحرر سهم طي (`−`/`+`) بجانب الكتل المتداخلة:

```gdscript
func _ready() -> void:          ← [−] يمكن طي
    var x = 1
    if x > 0:                   ← [−] يمكن طي
        print("positive")
        for i in range(10):     ← [−] يمكن طي
            print(i)

match value:                    ← [−] يمكن طي
    1:
        print("one")
    2:
        print("two")
```

### 6.2 مناطق الطي المخصصة (#region)

```gdscript
#region Lifecycle Methods       ← [−] يمكن طي كل المنطقة
func _init() -> void:
    pass

func _ready() -> void:
    pass
#endregion

#region Combat System
func attack() -> void:
    pass

func defend() -> void:
    pass
#endregion
```

### 6.3 API الطي

```gdscript
#a طي/فتح سطر
code_edit.fold_line(line: int)
code_edit.unfold_line(line: int)
code_edit.toggle_foldable_line(line: int)

# فحص حالة الطي
code_edit.is_line_folded(line: int) -> bool
code_edit.can_fold_line(line: int) -> bool

# طي/فتح الكل
code_edit.fold_all_lines()
code_edit.unfold_all_lines()
```

---

## 7. خريطة التطبيق لمشروعنا

### 7.1 مطابقة المكونات مع مشروع Flutter

| مكوّن Godot | المقابل في مشروعنا | الحالة |
| ------------ | ------------------- | -------- |
| `CodeEdit` | `EditorCodeField` + `GDScriptTextController` | 🔨 قيد البناء |
| `CodeHighlighter` | `GDScriptSyntaxHighlighter` (في controller) | ✅ مبني |
| `code_completion_*` | `EditorApi.getCompletions()` | 🔨 قيد البناء |
| Auto Indent | `GDScriptInputFormatter` | 🔨 قيد البناء |
| Auto Brace | `GDScriptInputFormatter` | 🔨 قيد البناء |
| Line Numbers | Gutter في `EditorCodeField` | 🔨 قيد البناء |
| Code Folding | لم يُنفَّذ بعد | 📋 مخطط |
| Breakpoints | لم يُنفَّذ بعد | 📋 مخطط |
| Minimap | لم يُنفَّذ بعد | 📋 مخطط |
| LSP | غير مطلوب (محلي) | ❌ غير مطلوب |
| Documentation | `EditorApi` tooltips | 📋 مخطط |

### 7.2 بنية البيانات المقترحة للإكمال

```dart
///a عنصر واحد في قائمة الإكمال
class CompletionItem {
  final CompletionKind kind;       // نوع العنصر
  final String displayText;        // النص المعروض
  final String insertText;         // النص المُدرج
  final String? detail;            // تفاصيل إضافية
  final String? documentation;     // وثائق
  final int sortPriority;          // أولوية الترتيب
  final String? returnType;        // نوع الإرجاع
  final List<ParameterInfo>? parameters; // المعاملات (للدوال)
}

/// أنواع عناصر الإكمال
enum CompletionKind {
  keyword,      // كلمة مفتاحية (var, func, if...)
  classType,    // صنف (Node, Sprite2D...)
  function,     // دالة
  variable,     // متغير
  constant,     // ثابت
  signal,       // إشارة
  enumType,     // تعداد
  enumValue,    // قيمة تعداد
  property,     // خاصية
  nodePath,     // مسار عقدة
  filePath,     // مسار ملف
  annotation,   // حاشية (@export, @onready...)
  snippet,      // قالب كود
}

/// معلومات معامل
class ParameterInfo {
  final String name;
  final String type;
  final String? defaultValue;
}
```

### 7.3 خوارزمية الفلترة والترتيب المقترحة

```dart
List<CompletionItem> filterAndSort(
  List<CompletionItem> items,
  String prefix,
  CompletionContext context,
) {
  // 1. فلترة بالبادئة (fuzzy match)
  final filtered = items.where((item) =>
    fuzzyMatch(item.displayText, prefix)
  ).toList();

  // 2. حساب الدرجة لكل عنصر
  for (final item in filtered) {
    item.score = calculateScore(item, prefix, context);
  }

  // 3. ترتيب حسب الدرجة
  filtered.sort((a, b) => b.score.compareTo(a.score));

  return filtered;
}

double calculateScore(CompletionItem item, String prefix, CompletionContext ctx) {
  double score = 0;

  // تطابق البادئة الدقيق
  if (item.displayText.startsWith(prefix)) score += 100;

  // القرب (scope)
  if (item.isLocal) score += 50;
  if (item.isClassMember) score += 30;
  if (item.isGlobal) score += 10;

  // ملاءمة السياق
  if (ctx.expectsType && item.kind == CompletionKind.classType) score += 40;
  if (ctx.expectsFunction && item.kind == CompletionKind.function) score += 40;

  // طول التطابق
  score += matchLength(item.displayText, prefix) * 10;

  return score;
}
```

### 7.4 قواعد Auto-Indent للتنفيذ

```dart
///a يحدد مستوى المسافة البادئة للسطر الجديد
int calculateNewLineIndent(String previousLine, int currentIndent) {
  final trimmed = previousLine.trimRight();

  // كلمات تزيد indent (تنتهي بـ :)
  final indentKeywords = [
    'if', 'elif', 'else', 'for', 'while', 'match',
    'func', 'class', 'static func',
  ];

  // هل السطر ينتهي بـ ":"
  if (trimmed.endsWith(':')) {
    return currentIndent + 1;
  }

  // هل السطر يفتح قوس بدون إغلاق
  if (hasUnclosedBracket(trimmed)) {
    return currentIndent + 1;
  }

  // كلمات dedent
  final dedentKeywords = ['pass', 'return', 'break', 'continue'];
  if (dedentKeywords.any((k) => trimmed == k || trimmed.startsWith('$k '))) {
    return currentIndent; // السطر التالي يبقى بنفس المستوى أو ينقص
  }

  return currentIndent;
}
```

---

## المراجع الكاملة

### المصادر الرسمية

1. **CodeEdit Class Reference:** <https://docs.godotengine.org/en/stable/classes/class_codeedit.html>
2. **TextEdit Class Reference:** <https://docs.godotengine.org/en/stable/classes/class_textedit.html>
3. **CodeHighlighter Class Reference:** <https://docs.godotengine.org/en/stable/classes/class_codehighlighter.html>
4. **SyntaxHighlighter Class Reference:** <https://docs.godotengine.org/en/stable/classes/class_syntaxhighlighter.html>
5. **GDScript Style Guide:** <https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html>
6. **Static Typing in GDScript:** <https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/static_typing.html>
7. **GDScript Documentation Comments:** <https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_documentation_comments.html>
8. **GDScript Reference:** <https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html>

### أدوات خارجية

1. **GDToolkit (gdformat/gdlint):** <https://github.com/Scony/godot-gdscript-toolkit>
2. **Godot Tools (VS Code Extension):** <https://marketplace.visualstudio.com/items?itemName=geequlim.godot-tools>

### كود Godot المصدري

 1. **GDScript Parser:** <https://github.com/godotengine/godot/tree/master/modules/gdscript>
 2. **CodeEdit Implementation:** <https://github.com/godotengine/godot/blob/master/scene/gui/code_edit.cpp>
 3. **GDScript LSP:** <https://github.com/godotengine/godot/tree/master/modules/gdscript/language_server>
