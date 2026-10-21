# تقرير الفحص والتحليل الشامل لمكتبة GDScript Engine

## (Comprehensive Audit & Architecture Analysis Report)

**تاريخ التحليل:** 20 أكتوبر 2026  
**المكتبة المفحوصة:** `gdscript_engine` (`packages/gdscript_engine`)  
**الهدف:** فحص واكتشاف الأخطاء، العيوب المعمارية، النواقص بالنسبة لمواصفات GDScript 4، الفائض والتكرار، وحالات الانهيار وحدود الذاكرة.

---

## 1. الملخص التنفيذي (Executive Summary)

تمثل مكتبة `gdscript_engine` تنفيذاً طموحاً وقوياً ومكتوباً بلغة Dart النقية لمصرف (Compiler) ومحلل (Semantic Analyzer) وآلة افتراضية معتمدة على المكدس (Stack-based Virtual Machine) لتشغيل لغة **GDScript 4**، بالإضافة إلى محرك دعم محرر الكود (`EditorAPI`) للتلوين النحوي والإكمال التلقائي.

أظهر الفحص الدقيق والتشغيل الفعلي لمجموعات الاختبارات (234 اختباراً تم تشغيلها) أن النواة البرمجية جيدة التصميم كبنية أولية، ولكنها تعاني من:

1. **أخطاء برمجية حرجة (Fatal Runtime & Compiler Bugs)** تتسبب في فشل تشغيل سيناريوهات أساسية (مثل انهيار تجميع متغيرات المستوي الأعلى وعمليات الحساب البسيطة).
2. **تسريب للمكدس (Stack Leak)** في جمل الاختيار `match`.
3. **نواقص جوهرية مقارنة بمعايير GDScript 4** (غياب كامل لكافة أنواع المتجهات `Vector2/3/4` والألوان `Color`، وغياب الـ Getters/Setters، وغياب الـ Coroutines الفعلي لـ `await`).
4. **فائض وتضخم في ملف `editor_api.dart`** (يصل إلى 130 كيلوبايت و 4000 سطر متصل دون تقسيم معياري).
5. **غياب كامل للاختبارات داخل حزمة المكتبة المستقلة**، حيث تقع كافة الاختبارات داخل تطبيق خارجي.

---

## 2. الأخطاء البرمجية الحرجة المكتشفة (Critical Bugs & Defects)

### 2.1. خطأ قاتل: انهيار المصرف عند تقييم المتغيرات العامة (`RuntimeError: Cannot add "Nil" and "Nil"`)

* **الملف المتأثر:** `lib/compiler/compiler.dart` (الأسطر 130-155 و 1440-1510)
* **المشكلة:**
  أثناء مرور التجميع المسبق لتسجيل المتغيرات والخصائص التابعة للفئة (`compileScript`):

  ```dart
  for (final decl in script.declarations) {
    if (decl is VarStmt) {
      final defVal = _evalStaticLiteral(decl.initializer);
      ...
    }
  }
  ```

  تستدعي الدالة `_evalStaticLiteral` التقييم الاستاتيكي لأي تعبير (Initializer) حتى وإن كان تعبيراً ديناميكياً يعتمد على متغيرات أخرى مثل:

  ```gdscript
  var a = 10
  var b = 25
  var c = a + b
  ```

  أو:

  ```gdscript
  var z = (x * 2) + (y / 2)
  ```

  عندما يكون المعامل `a` من نوع `IdentifierExpr`، ترجع `_evalStaticLiteral(expr.left)` القيمة `GDNull.instance`، ثم تحاول تنفيذ:

  ```dart
  case TokenType.plus:
    return left + right; // GDNull + GDNull!
  ```

  يؤدي هذا إلى رمي استثناء فوري: `GDRuntimeError: Cannot add "Nil" and "Nil"` أثناء زمن التصريف!
