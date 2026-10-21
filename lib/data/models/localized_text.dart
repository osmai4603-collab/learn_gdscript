import 'package:flutter/widgets.dart';

import 'model_json.dart';

@immutable
class LocalizedText {
  final String ar;
  final String en;

  const LocalizedText({required this.ar, required this.en});

  factory LocalizedText.fromJson(JsonObject json) => LocalizedText(
    ar: requiredString(json, 'ar'),
    en: requiredString(json, 'en'),
  );

  /// Unsupported languages deliberately fall back to the Arabic source text.
  String resolve(Locale locale) => locale.languageCode == 'en' ? en : ar;

  JsonObject toJson() => {'ar': ar, 'en': en};

  @override
  bool operator ==(Object other) =>
      other is LocalizedText && other.ar == ar && other.en == en;

  @override
  int get hashCode => Object.hash(ar, en);
}
