import 'package:vader_server/vader_server.dart';
import 'package:vader_server_example/clients/ai_client.dart';
import 'package:vader_server_example/core/error_service.dart';
import 'package:vader_server_example/clients/surrealdb_client.dart' hide Middleware;

class AppModule extends VaderModule {
  @override
  Future<Injector> services(Injector i) async {
    i.addSingleton(AiClient.new);
    i.addInstance<SurrealDB>(await SurrealDbClient.init());
    i.addSingleton(ErrorService.new);

    return i;
  }

  @override
  List<Controller> get controllers => [];

  @override
  List<Middleware> get middlewares => [logRequests()];
}