* **الأثر:** فشل اختبارات `Phase 9: executes basic arithmetic` واختبار التكامل `Scenario 1: Basics`، واستحالة كتابة أي سكريبت يحتوي متغيرات عليا معتمدة على بعضها.
* **الحل المطلوب:**
  يجب فحص ما إذا كان التعبير ثابتاً صريحاً (`isConstantLiteral`) قبل محاولة تقييمه، وفي حال وجود متغيرات غير ثابتة يتم تعيين الحقل بقيمة `GDNull.instance` مبدئياً، وترك التقييم الديناميكي الفعلي لكتلة البايتكود التنفيذية (`mainChunk` أو دالة `_init`).

---

### 2.2. خطأ: إخفاء وتجاهل التعليقات في التلوين النحوي (`getSyntaxHighlights`)

* **الملف المتأثر:** `lib/api/editor_api.dart` (السطر 249)
* **المشكلة:**

  ```dart
  List<SyntaxHighlight> getSyntaxHighlights(String sourceCode) {
    final source = Source.memory(sourceCode);
    final reporter = ErrorReporter();
    final lexer = Lexer(source: source, reporter: reporter); // includeComments افتراضياً false!
    final tokens = lexer.scanTokens();
  ```

  دالة `getSyntaxHighlights` تستدعي `Lexer` بالقيمة الافتراضية `includeComments = false`. ونتيجة لذلك يتجاهل المحلل المعجمي كافة التعليقات (`# comment`)، فلا تظهر أي تلوينات للتعليقات في المحرر.
* **الأثر:** فشل اختبار `EditorAPI Services getSyntaxHighlights classifies tokens accurately` وعجز واجهات المحرر عن تلوين التعليقات.
* **الحل المطلوب:** تمرير `includeComments: true` عند إنشاء كائن `Lexer` داخل `getSyntaxHighlights`.

---

### 2.3. خطأ تسريب عناصر المكدس في جمل `match` (VM Stack Leak)

* **الملف المتأثر:** `lib/compiler/compiler.dart` (الأسطر 935-955)
* **المشكلة:**
  عند تجميع جملة `match`، يقوم المترجم بنسخ الهدف `opDuplicate` لكل فرع ومقارنته. وفي نهاية الفروع:

  ```dart
      branch.body.accept(this);
      endJumps.add(_emitJump(OpCode.opJump, line)); // القفز لنهاية الـ match

      _patchJump(skipBranchJump);
    }

    // Pop the subject from stack
    _emitOp(OpCode.opPop, line); // السطر 950: حذف الهدف

    for (final ej in endJumps) {
      _patchJump(ej); // القفزات تتجاوز السطر 950!
    }
  ```

  القفزات `endJumps` التابعة للفروع المطابقة تقفز إلى ما **بعد** السطر 950. بالتالي، إذا تحقق أي فرع، يتم تنفيذ جسم الفرع ثم القفز متجاوزاً `opPop`، مما يترك عنصر الهدف (subject) عالقاً على مكدس الآلة الافتراضية طوال بقية التنفيذ!
* **الأثر:** تسريب تدريجي في مكدس الذاكرة (Stack Growth) وتشوه في مؤشر المكدس مما يسبب أخطاء `Stack overflow` أو قراءة قيم خاطئة في الدوال.
* **الحل المطلوب:** يجب أن تقفز `endJumps` قبل السطر الذي يحذف الهدف `opPop`، أو يتم استدعاء `_emitOp(OpCode.opPop)` قبل كل قفزة خروج من جسم الفرع.

---

### 2.4. خطأ تسريب المتغيرات الحبيسة (Upvalues) عند استخدام `break` و `continue`

