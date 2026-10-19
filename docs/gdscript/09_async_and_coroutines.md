# البرمجة غير المتزامنة ودوال التعليق في GDScript (Async, Await & Coroutines)

> **المصدر الرسمي:**
>
> - [Godot Docs — Coroutines with await](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html#awaiting-for-signals-or-coroutines)
> - [Godot Engine — Differences between Godot 3 and 4 (yield to await)](https://godotengine.org/article/gdscript-progress-report-feature-complete-4-0/)

---

## 1. الانتقال من `yield` إلى `await`

> [!IMPORTANT]
> في **Godot 4**، تم حذف الكلمة المحجوزة `yield` بالكامل، واستبدالها بنظام **`await`** الأكثر بساطة ووضوحاً وأماناً، مماثل لما هو موجود في لغات مثل JavaScript و C# و Python.

---

## 2. كيفية عمل `await`

عند استخدام `await`، يتوقف تنفيذ الدالة مؤقتاً عند ذلك السطر ويعود التحكم إلى حلقة المحرك الرئيسية (Main Loop)، دون تجميد اللعبة أو الشاشة. وعندما يتم إطلاق الإشارة المنتظرة، يستأنف الكود التنفيذ تلقائياً من حيث توقف.

أي دالة تحتوي على `await` تصبح تلقائياً **Coroutine** (دالة غير متزامنة).

```gdscript
func show_damage_effect():
    modulate = Color.RED
    # تعليق الدالة لمدة 0.2 ثانية
    await get_tree().create_timer(0.2).timeout
    modulate = Color.WHITE
```

---

## 3. أشهر استخدامات `await`

### أ. انتظار مدة زمنية محددة (Timers)

```gdscript
func countdown():
    print("3...")
    await get_tree().create_timer(1.0).timeout
    print("2...")
    await get_tree().create_timer(1.0).timeout
    print("1...")
    await get_tree().create_timer(1.0).timeout
    print("انطلق!")
```

### ب. انتظار إطار رسم أو خطوة فيزيائية (Frames)

مفيد جداً لانتظار استقرار المشهد أو تحديث القياسات:

```gdscript
func update_layout():
    # انتظار حتى يتم رسم الإطار التالي
    await get_tree().process_frame
    print("تم تحديث الشاشة ورسم العناصر")

    # انتظار الخطوة الفيزيائية التالية
    await get_tree().physics_frame
    print("تم تحديث الحسابات الفيزيائية")
```

### ج. انتظار اكتمال دالة أخرى (Coroutine to Coroutine)

عندما تستدعي دالة غير متزامنة أخرى، يمكنك انتظار نتيجتها باستخدام `await`:

```gdscript
func load_player_profile() -> Dictionary:
    print("بدء جلب البيانات...")
    await get_tree().create_timer(1.5).timeout # محاكاة تحميل
    return {"name": "أحمد", "level": 10}

func start_game():
    # انتظار نتيجة الدالة load_player_profile
    var profile: Dictionary = await load_player_profile()
    print("مرحباً بك: ", profile["name"])
```

### د. انتظار طلبات الشبكة (HTTP Requests)

```gdscript
func fetch_online_data():
    var http = HTTPRequest.new()
    add_child(http)
    
    http.request("https://api.example.com/data")
    # انتظار اكتمال الطلب واستقبال النتيجة
    var response = await http.request_completed
    
    var result_code = response[0]
    var response_code = response[1]
    var body = response[3].get_string_from_utf8()
    
    print("كود الاستجابة: ", response_code)
    http.queue_free()
```

---

## 4. أفضل الممارسات والحذر عند استخدام `await`

### أ. التحقق من سلامة العقدة بعد الاستئناف

بما أن اللعبة تستمر بالعمل أثناء الـ `await`، فقد يتم حذف الكائن أو خروجه من الشجرة قبل استئناف الدالة. لتجنب الأخطاء:

```gdscript
func safe_delayed_action():
    await get_tree().create_timer(3.0).timeout
    
    # تحقق هل الكائن ما زال موجوداً في شجرة المشهد
    if not is_inside_tree():
        return
        
    position.x += 100
```

### ب. تجنب حلقات `await` اللانهائية

تأكد دائماً من أن الإشارة المنتظرة مضمونة الإطلاق، وإلا ستظل الدالة معلقة في الذاكرة.
