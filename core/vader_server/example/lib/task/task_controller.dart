import 'package:vader_server/api_response.dart';
import 'package:vader_server/vader_server.dart';
import 'package:vader_server_example/task/task_service.dart';

import 'entities/task.dart';

class TaskController extends Controller {
  TaskController({super.path = '/task'}) {
    on(Route.post('/'), createTask);
    on(Route.get('/list'), listTasks);
    on(Route.delete('/<id>'), deleteTask);

    onMcp(TaskTools.listTasks, listTasks);
    onMcp(TaskTools.createTask, createTask);
    onMcp(TaskTools.deleteTask, deleteTask);
  }

  Future<ApiResponse> listTasks(context) async {
    try {
      final taskService = injector.use<TaskService>();
      final allEvents = await taskService.listAllTasks();
      return SuccessResponse.ok(data: allEvents);
    } catch (e) {
      return ErrorResponse.internalServerError(message: e.toString());
    }
  }

  Future<ApiResponse> createTask(HandlerContext context) async {
    final Task task;
    if (context.httpRequest != null) {
      task = Task.fromJson(await context.httpRequest!.body.asJson);
    } else if (context.mcpArgs != null) {
      task = Task.fromJson(context.mcpArgs!);
    } else {
      return ErrorResponse.badRequest();
    }

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

  Future<ApiResponse> deleteTask(HandlerContext context) async {
    final taskService = injector.use<TaskService>();

    final String taskId;
    if (context.httpRequest != null) {
      taskId = context.httpRequest!.params['id'] as String;
    } else if (context.mcpArgs != null) {
      taskId = context.mcpArgs!['id'] as String;
    } else {
      return ErrorResponse.badRequest();
    }

    try {
      await taskService.deleteTask(taskId);
      return SuccessResponse.ok();
    } catch (e) {
      return ErrorResponse.internalServerError(message: e.toString());
    }
  }
}

class TaskTools {
  static final listTasks = McpTool(
    name: 'list_tasks',
    description: 'List all tasks',
    inputSchema: {'type': 'object', 'properties': {}},
  );
  static final createTask = McpTool(
    name: 'create_task',
    description: 'Create a new task or subtask',
    inputSchema: {
      'type': 'object',
      'properties': {
        'name': {'type': 'string', 'description': 'Name of the task'},
        'description': {'type': 'string', 'description': 'Description of the task'},
        'project_id': {'type': 'string', 'description': 'ID of the project this task belongs to'},
        'parent_id': {'type': 'string', 'description': 'ID of the parent task (for subtasks)'},
        'deadline': {
          'type': 'string',
          'description': 'Deadline for the task in ISO 8601 format (YYYY-MM-DD)',
        },
        'priority': {'type': 'integer', 'description': 'Priority of the task (1-4, where 4 is highest)'},
      },
      'required': ['name'],
    },
  );

  static final deleteTask = McpTool(
    name: 'delete_task',
    description: 'Delete a task',
    inputSchema: {
      'type': 'object',
      'properties': {
        'id': {'type': 'string', 'description': 'ID of the task to delete'},
      },
      'required': ['id'],
    },
  );
}
