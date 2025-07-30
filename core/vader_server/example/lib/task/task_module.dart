import 'package:vader_server/vader_server.dart';
import 'package:vader_server_example/core/app_module.dart';
import 'package:vader_server_example/task/task_controller.dart';
import 'package:vader_server_example/task/task_service.dart';
import 'package:vader_server_example/task/todoist_repository.dart';

import '../clients/surrealdb_client.dart' hide Middleware;

class TaskModule extends AppModule {
  @override
  Injector? get services {
    final services = super.services!;
    services.waitFor<SurrealDB>(() {
      services.addSingleton(TodoistRepository.new);
      services.addSingleton(TaskService.new);
    });
    return services;
  }

  @override
  List<Controller> get controllers => [TaskController()];

  @override
  List<Middleware> get middlewares => [...super.middlewares];
}

