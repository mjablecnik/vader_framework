import 'package:vader_core/vader_core.dart';
import 'package:vader_server/vader_server.dart';
import 'package:vader_server_example/clients/ai_client.dart';
import 'package:vader_server_example/core/error_service.dart';
import 'package:vader_server_example/clients/surrealdb_client.dart' hide Middleware;


class AppModule extends VaderModule {

  Injector? _injector;

  @override
  Injector? get services {
    if (_injector != null) return _injector;

    _injector = Injector();
    _injector!.addSingleton(AiClient.new);
    _injector!.addLazyInstance<SurrealDB>(SurrealDbClient.init());
    _injector!.waitFor<SurrealDB>(() {
      _injector!.addSingleton(ErrorService.new);
    });

    return _injector!;
  }

  @override
  List<Controller> get controllers => [];

  @override
  List<Middleware> get middlewares => [];
}
