import 'package:vader_server/vader_server.dart';
import 'package:vader_server_example/task/task_controller.dart';
import 'package:vader_server_example/task/task_service.dart';
import 'package:vader_server_example/task/todoist_repository.dart';


class TaskModule extends VaderModule {
  @override
  Future<Injector> services(Injector i) async {
    i.addSingleton(TodoistRepository.new);
    i.addSingleton(TaskService.new);
    return i;
  }

  @override
  List<Controller> get controllers => [TaskController()];

  @override
  List<Middleware> get middlewares => [logRequests()];
}
