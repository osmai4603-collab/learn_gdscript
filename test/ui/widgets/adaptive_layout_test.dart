import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_gdscript/ui/layouts/adaptive_layout.dart';

void main() {
  testWidgets('switches builders at the configured breakpoint', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 800);
    await tester.pumpWidget(
      MaterialApp(
        home: AdaptiveLayout(
          mobileBuilder: (_) => const Text('mobile'),
          desktopBuilder: (_) => const Text('desktop'),
        ),
      ),
    );
    expect(find.text('mobile'), findsOneWidget);

    tester.view.physicalSize = const Size(1280, 800);
    await tester.pumpWidget(
      MaterialApp(
        home: AdaptiveLayout(
          mobileBuilder: (_) => const Text('mobile'),
          desktopBuilder: (_) => const Text('desktop'),
        ),
      ),
    );
    expect(find.text('desktop'), findsOneWidget);
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
