import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:learn_gdscript/app.dart';
import 'package:learn_gdscript/app_dependencies.dart';
import 'package:learn_gdscript/data/sqlite/database_helper.dart';
import 'package:shimmer/shimmer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('loads repository entries and filters using the active locale', (
    tester,
  ) async {
    final dependencies = await AppDependencies.create(
      databaseHelper: DatabaseHelper(inMemory: true),
      assetBundle: rootBundle,
    );
    addTearDown(dependencies.dispose);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    await dependencies.appSettingsProvider.completeOnboarding();

    await tester.pumpWidget(LearnGdscriptApp(dependencies: dependencies));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    GoRouter.of(
      tester.element(find.byType(Scaffold).first),
    ).go('/syntax-reference');
    await tester.pump();
    expect(find.byType(Shimmer), findsOneWidget);
    for (var attempt = 0; attempt < 20; attempt++) {
      if (find.byType(Shimmer).evaluate().isEmpty) break;
      await tester.pump(const Duration(milliseconds: 250));
    }
    expect(find.byType(Shimmer), findsNothing);

    expect(find.text('مستكشف الصياغة'), findsWidgets);
    expect(find.text('37 عنصر موثّق'), findsWidgets);
    expect(find.byType(TextField), findsOneWidget);

    await dependencies.appSettingsProvider.setLocale(const Locale('en'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('Syntax explorer'), findsWidgets);
    expect(find.text('37 documented entries'), findsWidgets);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.keyK);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.keyK);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    expect(
      tester.widget<TextField>(find.byType(TextField)).focusNode?.hasFocus,
      isTrue,
    );

    await tester.enterText(find.byType(TextField), 'Integer');
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Integer'), findsWidgets);
    expect(find.text('A number with no fractional part.'), findsWidgets);

    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(dependencies.progressProvider.progress?.syntaxExplorerUses, 1);
  });
}
