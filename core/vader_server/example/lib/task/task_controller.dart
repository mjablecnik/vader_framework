import 'dart:convert';

import 'package:vader_server/api_response.dart';
import 'package:vader_server/vader_shelf_server.dart';
import 'package:vader_server_example/task/task_service.dart';

import 'entities/task.dart';

class TaskController extends Controller {
  TaskController({super.path = '/task'}) {
    on(Route.post('/'), createTask);
    on(Route.get('/list'), listTasks);
    on(Route.get('/<taskId>'), deleteTask);
  }

  Future<ApiResponse> listTasks(Request context) async {
    try {
      final taskService = injector.use<TaskService>();
      final allEvents = await taskService.listAllTasks();
      return SuccessResponse.ok(data: allEvents);
    } catch (e) {
      return ErrorResponse.internalServerError(message: e.toString());
    }
  }

  Future<ApiResponse> createTask(Request context) async {
    final task = Task.fromJson(await context.body.asJson);
    final taskService = injector.use<TaskService>();

    try {
      final createdTask = await taskService.createTask(
        name: task.name,
        description: task.description,
        deadline: task.deadline,
        priority: task.priority,
      );

      return SuccessResponse.ok(data: createdTask.toJson());
    } catch (e) {
      return ErrorResponse.internalServerError(message: e.toString());
    }
  }

  Future<ApiResponse> deleteTask(Request context) async {
    final taskService = injector.use<TaskService>();
    final taskId = context.params['taskId'] as String;

    try {
      await taskService.deleteTask(taskId);
      return SuccessResponse.ok();
    } catch (e) {
      return ErrorResponse.internalServerError(message: e.toString());
    }
  }
}
