import 'package:flutter/material.dart';
import 'package:learn_gdscript/l10n/app_localizations.dart';

extension AppContextExtensions on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
  bool get isWideLayout => MediaQuery.sizeOf(this).width >= 840;
}
