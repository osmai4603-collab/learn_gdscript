# الإشارات والأحداث في GDScript (Signals & Events)

> **المصدر الرسمي:**
>
> - [Godot Docs — Using Signals](https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html)
> - [GDScript Reference — Signals](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html#signals)

تُعد **الإشارات (Signals)** في Godot تطبيقاً لنمط المراقب (Observer Pattern). تتيح للكائنات التواصل مع بعضها البعض دون وجود ترابط وثيق بينها (Decoupled Architecture)، وتعتبر وسيلة الاتصال القياسية عند حدوث حدث معين.

في **Godot 4**، أصبحت الإشارات كائنات من الدرجة الأولى من نوع `Signal` ولها دوالها المباشرة الخاصة مثل `.emit()` و `.connect()`.

---

## 1. تعريف الإشارات (Declaring Signals)

يتم تعريف الإشارات في أعلى السكربت باستخدام الكلمة المحجوزة `signal`:

```gdscript
extends CharacterBody2D

# 1. إشارة بسيطة بدون معلمات
signal died

# 2. إشارة تحمل معلمات
signal level_up(new_level)

# 3. إشارة مع تحديد صارم للأنواع (Typed Signals - ينصح بها في Godot 4)
signal health_changed(current_health: int, max_health: int)
signal item_collected(item_name: String, amount: int)
```

---

## 2. إطلاق الإشارات (Emitting Signals)

في Godot 4، يتم استدعاء دالة `.emit()` مباشرة على كائن الإشارة:

```gdscript
func take_damage(amount: int):
    health -= amount
    
    # إطلاق الإشارة وتمرير القيم المحددة
    health_changed.emit(health, max_health)
    
    if health <= 0:
        died.emit()
```

> **ملاحظة:** الأسلوب القديم `emit_signal("health_changed", ...)` ما زال مدعوماً للتوافق، لكن يُفضل دائماً في Godot 4 استخدام `.emit()` المباشر لأنه أسرع، ويوفر تدقيقاً تلقائياً للأخطاء (Autocomplete & Static Analysis).

---

## 3. توصيل الإشارات بالكود (Connecting Signals via Code)

### أ. التوصيل بدالة عادية

```gdscript
func _ready():
    # الصيغة الحديثة في Godot 4
    health_changed.connect(_on_health_changed)
    died.connect(_on_player_died)

# دالة الاستقبال (Callback / Listener)
func _on_health_changed(current: int, maximum: int):
    print("الصحة المحدثة: ", current, " / ", maximum)

func _on_player_died():
    print("انتهت اللعبة!")
```

### ب. التوصيل بدوال مجهولة / لامبدا (Lambda / Anonymous Functions)

ميزة قوية في Godot 4 تتيح كتابة رد الفعل مباشرة في نفس السطر أو الكتلة:

```gdscript
func _ready():
    # دالة لامبدا مختصرة
    $Button.pressed.connect(func(): print("تم النقر على الزر!"))

    # دالة لامبدا متعددة الأسطر مع وسائط
    health_changed.connect(func(cur, _max):
        health_bar.value = cur
        if cur < 20:
            flash_red()
    )
```

### ج. تمرير وسائط إضافية عبر الربط (`.bind()`)

عندما تريد تمرير بيانات إضافية للدالة المستقبلة لا ترسلها الإشارة الأصلية:

```gdscript
func _ready():
    for item in ["جرعة", "درع", "خاتم"]:
        var btn = Button.new()
        btn.text = item
        # ربط اسم العنصر كمعامل إضافي
        btn.pressed.connect(_on_item_button_pressed.bind(item))
        add_child(btn)

func _on_item_button_pressed(item_name: String):
    print("تم اختيار: ", item_name)
```

---

## 4. خيارات التوصيل المتقدمة (Connection Flags)

يمكنك تمرير رايات (Flags) كمعلمة ثانية لدالة `.connect()`:

```gdscript
# 1. الاتصال لمرة واحدة فقط (One-Shot): ينفصل التوصيل تلقائياً فور أول إطلاق للإشارة
attack_finished.connect(_on_attack_done, CONNECT_ONE_SHOT)

# 2. تأجيل الاستدعاء (Deferred): تأجيل الاستدعاء حتى نهاية الإطار الحالي
size_changed.connect(_on_resize, CONNECT_DEFERRED)
```

---

## 5. فحص وفصل الإشارات (Disconnect & Check)

```gdscript
# فحص هل الإشارة متصلة بالدالة
if health_changed.is_connected(_on_health_changed):
    # فصل الإشارة
    health_changed.disconnect(_on_health_changed)

# الحصول على جميع المشتركين المتصلين بالإشارة
var connections = health_changed.get_connections()
```

---

## 6. انتظار الإشارات بشكل متزامن (`await`)

تتيح لغة GDScript تعليق تنفيذ السكربت حتى تطلق الإشارة دون الحاجة لإنشاء دوال استقبال فرعية:

```gdscript
func start_cutscene():
    print("بدء المشهد السينمائي...")
    
    # انتظار مؤقت زمني لمدة 2 ثانية
    await get_tree().create_timer(2.0).timeout
    print("مرت ثانيتان!")

    # انتظار انتهاء حركة الأنيميشن
    $AnimationPlayer.play("fade_in")
    await $AnimationPlayer.animation_finished
    
    # انتظار نقرة اللاعب على زر المتابعة
    await $DialogBox/NextButton.pressed
    print("تم الانتقال للمرحلة التالية")
```

---

## 7. إشارات العقد المدمجة الشائعة (Common Built-in Signals)

| العقدة | الإشارة | توقيت الإطلاق |
| :--- | :--- | :--- |
| `BaseButton` (Button, CheckBox) | `pressed` | عند النقر على الزر |
| `Timer` | `timeout` | عند انتهاء وقت المؤقت |
| `Area2D` / `Area3D` | `body_entered(body: Node)` | عند دخول جسم فيزيائي نطاق المنطقة |
| `Area2D` / `Area3D` | `area_entered(area: Area2D)` | عند تداخل منطقة أخرى مع هذه المنطقة |
| `AnimationPlayer` | `animation_finished(anim_name)` | عند اكتمال تشغيل حركة |
| `Tween` | `finished` | عند اكتمال حركة الانتقال السلس |
