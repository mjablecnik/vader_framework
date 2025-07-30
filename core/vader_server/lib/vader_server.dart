export 'package:mcp_server/mcp_server.dart' hide Logger;
export 'package:shelf_plus/shelf_plus.dart' hide Server;
export 'package:vader_core/vader_core.dart';

import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_plus/shelf_plus.dart';
import 'package:vader_core/vader_core.dart';

final Injector injector = Injector();

class VaderShelfServer {
  const VaderShelfServer({required this.modules, this.config = const VaderServerConfig()});

  final List<VaderModule> modules;

  final VaderServerConfig config;

  Middleware? _getCombinedMiddleware(List<Middleware> middlewares) {
    if (middlewares.isEmpty) return null;
    if (middlewares.length == 1) return middlewares.first;
    return middlewares.reduce((combined, next) => combined + next);
  }

  Future<Handler> router() async {
    var app = Router().plus;
    if (config.enableCorsHeaders) app.use(corsHeaders());
    for (VaderModule module in modules) {
      for (Controller controller in module.controllers) {
        for (RouteHandler route in controller.handlers) {
          if (route.route.route == '/') {
            if (config.isDebugMode) print("${route.route.verb}, ${controller.path}, ${route.handler}");
            app.add(route.route.verb, controller.path, route.handler, _getCombinedMiddleware(module.middlewares));
          }
          if (config.isDebugMode) {
            print("${route.route.verb}, ${controller.path + route.route.route}, ${route.handler}");
          }
          app.add(
            route.route.verb,
            controller.path + route.route.route,
            route.handler,
            _getCombinedMiddleware(module.middlewares),
          );
        }
      }
    }

    return app.call;
  }

  setupInjector() async {
    for (VaderModule module in modules) {
      final services = module.services;
      injector.addInjector(services ?? Injector());
    }
    injector.commit();
    await Future.delayed(Duration(seconds: 1));
  }

  run() async {
    await setupInjector();
    shelfRun(
      router,
      defaultBindAddress: config.host,
      defaultBindPort: config.port,
      defaultEnableHotReload: config.isDebugMode,
    );
  }
}

class VaderServerConfig {
  final bool enableCorsHeaders;
  final bool isDebugMode;
  final String host;
  final int port;

  const VaderServerConfig({
    this.enableCorsHeaders = true,
    this.isDebugMode = false,
    this.host = '0.0.0.0',
    this.port = 8000,
  });
}

abstract class VaderModule {
  bool isReady = false;
  bool enableMcp = false;

  //abstract final List<RouteBase> routes;
  abstract final List<Controller> controllers;
  abstract final List<Middleware> middlewares;
  abstract final Injector? services;
}

typedef ReqResHandler = Future Function(Request context);

class RouteHandler {
  final Route route;
  final ReqResHandler handler;

  const RouteHandler(this.route, this.handler);
}

/// The [Controller] class is used to define a controller.
abstract class Controller {
  /// The [path] property contains the path of the controller.
  final String path;

  /// The [Controller] constructor is used to create a new instance of the [Controller] class.
  Controller({this.path = '/'});

  final List<RouteHandler> handlers = [];

  /// The [on] method is used to register a route.
  ///
  /// It takes a [Route] and a [ReqResHandler].
  ///
  /// It should not be overridden.
  @mustCallSuper
  void on<R extends Route>(R route, ReqResHandler handler) {
    handlers.add(RouteHandler(route, handler));
  }
}
