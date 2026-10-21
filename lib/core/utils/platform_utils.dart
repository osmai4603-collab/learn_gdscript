import 'package:flutter/foundation.dart';

abstract final class PlatformUtils {
  static bool get isWeb => kIsWeb;
  static bool get supportsLocalProcess =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.windows);
}
