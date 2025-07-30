import 'package:vader_server/vader_server.dart';
import 'package:vader_server_example/core/app_module.dart';
import 'package:vader_server_example/task/task_module.dart';

Future<void> main(List<String> arguments) async {
  await VaderServer(
    modules: [AppModule(), TaskModule()],
    config: VaderServerConfig(isDebugMode: true),
    mcpConfig: VaderMcpConfig(isDebugMode: true),
  ).run();
}
