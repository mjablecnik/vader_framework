export 'package:mcp_server/mcp_server.dart' hide Logger;
export 'package:shelf_plus/shelf_plus.dart' hide Server;
export 'package:vader_core/vader_core.dart';

import 'dart:convert';

import 'package:mcp_server/mcp_server.dart' as mcp;
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_plus/shelf_plus.dart';
import 'package:vader_core/vader_core.dart';

final Injector injector = Injector();

class VaderServer {
  const VaderServer({
    required this.modules,
    this.config = const VaderServerConfig(),
    this.mcpConfig = const VaderMcpConfig(),
    this.setupDelay = const Duration(seconds: 1),
  });

  final List<VaderModule> modules;

  final VaderServerConfig config;
  final VaderMcpConfig mcpConfig;
  final Duration setupDelay;

  Middleware? _getCombinedMiddleware(List<Middleware> middlewares) {
    if (middlewares.isEmpty) return null;
    if (middlewares.length == 1) return middlewares.first;
    return middlewares.reduce((combined, next) => combined + next);
  }

  Future<Handler> _router() async {
    var app = Router().plus;
    if (config.enableCorsHeaders) app.use(corsHeaders());
    for (VaderModule module in modules) {
      for (Controller controller in module.controllers) {
        for (RouterHandler routerHandler in controller.handlers) {
          final router = routerHandler.router as Route;
          handler(Request req) => routerHandler.handler.call(HandlerContext(httpRequest: req));

          if (router.route == '/') {
            if (config.isDebugMode) print("${router.verb}, ${controller.path}, $handler");
            app.add(router.verb, controller.path, handler, _getCombinedMiddleware(module.middlewares));
          }
          if (config.isDebugMode) {
            print("${router.verb}, ${controller.path + router.route}, $handler");
          }
          app.add(router.verb, controller.path + router.route, handler, _getCombinedMiddleware(module.middlewares));
        }
      }
    }

    return app.call;
  }

  _setupInjector() async {
    for (VaderModule module in modules) {
      final services = module.services;
      services.call(injector);
    }
    await Future.delayed(setupDelay);
    injector.commit();
  }

  run() async {
    await _setupInjector();
    shelfRun(
      _router,
      defaultBindAddress: config.host,
      defaultBindPort: config.port,
      defaultEnableHotReload: config.isDebugMode,
    );
    await _runMcp();
  }

  _registerTools(mcp.Server server) {
    for (VaderModule module in modules) {
      for (Controller controller in module.controllers) {
        for (RouterHandler routerHandler in controller.mcpHandlers) {
          final tool = (routerHandler.router as McpTool);
          if (mcpConfig.isDebugMode) print('Registering tool: ${tool.name}');
          server.addTool(
            name: tool.name,
            description: tool.description,
            inputSchema: tool.inputSchema,
            handler: (args) async {
              final result = (await routerHandler.handler.call(HandlerContext(mcpArgs: args))).toJson();
              return mcp.CallToolResult(
                content: [
                  mcp.TextContent.fromJson({"text": jsonEncode(result)}),
                ],
              );
            },
          );
        }
      }
    }
  }

  _runMcp() async {
    final serverResult = await mcp.McpServer.createAndStart(
      config: mcp.McpServer.simpleConfig(name: mcpConfig.name, version: mcpConfig.version),
      transportConfig:
          mcpConfig.transportConfig ??
          mcp.TransportConfig.sse(host: mcpConfig.host, port: mcpConfig.port, endpoint: mcpConfig.endpoint),
    );

    serverResult.fold((server) async {
      _registerTools(server);
    }, (error) => print('Server failed: $error'));
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

class VaderMcpConfig {
  final bool isDebugMode;
  final String name;
  final String version;
  final String endpoint;
  final String host;
  final int port;
  final mcp.TransportConfig? transportConfig;

  const VaderMcpConfig({
    this.name = 'Vader MCP server',
    this.version = '1.0.0',
    this.endpoint = '/sse',
    this.transportConfig,
    this.isDebugMode = false,
    this.host = '0.0.0.0',
    this.port = 8080,
  });
}

abstract class VaderModule {
  bool isReady = false;
  bool enableMcp = false;

  abstract final List<Controller> controllers;
  abstract final List<Middleware> middlewares;
  Future<Injector> services(Injector i);
}

typedef ReqResHandler = Future Function(HandlerContext context);

class HandlerContext {
  final Request? httpRequest;
  final Map<String, dynamic>? mcpArgs;

  HandlerContext({this.httpRequest, this.mcpArgs});
}

class RouterHandler<T> {
  final T router;
  final ReqResHandler handler;

  const RouterHandler(this.router, this.handler);
}

/// The [Controller] class is used to define a controller.
abstract class Controller {
  /// The [path] property contains the path of the controller.
  final String path;

  /// The [Controller] constructor is used to create a new instance of the [Controller] class.
  Controller({this.path = '/'});

  final List<RouterHandler> handlers = [];
  final List<RouterHandler> mcpHandlers = [];

  @mustCallSuper
  void on(Route route, ReqResHandler handler) {
    handlers.add(RouterHandler(route, handler));
  }

  @mustCallSuper
  void onMcp(McpTool tool, ReqResHandler handler) {
    mcpHandlers.add(RouterHandler(tool, handler));
  }
}

class McpTool {
  final String name;
  final String description;
  final Map<String, dynamic> inputSchema;

  const McpTool({required this.name, required this.description, required this.inputSchema});
}
