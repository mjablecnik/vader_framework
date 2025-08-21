import 'package:flutter/material.dart';

class ThemeProvider extends InheritedNotifier<ValueNotifier<ThemeMode>> {
  ThemeProvider({super.key, required ThemeMode initialTheme, required super.child})
      : super(notifier: ValueNotifier(initialTheme));

  static ThemeProvider of(BuildContext context) {
    final ThemeProvider? result = context.dependOnInheritedWidgetOfExactType<ThemeProvider>();
    assert(result != null, 'No ThemeProvider found in context');
    return result!;
  }

  ThemeMode get currentTheme => notifier!.value;

  void setTheme(ThemeMode newTheme) {
    notifier!.value = newTheme;
  }
}

class LocaleProvider extends InheritedNotifier<ValueNotifier<Locale>> {
  LocaleProvider({super.key, required Locale initialLocale, required super.child})
      : super(notifier: ValueNotifier(initialLocale));

  static LocaleProvider of(BuildContext context) {
    final LocaleProvider? result = context.dependOnInheritedWidgetOfExactType<LocaleProvider>();
    assert(result != null, 'No LocaleProvider found in context');
    return result!;
  }

  Locale get locale => notifier!.value;

  void setLocale(Locale newLocale) {
    notifier!.value = newLocale;
  }
}
