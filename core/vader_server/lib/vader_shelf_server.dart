export 'package:mcp_server/mcp_server.dart' hide Logger;
export 'package:shelf_plus/shelf_plus.dart' hide Server;
export 'package:vader_core/vader_core.dart';

import 'package:shelf_plus/shelf_plus.dart';
import 'package:vader_core/vader_core.dart';

final Injector injector = Injector();

class VaderShelfServer {
  const VaderShelfServer({required this.modules, this.config = const VaderServerConfig()});

  final List<VaderModule> modules;

  final VaderServerConfig config;

  Future<Handler> router() async {
    var app = Router().plus;
    for (VaderModule module in modules) {
      final services = module.services;
      injector.addInjector(services ?? Injector());

      for (Controller controller in module.controllers) {
        for (RouteHandler route in controller.handlers) {
          print("${route.route.verb}, ${controller.path + route.route.route}, ${route.handler}");
          app.add(route.route.verb, controller.path + route.route.route, route.handler);
        }
      }
    }
    injector.commit();
    await Future.delayed(Duration(seconds: 1));

    return app.call;
  }

  run() async {
    shelfRun(
      router,
      defaultBindAddress: config.host,
      defaultBindPort: config.port,
      defaultEnableHotReload: config.isDebugMode,
    );

    //if (config.isDebugMode) await HotReloader.create(debounceInterval: Duration(milliseconds: 300));

    //final List<VaderModule> serinusModules = [];

    //final app = await serinus.createApplication(
    //  entrypoint: _SerinusApp(modules: serinusModules),
    //  host: config.host,
    //  port: config.port,
    //);

    //app.use(CorsHook());
    //app.use(VaderLoggerHook(enableRequestLog: config.enableRequestLog, enableResponseLog: config.enableResponseLog));
    //await app.serve();
  }
}

class VaderServerConfig {
  final bool enableRequestLog;
  final bool enableResponseLog;
  final bool isDebugMode;
  final String host;
  final int port;

  const VaderServerConfig({
    this.enableRequestLog = false,
    this.enableResponseLog = true,
    this.isDebugMode = false,
    this.host = '0.0.0.0',
    this.port = 8000,
  });
}

// abstract class VaderHook {
//   const VaderHook();
// }
//
// class VaderLoggerHook extends VaderHook {
//   final bool enableRequestLog;
//   final bool enableResponseLog;
//
//   const VaderLoggerHook({this.enableRequestLog = false, this.enableResponseLog = true});
//
//   @override
//   Future<void> onRequest(Request request, InternalResponse response) async {
//     if (enableRequestLog) print('[${DateTime.now()}] ${request.method} ${request.uri}');
//   }
//
//   @override
//   Future<void> onResponse(Request request, dynamic data, ResponseProperties properties) async {
//     if (enableResponseLog) print('[${DateTime.now()}] ${data.status.code} ${request.method} ${request.uri}');
//   }
// }

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
  Controller({required this.path});

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
