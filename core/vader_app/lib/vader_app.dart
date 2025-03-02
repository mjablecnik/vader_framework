export 'package:vader_core/vader_core.dart';
export 'package:vader_design/vader_design.dart';

export 'package:go_router/go_router.dart';
export 'package:flutter_bloc/flutter_bloc.dart';
export 'package:bloc/bloc.dart';

export 'vader_module.dart';
export 'splash_view.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vader_design/design/themes.dart';
import 'package:vader_app/vader_module.dart';
import 'package:vader_core/clients/injector.dart';

final Injector injector = Injector();

class VaderApp extends StatelessWidget {
  const VaderApp({super.key, required this.modules, required this.theme, this.isDebug = false, this.entrypoint});

  final List<VaderModule> modules;

  final VaderTheme theme;

  final bool isDebug;

  final String? entrypoint;

  void setup() {
    for (var module in modules) {
      injector.addInjector(module.injector);
    }
    injector.commit();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: isDebug,
      theme: theme.light,
      darkTheme: theme.dark,
      routerConfig: GoRouter(initialLocation: entrypoint, routes: [for (var module in modules) ...module.routes]),
    );
  }
}


class Route {
  static GoRoute page(Widget page, {bool initial = false, bool enableTransition = false, String? path}) {
    path = initial ? '/' : path ?? '/${page.runtimeType.toString().replaceFirst('Page', '')}';

    if (enableTransition) {
      return GoRoute(path: path, builder: (context, state) => page);
    } else {
      return GoRoute(path: path, pageBuilder: (context, state) => NoTransitionPage(child: page));
    }
  }
}
