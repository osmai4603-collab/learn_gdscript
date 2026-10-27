import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_gdscript/ui/screens/lesson/lesson_code_block.dart';
import 'package:learn_gdscript/ui/screens/lesson/lesson_markdown_content.dart';
import 'package:learn_gdscript/ui/screens/lesson/widgets/lesson_callout_card.dart';

void main() {
  Widget wrapWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );
  }

  group('LessonMarkdownContent & Callouts Tests', () {
    testWidgets(
      'headings with inline code strip backticks and highlight code',
      (tester) async {
        const markdown =
            '## استخدام دالة `print()` في GDScript\n'
            '### 2. دور دالة `_ready()` في دورة الحياة';

        await tester.pumpWidget(
          wrapWidget(const LessonMarkdownContent(markdown: markdown)),
        );
        await tester.pumpAndSettle();

        // Ensure raw backticks do not appear on screen
        expect(find.textContaining('`print()`'), findsNothing);
        expect(find.textContaining('`_ready()`'), findsNothing);

        // Verify clean text with code inside is rendered in SelectableText
        final headingFinder = find.byWidgetPredicate(
          (widget) =>
              widget is SelectableText &&
              widget.textSpan?.toPlainText().contains('استخدام دالة') == true &&
              widget.textSpan?.toPlainText().contains('print()') == true,
        );
        expect(headingFinder, findsOneWidget);

        final subheadingFinder = find.byWidgetPredicate(
          (widget) =>
              widget is SelectableText &&
              widget.textSpan?.toPlainText().contains('دور دالة') == true &&
              widget.textSpan?.toPlainText().contains('_ready()') == true,
        );
        expect(subheadingFinder, findsOneWidget);

        // Verify step number badge 2
        expect(find.text('2'), findsOneWidget);
      },
    );

    testWidgets(
      'directive callouts > [!WARNING], > [!TIP], > [!NOTE] render callout cards',
      (tester) async {
        const markdown = '''
> [!WARNING]
> قسمة عددين صحيحين `5 / 2` تُنتج `2` وتتجاهل الكسر.

> [!TIP]
> التزم دائماً بقاعدة **Signal Up, Call Down**.

> [!NOTE]
> المتغيرات من نوع `Array` تُمرر بالمرجع.
''';

        await tester.pumpWidget(
          wrapWidget(const LessonMarkdownContent(markdown: markdown)),
        );
        await tester.pumpAndSettle();

        final cards = tester
            .widgetList<LessonCalloutCard>(find.byType(LessonCalloutCard))
            .toList();

        expect(cards.length, 3);
        expect(cards[0].type, CalloutType.warning);
        expect(cards[1].type, CalloutType.tip);
        expect(cards[2].type, CalloutType.note);

        // Ensure directive marker is NOT visible as raw text
        expect(find.textContaining('[!WARNING]'), findsNothing);
        expect(find.textContaining('[!TIP]'), findsNothing);
        expect(find.textContaining('[!NOTE]'), findsNothing);
      },
    );

    testWidgets('golden rule quotes render goldenRule callout card', (
      tester,
    ) async {
      const markdown = '''
> **قاعدة ذهبية:** السكربت المستقل لا يعمل في لعبتك ما لم يُرفق بعقدة داخل مشهد نشط.
''';

      await tester.pumpWidget(
        wrapWidget(const LessonMarkdownContent(markdown: markdown)),
      );
      await tester.pumpAndSettle();

      final goldenCardFinder = find.byWidgetPredicate(
        (widget) =>
            widget is LessonCalloutCard &&
            widget.type == CalloutType.goldenRule,
      );
      expect(goldenCardFinder, findsOneWidget);
      expect(find.textContaining('قاعدة ذهبية'), findsOneWidget);
    });

    testWidgets('inline alert list items (- ⚠️) render as callout card', (
      tester,
    ) async {
      const markdown = '''
- ⚠️ **تحذير رسمي:** نسيان وضع الأقواس `()` يمنع التشغيل.
- 💡 **توصية:** اكتب تعليقات توثيقية واضحة.
''';

      await tester.pumpWidget(
        wrapWidget(const LessonMarkdownContent(markdown: markdown)),
      );
      await tester.pumpAndSettle();

      final cards = tester
          .widgetList<LessonCalloutCard>(find.byType(LessonCalloutCard))
          .toList();

      expect(cards.length, 2);
      expect(cards[0].type, CalloutType.warning);
      expect(cards[1].type, CalloutType.tip);
    });

    testWidgets('bullet items and code blocks render properly', (tester) async {
      const markdown = '''
- النقطة الأولى مع `var x = 1` كود
- النقطة الثانية مع نص **عريض**

```gdscript
func _ready():
    print("test")
```
''';

      await tester.pumpWidget(
        wrapWidget(const LessonMarkdownContent(markdown: markdown)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LessonCodeBlock), findsOneWidget);
      expect(find.textContaining('func _ready():'), findsOneWidget);

      final bulletFinder = find.byWidgetPredicate(
        (widget) =>
            widget is SelectableText &&
            widget.textSpan?.toPlainText().contains('النقطة الأولى') == true &&
            widget.textSpan?.toPlainText().contains('var x = 1') == true,
      );
      expect(bulletFinder, findsOneWidget);
    });
  });
}