* **الملف المتأثر:** `lib/compiler/compiler.dart` (الأسطر 970-1005)
* **المشكلة:**
  عند الخروج من النطاقات الداخلية بحلقة تكرار عبر `break` أو `continue`:

  ```dart
  for (var i = _fn.locals.length - 1;
      i >= 0 && _fn.locals[i].depth > loop.scopeDepth;
      i--) {
    _emitOp(OpCode.opPop, node.location.line);
  }
  ```

  يتم إصدار أمر الحذف `opPop` فقط دون فحص ما إذا كان المتغير قد تم اقتناصه كـ Upvalue بواسطة دالة Lambda (`_fn.locals[i].isCaptured`). بالمقابل، فإن الدالة النظامية `_endScope` تصدر أمر `opCloseUpvalue` لإغلاق المتغير وحفظ قيمته في الكومة.
* **الأثر:** إذا كانت هناك دالة لامبدا داخل الحلقة تقتنص متغيراً محلياً وتم تنفيذ `break`، تظل إشارة الـ Upvalue تشير إلى موضع غير صالح في المكدس، مما يسبب فساداً في قيم المتغيرات الحبيسة لاحقاً.

---

### 2.5. خطأ الفائض الصامت لعدد المتغيرات المحلية (Local Variables Overflow)

* **الملف المتأثر:** `lib/compiler/opcode.dart` و `lib/runtime/vm.dart` (السطر 707)
* **المشكلة:**
  أوامر جلب وتعيين المتغيرات المحلية `OpCode.opGetLocal` و `OpCode.opSetLocal` تعتمد على معامل بحجم **Byte واحد فقط (8-bit)**:

  ```dart
  case OpCode.opGetLocal:
    final slot = frame.readByte();
    push(stack[frame.slotsOffset + slot]);
  ```

  بينما في `compiler.dart`:

  ```dart
  int _addLocal(String name) {
    _fn.locals.add(...);
    return _fn.locals.length - 1;
  }
  ```

  المصرف لا يتحقق مما إذا كان `slot > 255`، ولا يوجد أمر `opGetLocalLong` (16-bit). إذا زاد عدد المتغيرات المحلية في دالة عن 255، يحدث التفاف صامت للرقم (Silent Truncation) ليعود إلى المتغير 0 أو 1، مسبباً دماراً في بيانات المكدس دون أي تحذير تصريفي.

---

### 2.6. خطأ الانهيار بالتكرار اللانهائي للأوعية الدائرية (Cyclic Reference Crash)

* **الملف المتأثر:** `lib/runtime/value.dart` (الأسطر 816-829 في `GDArray` و 870-890 في `GDDictionary`)
* **المشكلة:**
  عوامل المقارنة `==` ودوال التجزئة `hashCode` والتحويل إلى نصوص `toGDString()` في المصفوفات والقواميس تطبق استدعاءً تكرارياً غير محمي:

  ```dart
  for (var i = 0; i < elements.length; i++) {
    if (elements[i] != other.elements[i]) return false;
  }
  ```

  إذا احتوت مصفوفة على نفسها كعنصر (`a.append(a)`)، فإن مقارنتها أو استدعاء `print(a)` يؤدي إلى انهيار فوري في Dart بسبب `StackOverflowError` غير قابل للاعتراض.
* **الحل المطلوب:** استخدام تقنية تتبع الزيارات (Visited Set / Identity Map) لمنع التكرار اللانهائي عند تكرار المراجع.

---

### 2.7. خطأ تجاهل المعاملات المقيدة في مساواة الدوال (`GDCallable` Equality Bug)

* **الملف المتأثر:** `lib/objects/gd_callable.dart` (الأسطر 108-116 و 214-222)
* **المشكلة:**
  تتجاهل دالة المساواة `operator ==` كلياً مصفوفة `boundArguments`:

  ```dart
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GDUserFunctionCallable &&
          function == other.function &&
          target == other.target &&
          unbindCount == other.unbindCount); // أين boundArguments؟!
  ```

  إذا قمت بربط وسيطة معينة `fn.bind([1])` وقارنتها مع `fn.bind([2])`، سيعتبرهما المحرك متطابقين تماماً.
