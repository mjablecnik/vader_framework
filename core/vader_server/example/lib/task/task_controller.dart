import 'dart:convert';
import 'dart:io';

import 'package:vader_server/api_response.dart';
import 'package:vader_server/vader_server.dart';
import 'package:vader_server_example/task/task_service.dart';

import 'entities/task.dart';

class TaskController extends Controller {
  TaskController({super.path = '/task'}) {
    on(Route.post('/'), _createTask);
    on(Route.get('/list'), _listTasks);
  }

  Future<ApiResponse> _createTask(RequestContext context) async {
    final task = Task.fromJson(jsonDecode(context.body.text!));
    final taskService = injector.use<TaskService>();
    context.res.contentType = ContentType.json;

    try {
      final createdTask = await taskService.createTask(
        name: task.name,
        description: task.description,
        deadline: task.deadline,
        priority: task.priority,
      );

      return SuccessResponse.ok(data: createdTask.toJson());
    } catch (e) {
      //final errorService = injector.use<ErrorService>();
      //await errorService.createError(url, e.toString());

      return ErrorResponse.internalServerError(message: e.toString());
    }
  }

  Future<ApiResponse> _listTasks(RequestContext context) async {
    try {
      final taskService = injector.use<TaskService>();
      context.res.contentType = ContentType.json;
      final allEvents = await taskService.listAllTasks();
      return SuccessResponse.ok(data: allEvents);
    } catch (e) {
      return ErrorResponse.internalServerError(message: e.toString());
    }
  }
}
