import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:vader_app/app_info.dart';

class Settings {
  final ThemeMode themeMode;
  final Locale locale;
  final AppInfo appInfo;

  Settings({required this.themeMode, required this.locale}) : appInfo = AppInfo.instance;

  Settings copyWith({ThemeMode? themeMode, Locale? locale}) {
    return Settings(themeMode: themeMode ?? this.themeMode, locale: locale ?? this.locale);
  }
}

class SettingsProvider extends InheritedNotifier<ValueNotifier<Settings>> {
  SettingsProvider({super.key, required Settings initialSettings, required this.storage, required super.child})
    : super(notifier: ValueNotifier(initialSettings));

  final Box storage;

  static SettingsProvider of(BuildContext context) {
    final SettingsProvider? result = context.dependOnInheritedWidgetOfExactType<SettingsProvider>();
    assert(result != null, 'No AppSettingsProvider found in context');
    return result!;
  }

  Settings get currentSettings => notifier!.value;

  ThemeMode get currentTheme => ThemeMode.values.byName(storage.get('theme') ?? currentSettings.themeMode.name);

  Locale get currentLocale => Locale(storage.get('locale') ?? currentSettings.locale.languageCode);

  AppInfo get appInfo => notifier!.value.appInfo;

  void setTheme(ThemeMode newTheme) {
    storage.put('theme', newTheme.name);
    notifier!.value = notifier!.value.copyWith(themeMode: newTheme);
  }

  void setLocale(Locale newLocale) {
    storage.put('locale', newLocale.languageCode);
    notifier!.value = notifier!.value.copyWith(locale: newLocale);
  }
}