* **الأثر:** في نظام الإشارات `GDSignal.connect`، إذا حاولت ربط دالة مع معاملات مختلفة بإشارة واحدة، سيرمي المحرك خطأً بأن الإشارة متصلة مسبقاً!

---

### 2.8. خلل خطوة التنفيذ الفردية في المصحح (`stepInto` Debugger Issue)

* **الملف المتأثر:** `lib/runtime/vm.dart` (الأسطر 1204-1248)
* **المشكلة:**
  دالة `stepInto()` تعالج فقط 6 أوامر أساسية (`opAdd`, `opPop`, `opReturn` إلخ)، أما لبقية الأوامر فتقوم بما يلي:

  ```dart
  default:
    frame.ip--;
    _run(); // استدعاء تشغيل كامل حتى النهاية!
  ```

  هذا يعني أن محاولة تنفيذ خطوة واحدة داخل حلقة، استدعاء دالة، شرط، أو وصول لعنصر يؤدي إلى إكمال تشغيل البرنامج كاملاً بدلاً من التقدم تعليمة بايتكود واحدة.

---

## 3. النواقص والميزات غير المكتملة (Incomplete GDScript 4 Features)

تفتقر المكتبة في وضعها الحالي إلى مجموعة واسعة من ركائز لغة GDScript 4:

| الميزة الناقصة | الوصف في معيار GDScript 4 | الحالة في المكتبة الحالية |
| :--- | :--- | :--- |
| **أنواع المتجهات والرياضيات** | `Vector2`, `Vector2i`, `Vector3`, `Vector3i`, `Vector4`, `Vector4i`, `Color`, `Rect2`, `Transform2D`, `Transform3D`, `Quaternion`, `Plane`, `AABB`, `Basis` | **غير موجودة كلياً**. محاولة استدعاء `Vector2(1, 2)` تؤدي إلى خطأ `Undefined variable`. تم تسجيل الثوابت العددية فقط `TYPE_VECTOR2` في `GlobalScope`. |
| **المصفوفات المعبأة (Packed Arrays)** | `PackedByteArray`, `PackedInt32Array`, `PackedFloat32Array`, `PackedStringArray`, `PackedVector2Array` | **غير مدعومة**. يتم التعامل مع كل شيء عبر `GDArray` العامة التي تستهلك ذاكرة أكبر بكثير. |
| **الخصائص بمعدلات الجلب والتعيين (Getters & Setters)** | بناء الجملة الرسمي: `var speed: int: get: return _speed; set(v): _speed = v` | **غير مدعوم نهائياً**. المحلل النحوي يرمي خطأ صياغة فور رؤية نقطتين `:` بعد تعريف المتغير. |
| **معامل تشكيل النصوص (`%`)** | التشكيل المشهور للطباعة: `"Score: %d, Name: %s" % [100, "Hero"]` | **غير مدعوم**. استدعاؤه يرمي خطأ `Modulo not supported for "String"` لأن `GDString` لا تحتوي على تطبيق لمعامل `%`. |
| **التزامن والانتظار (`await`)** | تعليمة `await` لتعليق التنفيذ واستئنافه بعد انتهاء إشارة أو Future | **هيكل صوري (Stub)**. داخل `compiler.dart`: `visitAwaitExpr` يقوم فقط بتصريف التعبير الداخلي كأنه أمر عادي دون أي تعليق أو تفاعل مع حدث Dart التزامني. |
| **التحميل المسبق (`preload`)** | تحميل وتصريف الموارد والسكريبتات الأخرى في زمن التصريف | **صوري فقط**. يكتفي بإرجاع نص المسار كـ `GDString` دون تحميل حقيقي أو استيراد لأي فئة. |
| **مطابقة الأنماط المتقدمة في `match`** | تفكيك المصفوفات `[var a, var b]`، مطابقة القواميس، ومطابقة الأنواع | **غير مكتمل**. يدعم فقط المقارنة المساواتية البسيطة والرمز العام `_`. |
| **الوسوم والبيانات الوصفية (Annotations)** | `@export`, `@export_range`, `@onready`, `@tool`, `@rpc` | **مهملة في التنفيذ**. يتم تحليلها نحوياً فقط، ولكن المصرف يتركها معلقة دون أي سلوك تشغيلي (مثلاً `@onready` لا تؤجل التهيئة). |

