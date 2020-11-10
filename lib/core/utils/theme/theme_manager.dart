import 'package:flutter/material.dart';

class ThemeManager extends ValueNotifier<ThemeData> {
  ThemeData _themeData;

  ThemeData get themeData => _themeData;

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  static ThemeData defaultTheme = ThemeData(fontFamily: 'Raleway');

  ThemeManager([ThemeData initialTheme]) : _themeData = initialTheme ?? defaultTheme, super(defaultTheme);
}