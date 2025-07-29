export 'package:serinus/serinus.dart' hide Logger, LogLevel, HttpMethod;
export 'package:vader_core/vader_core.dart';

import 'package:serinus/serinus.dart';
import 'package:hotreloader/hotreloader.dart';
import 'package:vader_core/vader_core.dart';
import 'package:uuid/uuid.dart';

final Injector injector = Injector();

class VaderServer {
  const VaderServer({required this.modules, this.config = const VaderServerConfig()});

  final List<VaderModule> modules;

  final VaderServerConfig config;

  run() async {
    if (config.isDebugMode) await HotReloader.create(debounceInterval: Duration(milliseconds: 300));

    final List<Module> serinusModules = [];

    for (VaderModule module in modules) {
      final services = module.services;
      injector.addInjector(services ?? Injector());
      serinusModules.add(_SerinusModule(controllers: module.controllers, middlewares: module.middlewares));
    }
    injector.commit();
    await Future.delayed(Duration(seconds: 1));

    final app = await serinus.createApplication(
      entrypoint: _SerinusApp(modules: serinusModules),
      host: config.host,
      port: config.port,
    );
    app.use(CorsHook());
    app.use(VaderLoggerHook(enableRequestLog: config.enableRequestLog, enableResponseLog: config.enableResponseLog));
    await app.serve();
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

abstract class VaderHook extends Hook with OnRequestResponse {
  const VaderHook();
}

class VaderLoggerHook extends VaderHook {
  final bool enableRequestLog;
  final bool enableResponseLog;

  const VaderLoggerHook({this.enableRequestLog = false, this.enableResponseLog = true});

  @override
  Future<void> onRequest(Request request, InternalResponse response) async {
    if (enableRequestLog) print('[${DateTime.now()}] ${request.method} ${request.uri}');
  }

  @override
  Future<void> onResponse(Request request, dynamic data, ResponseProperties properties) async {
    if (enableResponseLog) print('[${DateTime.now()}] ${data.status.code} ${request.method} ${request.uri}');
  }
}

abstract class VaderModule {
  bool isReady = false;

  //abstract final List<RouteBase> routes;
  abstract final List<Controller> controllers;
  abstract final List<Middleware> middlewares;
  abstract final Injector? services;
}

class _SerinusModule extends Module {
  _SerinusModule({
    List<Controller> controllers = const [],
    List<Middleware> middlewares = const [],
    List<Module> modules = const [],
  }) : super(controllers: controllers, middlewares: middlewares, imports: modules, token: Uuid().v4());
}

class _SerinusApp extends Module {
  _SerinusApp({List<Module> modules = const []}) : super(imports: modules);
}
