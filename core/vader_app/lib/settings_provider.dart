import 'package:flutter/material.dart';

class Settings {
  final ThemeMode themeMode;
  final Locale locale;

  Settings({required this.themeMode, required this.locale});

  Settings copyWith({ThemeMode? themeMode, Locale? locale}) {
    return Settings(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
    );
  }
}

class SettingsProvider extends InheritedNotifier<ValueNotifier<Settings>> {
  SettingsProvider({super.key, required Settings initialSettings, required super.child})
      : super(notifier: ValueNotifier(initialSettings));

  static SettingsProvider of(BuildContext context) {
    final SettingsProvider? result = context.dependOnInheritedWidgetOfExactType<SettingsProvider>();
    assert(result != null, 'No AppSettingsProvider found in context');
    return result!;
  }

  Settings get currentSettings => notifier!.value;

  ThemeMode get currentTheme => notifier!.value.themeMode;

  Locale get currentLocale => notifier!.value.locale;

  void setTheme(ThemeMode newTheme) {
    notifier!.value = notifier!.value.copyWith(themeMode: newTheme);
  }

  void setLocale(Locale newLocale) {
    notifier!.value = notifier!.value.copyWith(locale: newLocale);
  }
}