---

## 4. العيوب المعمارية والتصميمية (Architectural & Design Flaws)

### 4.1. تجاوز محلل مسارات التحكم في المحرك (`ControlFlowAnalyzer Bypass`)

* تم تصميم فئة `SemanticAnalyzer` لتوحيد ثلاث مراحل:
  1. `Resolver` (حل الأسماء والنطاقات)
  2. `ControlFlowAnalyzer` (فحص مسارات الدوال الميتة والـ return الناقص)
  3. `TypeChecker` (فحص وتوافق الأنواع)
* لكن في `GDScriptEngine.executeSync()`، يتم استدعاء `Resolver` و `TypeChecker` مباشرة وتجاهل `ControlFlowAnalyzer` بالكامل!
* **النتيجة:** لا يتم التحقق من أن الدوال ذات الأنواع المحددة تُرجع قيماً في كافة المسارات، ولا يتم تنبيه المستخدم بالكود الميت (Dead Code).

### 4.2. تضخم وتراكم ملف `editor_api.dart` (Monolithic Code Bloat)

* حجم الملف يتجاوز **130,000 بايت** (ما يقارب 4,000 سطر برمجي في ملف واحد).
* يحتوي الملف على جداول إكمال ضخمة مضمنة في الشفرة، وقواميس توثيق، وتصنيفات مفردات نصية ثابتة ومكررة كان ينبغي فصلها إلى وحدات مستقلة:
  * `editor_data_keywords.dart`
  * `editor_data_builtins.dart`
  * `editor_data_docs.dart`
  * `editor_highlighter.dart`
* هذا التضخم يجعل صيانة الكود صعبة ويزيد من وقت التجميع والتحليل الثابت.

### 4.3. عدم منع وصول الدوال الساكنة لأعضاء الكائن (Static Function Safety Violation)

* في `resolver.dart` يتم التحقق من عدم استخدام الكلمة المفتاحية `self` داخل الدوال الساكنة (`static func`).
* **ولكن الثغرة:** إذا قام المطور بكتابة اسم الحقل مباشرة مثل `health = 50` داخل `static func foo()`, فإن `Resolver` لا يرمي أي خطأ مع أن `health` حقل كائن وليست متغيراً محلياً، مما يسبب سلوكاً تشغيلياً مبهماً أو تعديلاً غير مقصود في البيئة العامة.

---

## 5. الفائض والتكرار (Redundancy & Dead Code)

1. **النسخ المتطابق للكود عبر المشاريع:**
   * يوجد نسختان متطابقتان بنسبة 100% من المحرك:
     * الأولى في: `/home/osm/flutter_projects/learn_gdscript/packages/gdscript_engine/`
     * الثانية في: `/home/osm/flutter_projects/gdscript_editor/lib/gdscript_engine/`
   * هذا التكرار الكامل يعرض الصيانة للخطر، حيث قد يتم تعديل أو إصلاح خطأ في مكان ونسيانه في الآخر.
2. **تكرار معالجة النصوص:**
   * توجد معالجات النصوص مرتين: مرة في `GDStringHelpers` ومرة في دوال الإحالة بداخل `BuiltinTypes._resolveStringMethod`.
3. **الدوال الصورية المهملة (No-op Visitors):**
   * في عدة ملفات توجد دوال زيارة (Visitors) فارغة تعود بـ `false` أو `null` مثل `visitAnnotationDecl` دون حتى تسجيل تحذير بعدم دعم الميزة.

---

## 6. مشاكل الأداء وإدارة الذاكرة (Performance & Memory)

