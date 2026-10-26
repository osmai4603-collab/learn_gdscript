import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_gdscript/core/theme/blue_theme.dart';
import 'package:learn_gdscript/core/theme/editor_theme_extension.dart';
import 'package:learn_gdscript/core/theme/godot_arabic_ide_theme.dart';
import 'package:learn_gdscript/core/theme/theme_data.dart';

void main() {
  group('AppTheme.light', () {
    final light = AppTheme.light.colorScheme;
    final dark = AppTheme.dark.colorScheme;

    test('preserves the dark scheme accent hues', () {
      expect(light.brightness, Brightness.light);
      expect(_hueDifference(light.primary, dark.primary), lessThan(8));
      expect(_hueDifference(light.secondary, dark.secondary), lessThan(8));
      expect(_hueDifference(light.tertiary, dark.tertiary), lessThan(8));
    });

    test('provides accessible contrast for semantic foreground pairs', () {
      final pairs = <(Color, Color)>[
        (light.onPrimary, light.primary),
        (light.onPrimaryContainer, light.primaryContainer),
        (light.onSecondary, light.secondary),
        (light.onSecondaryContainer, light.secondaryContainer),
        (light.onTertiary, light.tertiary),
        (light.onTertiaryContainer, light.tertiaryContainer),
        (light.onError, light.error),
        (light.onErrorContainer, light.errorContainer),
        (light.onSurface, light.surface),
        (light.onSurfaceVariant, light.surface),
      ];

      for (final (foreground, background) in pairs) {
        expect(
          _contrastRatio(foreground, background),
          greaterThanOrEqualTo(4.5),
        );
      }
      expect(
        _contrastRatio(light.outline, light.surface),
        greaterThanOrEqualTo(3),
      );
    });

    test('keeps surface roles ordered from lightest to darkest', () {
      final luminances = [
        light.surfaceBright,
        light.surfaceContainerLowest,
        light.surfaceContainerLow,
        light.surfaceContainer,
        light.surfaceContainerHigh,
        light.surfaceContainerHighest,
        light.surfaceDim,
      ].map((color) => color.computeLuminance()).toList();

      for (var index = 1; index < luminances.length; index++) {
        expect(luminances[index - 1], greaterThanOrEqualTo(luminances[index]));
      }
    });
  });

  test('all app themes provide code typography through ThemeData', () {
    final themes = [
      BlueTheme().light,
      BlueTheme().dark,
      GodotArabicIdeTheme().light,
      GodotArabicIdeTheme().dark,
    ];

    for (final theme in themes) {
      final codeTextTheme = theme.extension<CodeTextTheme>();
      expect(codeTextTheme, isNotNull);
      expect(
        codeTextTheme!.bodyMedium.fontFamily,
        CodeEditorTheme.codeFontFamily,
      );
    }
  });
}

double _contrastRatio(Color first, Color second) {
  final luminances = [first.computeLuminance(), second.computeLuminance()]
    ..sort();
  return (luminances.last + 0.05) / (luminances.first + 0.05);
}

double _hueDifference(Color first, Color second) {
  final firstHue = HSLColor.fromColor(first).hue;
  final secondHue = HSLColor.fromColor(second).hue;
  final difference = (firstHue - secondHue).abs();
  return difference > 180 ? 360 - difference : difference;
}
