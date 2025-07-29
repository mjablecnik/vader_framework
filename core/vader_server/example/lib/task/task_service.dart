import 'package:vader_server_example/config.dart';
import 'package:vader_server_example/task/todoist_repository.dart';

import 'entities/project.dart';
import 'entities/task.dart';

/// Custom exceptions for TaskService
class TaskServiceException implements Exception {
  final String message;
  final Exception? cause;

  TaskServiceException(this.message, {this.cause});

  @override
  String toString() => 'TaskServiceException: $message${cause != null ? ' (Cause: $cause)' : ''}';
}

/// Service for managing tasks and projects using Todoist API
class TaskService {
  final TodoistRepository _repository;

  /// Constructor for TaskService
  TaskService({TodoistRepository? repository})
      : _repository = repository ?? TodoistRepository(apiToken: TaskConfig.todoistApiToken);

  /// List all projects
  Future<List<Project>> listAllProjects() async {
    try {
      return await _repository.listAllProjects();
    } catch (e) {
      // Pass through repository exceptions
      if (e is TodoistApiException) {
        throw e;
      }
      throw TaskServiceException('Failed to list projects', cause: e is Exception ? e : Exception(e.toString()));
    }
  }

  /// List all tasks
  Future<List<Task>> listAllTasks() async {
    try {
      return await _repository.listAllTasks();
    } catch (e) {
      if (e is TodoistApiException) {
        throw e;
      }
      throw TaskServiceException('Failed to list tasks', cause: e is Exception ? e : Exception(e.toString()));
    }
  }

  /// Get tasks for a specific project
  Future<List<Task>> getTasksByProject(String projectId) async {
    try {
      if (projectId.isEmpty) {
        throw TaskServiceException('Project ID cannot be empty');
      }
      return await _repository.getTasksByProject(projectId);
    } catch (e) {
      if (e is TodoistApiException) {
        throw e;
      }
      throw TaskServiceException('Failed to get tasks for project',
          cause: e is Exception ? e : Exception(e.toString()));
    }
  }

  /// Create a new task (handles both tasks and subtasks)
  Future<Task> createTask({
    required String name,
    String description = '',
    String? projectId,
    String? parentId,
    DateTime? deadline,
    int priority = 1,
  }) async {
    try {
      // Validate input
      if (name.isEmpty) {
        throw TaskServiceException('Task name cannot be empty');
      }

      return await _repository.createTask(
        content: name,
        description: description,
        projectId: projectId,
        parentId: parentId,
        dueDate: deadline,
        priority: priority,
      );
    } catch (e) {
      if (e is TodoistApiException) {
        throw e;
      }
      throw TaskServiceException('Failed to create task', cause: e is Exception ? e : Exception(e.toString()));
    }
  }

  /// Update an existing task
  Future<Task> updateTask({
    required String taskId,
    String? name,
    String? description,
    String? projectId,
    DateTime? deadline,
    bool? solved,
    int? priority,
  }) async {
    try {
      // Validate input
      if (taskId.isEmpty) {
        throw TaskServiceException('Task ID cannot be empty');
      }

      return await _repository.updateTask(
        taskId: taskId,
        content: name,
        description: description,
        projectId: projectId,
        dueDate: deadline,
        completed: solved,
        priority: priority,
      );
    } catch (e) {
      if (e is TodoistApiException) {
        throw e;
      }
      throw TaskServiceException('Failed to update task', cause: e is Exception ? e : Exception(e.toString()));
    }
  }

  /// Delete a task by ID
  Future<bool> deleteTask(String taskId) async {
    try {
      // Validate input
      if (taskId.isEmpty) {
        throw TaskServiceException('Task ID cannot be empty');
      }

      return await _repository.deleteTask(taskId);
    } catch (e) {
      if (e is TodoistApiException) {
        throw e;
      }
      throw TaskServiceException('Failed to delete task', cause: e is Exception ? e : Exception(e.toString()));
    }
  }
}
