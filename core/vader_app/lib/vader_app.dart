export 'package:vader_core/vader_core.dart';
export 'package:vader_design/vader_design.dart';

export 'package:go_router/go_router.dart';
export 'package:flutter_bloc/flutter_bloc.dart';
export 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:talker_bloc_logger/talker_bloc_logger.dart';
export 'package:bloc/bloc.dart';
import 'package:bloc/bloc.dart';

export 'app_settings_provider.dart';
export 'back_button_handler.dart';
export 'splash_view.dart';
export 'vader_app_tester.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:vader_app/app_settings_provider.dart';
import 'package:vader_core/clients/logger.dart';
import 'package:vader_design/design/themes.dart';
import 'package:vader_core/clients/injector.dart';

final Injector injector = Injector();

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class VaderApp extends StatefulWidget {
  const VaderApp({
    super.key,
    required this.modules,
    required this.theme,
    this.localization,
    this.isDebug = false,
    this.preventTextScaling = false,
    this.entrypoint,
  });

  final List<VaderModule> modules;

  final VaderTheme theme;

  final bool isDebug;

  final bool preventTextScaling;

  final String? entrypoint;

  final Localization? localization;

  @override
  State<VaderApp> createState() => _VaderAppState();
}

class _VaderAppState extends State<VaderApp> {
  late final GoRouter router;

  @override
  void initState() {
    super.initState();
    Bloc.observer = TalkerBlocObserver(talker: logger.getTalker());
    setupModules();
    router = GoRouter(
      observers: [TalkerRouteObserver(logger.getTalker())],
      initialLocation: widget.entrypoint,
      navigatorKey: navigatorKey,
      routes: [for (var module in widget.modules) ...module.routes],
    );
  }

  void setupModules() {
    for (var module in widget.modules) {
      if (module.services != null) {
        injector.addInjector(module.services!);
      }
    }
    injector.commit();
  }

  @override
  Widget build(BuildContext context) {
    final supportedLocales = widget.localization?.supportedLocales ?? const <Locale>[Locale('en', 'US')];
    return LocaleProvider(
      initialLocale: widget.localization?.initialLocale ?? supportedLocales.first,
      child: ThemeProvider(
        initialTheme: widget.theme.mode,
        child: Builder(
          builder: (context) {
            return GestureDetector(
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: MaterialApp.router(
                debugShowCheckedModeBanner: widget.isDebug,
                theme: widget.theme.light,
                darkTheme: widget.theme.dark,
                themeMode: ThemeProvider.of(context).currentTheme,
                locale: widget.localization?.locale ?? LocaleProvider.of(context).locale,
                supportedLocales: supportedLocales,
                localizationsDelegates: widget.localization?.delegates,
                routeInformationParser: router.routeInformationParser,
                routeInformationProvider: router.routeInformationProvider,
                routerDelegate: router.routerDelegate,
                builder: (context, child) {
                  if (widget.preventTextScaling) {
                    return MediaQuery(
                      data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
                      child: child!,
                    );
                  } else {
                    return child!;
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class Localization {
  const Localization({this.initialLocale, this.locale, required this.supportedLocales, required this.delegates});

  final Locale? locale;
  final Locale? initialLocale;
  final Iterable<Locale> supportedLocales;
  final Iterable<LocalizationsDelegate<dynamic>> delegates;
}

abstract class VaderModule {
  abstract final List<RouteBase> routes;
  abstract final Injector? services;
}
