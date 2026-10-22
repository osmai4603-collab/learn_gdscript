import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_gdscript/l10n/app_localizations.dart';
import 'package:learn_gdscript/ui/widgets/output_panel/output_panel.dart';

void main() {
  testWidgets('shows empty and success states in LTR direction', (
    tester,
  ) async {
    Widget buildPanel(OutputState state, {String? output}) => MaterialApp(
      locale: const Locale('ar'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: Scaffold(
        body: OutputPanel(state: state, output: output),
      ),
    );

    await tester.pumpWidget(buildPanel(OutputState.empty));
    expect(find.text('اضغط شغّل لرؤية الناتج'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.byType(OutputPanel))),
      TextDirection.rtl,
    );
    expect(
      Directionality.of(tester.element(find.byType(Text).last)),
      TextDirection.ltr,
    );

    await tester.pumpWidget(buildPanel(OutputState.success, output: 'Hello'));
    expect(find.text('Hello'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.byType(SelectableText).first)),
      TextDirection.ltr,
    );
  });
}
