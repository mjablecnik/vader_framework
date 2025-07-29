import 'package:vader_server/vader_shelf_server.dart';
import 'package:vader_server_example/core/app_module.dart';
import 'package:vader_server_example/task/task_module.dart';

Future<void> main(List<String> arguments) async {
  await VaderShelfServer(modules: [AppModule(), TaskModule()], config: VaderServerConfig(isDebugMode: true)).run();
}
