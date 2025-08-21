import 'package:flutter/material.dart';

abstract class VaderTheme {
  const VaderTheme({this.mode = ThemeMode.system});

  abstract final Map<String, ThemeData> themes;
  final ThemeMode mode;

  ThemeData? getTheme(String name) {
    return themes.containsKey(name) ? themes[name] : null;
  }

  ThemeData? get light => getTheme('light');

  ThemeData? get dark => getTheme('dark');
}