1. **نمو مكدس الآلة الافتراضية دون تقليص:**
   * دالة `push()` تقوم بمضاعفة حجم قائمة `stack` كلما امتلأت، ولكن عند تنفيذ آلاف العمليات ثم انتهاء الدوال، لا يتم تقليص المصفوفة (`shrink`) على الإطلاق، مما يبقي سعة المكدس محجوزة في الذاكرة طوال دورة حياة كائن `VM`.
2. **استنساخ الأوعية في الكائنات (`GDInstance`):**
   * عند إنشاء كائن جديد، يتم استنساخ كافة المصفوفات والقواميس المبدئية (`duplicate()`) حتى لو لم يتم تعديلها، مما يولد كائنات إضافية في مجمع النفايات (Garbage Collector).

---

## 7. العيوب في إدارة الحزمة والاختبارات (Package & Testing Shortcomings)

1. **انعدام الاختبارات داخل حزمة المكتبة المستقلة:**
   * لا يوجد مجلد `test/` داخل `packages/gdscript_engine/`.
   * ملف `pubspec.yaml` لا يحتوي على `dev_dependencies` ولا يدرج مكتبة `test`.
   * الاختبارات الفعلية للمكتبة موجودة فقط داخل مشروع المحرر الخارجي `gdscript_editor/test/gdscript_engine/`.
2. **غياب إعدادات الـ Linters:**
   * لا يوجد ملف `analysis_options.yaml` مستقل داخل مجلد المكتبة لفرض قواعد النمط البرمجي الصارم وجودة الكود.

---

## 8. خطة وتوصيات المعالجة والتطوير (Actionable Roadmap)

### أولوية قصوى (Immediate Fixes)

1. **إصلاح `_evalStaticLiteral` في `compiler.dart`:**
   * التأكد من عدم تقييم التعبيرات غير الثابتة (مثل العمليات الحسابية بين المتغيرات) وقت التجميع، وحفظ التهيئة ليتم تنفيذها في البايتكود.
2. **إصلاح استدعاء التعليقات في `editor_api.dart`:**
   * تمرير `includeComments: true` للـ `Lexer` في دالة `getSyntaxHighlights`.
3. **تصحيح تسريب مكدس `match` في `compiler.dart`:**
   * إصلاح قفزات `endJumps` بحيث تنفذ `opPop` لحذف قيمة المقارنة.
4. **تضمين الـ Upvalues عند الخروج بحلقات التكرار:**
   * استدعاء `opCloseUpvalue` للمتغيرات المحتجزة في `break` و `continue`.

### أولوية متوسطة (Architectural Refactoring)

1. **تفعيل `ControlFlowAnalyzer` في المحرك:**
   * استدعاء `SemanticAnalyzer` الموحد بدلاً من تجاوز الفحص في `GDScriptEngine.executeSync`.
2. **إضافة فئات المتجهات الأساسية لـ Godot:**
   * إنشاء كائنات `GDVector2` و `GDVector3` و `GDColor` ودعم عملياتها الرياضية لتمكين تجربة GDScript حقيقية.
3. **تفكيك ملف `editor_api.dart`:**
   * فصل الجداول الثابتة والتوثيقات ومحركات الإكمال في ملفات متخصصة تحت مجلد `lib/api/editor/`.

### أولوية حزمية وتكاملية

1. **نقل وتوطين الاختبارات:**
   * نقل مجلد الاختبارات من `gdscript_editor/test/gdscript_engine` إلى `packages/gdscript_engine/test` وتفعيل `dart test` المستقل داخل الحزمة.
2. **اعتماد المكتبة كـ Path Dependency:**
   * جعل مشروع `gdscript_editor` يعتمد على `packages/gdscript_engine` كحزمة محلية مساراً (`path: ../learn_gdscript/packages/gdscript_engine`) وحذف النسخة المكررة لضمان وجود مصدر وحيد للحقيقة (Single Source of Truth).
