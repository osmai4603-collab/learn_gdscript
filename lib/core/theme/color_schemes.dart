


import 'package:flutter/material.dart';

sealed class AppColorScheme {

  static ColorScheme get light {
    return ColorScheme.light();
  }
  
  static ColorScheme get dark {
    return ColorScheme.dark();
  }
}