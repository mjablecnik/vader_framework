import 'package:dio/dio.dart';
import 'package:vader_server_example/config.dart';
import 'dart:io' show Platform;

import 'entities/project.dart';
import 'entities/task.dart';

/// Custom exceptions for Todoist API
class TodoistApiException implements Exception {
  final String message;
  final int? statusCode;
  
  TodoistApiException(this.message, {this.statusCode});
  
  @override
  String toString() => 'TodoistApiException: $message ${statusCode != null ? '(Status: $statusCode)' : ''}';
}

class TodoistNetworkException extends TodoistApiException {
  TodoistNetworkException(String message) : super('Network error: $message');
}

class TodoistAuthException extends TodoistApiException {
  TodoistAuthException() : super('Authentication failed. Check your API token.', statusCode: 401);
}

/// Repository for interacting with the Todoist API
class TodoistRepository {
  final Dio _dio;
  final String _apiToken;
  final String _baseUrl = 'https://api.todoist.com/rest/v2';

  /// Constructor for TodoistRepository
  TodoistRepository({
    String? apiToken,
    Dio? dio,
  }) :
    _apiToken = apiToken ?? TaskConfig.todoistApiToken,
    _dio = dio ?? Dio() {
    // Configure Dio with default headers for authentication
    _dio.options.headers['Authorization'] = 'Bearer $_apiToken';
  }
  
  /// Get API token from environment variables
  static String _getApiTokenFromEnv() {
    final token = Platform.environment['TODOIST_API_TOKEN'];
    if (token == null || token.isEmpty) {
      throw TodoistApiException('Todoist API token not found. Set TODOIST_API_TOKEN environment variable.');
    }
    return token;
  }

  /// Create a new task in Todoist (handles both tasks and subtasks)
  Future<Task> createTask({
    required String content,
    String? description,
    String? projectId,
    String? parentId,
    DateTime? dueDate,
    int? priority,
  }) async {
    try {
      final data = {
        'content': content,
        if (description != null) 'description': description,
        if (projectId != null) 'project_id': projectId,
        if (parentId != null) 'parent_id': parentId,
        if (dueDate != null) 'due_date': dueDate.toIso8601String().split('T')[0],
        if (priority != null) 'priority': priority,
      };
      
      final response = await _dio.post('$_baseUrl/tasks', data: data);

      // Convert Todoist task to our Task model
      return Task(
        id: response.data['id'],
        name: response.data['content'],
        description: response.data['description'] ?? '',
        deadline: response.data['due'] != null ?
          DateTime.parse(response.data['due']['date']) : null,
        solved: response.data['completed'] ?? false,
        created: DateTime.now(),
      );
    } catch (e) {
      throw _handleApiError(e);
    }
  }

  /// Update an existing task in Todoist
  Future<Task> updateTask({
    required String taskId,
    String? content,
    String? description,
    String? projectId,
    DateTime? dueDate,
    bool? completed,
    int? priority,
  }) async {
    try {
      final data = {
        if (content != null) 'content': content,
        if (description != null) 'description': description,
        if (projectId != null) 'project_id': projectId,
        if (dueDate != null) 'due_date': dueDate.toIso8601String().split('T')[0],
        if (completed != null) 'completed': completed,
        if (priority != null) 'priority': priority,
      };
      
      final response = await _dio.post('$_baseUrl/tasks/$taskId', data: data);

      // Convert Todoist task to our Task model
      return Task(
        id: response.data['id'],
        name: response.data['content'],
        description: response.data['description'] ?? '',
        deadline: response.data['due'] != null ?
          DateTime.parse(response.data['due']['date']) : null,
        solved: response.data['completed'] ?? false,
        priority: response.data['priority'] ?? 1,
        created: DateTime.now(), // We don't get creation date from API
      );
    } catch (e) {
      throw _handleApiError(e);
    }
  }

  /// Delete a task from Todoist
  Future<bool> deleteTask(String taskId) async {
    try {
      await _dio.delete('$_baseUrl/tasks/$taskId');
      return true;
    } catch (e) {
      throw _handleApiError(e);
    }
  }

  /// List all tasks from Todoist
  Future<List<Task>> listAllTasks() async {
    try {
      final response = await _dio.get('$_baseUrl/tasks');
      
      final List<dynamic> tasksData = response.data;
      return tasksData.map((taskData) => Task(
        id: taskData['id'],
        name: taskData['content'],
        description: taskData['description'] ?? '',
        deadline: taskData['due'] != null ?
          DateTime.parse(taskData['due']['date']) : null,
        solved: taskData['completed'] ?? false,
        priority: taskData['priority'] ?? 1,
        created: DateTime.now(), // We don't get creation date from API
      )).toList();
    } catch (e) {
      throw _handleApiError(e);
    }
  }

  /// List all projects from Todoist
  Future<List<Project>> listAllProjects() async {
    try {
      final response = await _dio.get('$_baseUrl/projects');
      
      final List<dynamic> projectsData = response.data;
      return projectsData.map((projectData) => Project(
        id: projectData['id'],
        name: projectData['name'],
        created: DateTime.now(), // We don't get creation date from API
      )).toList();
    } catch (e) {
      throw _handleApiError(e);
    }
  }

  /// Get tasks for a specific project
  Future<List<Task>> getTasksByProject(String projectId) async {
    try {
      final response = await _dio.get('$_baseUrl/tasks', queryParameters: {
        'project_id': projectId,
      });
      
      final List<dynamic> tasksData = response.data;
      return tasksData.map((taskData) => Task(
        id: taskData['id'],
        name: taskData['content'],
        description: taskData['description'] ?? '',
        deadline: taskData['due'] != null ?
          DateTime.parse(taskData['due']['date']) : null,
        solved: taskData['completed'] ?? false,
        priority: taskData['priority'] ?? 1,
        created: DateTime.now(),
      )).toList();
    } catch (e) {
      throw _handleApiError(e);
    }
  }

  /// Handle errors from the Todoist API
  Exception _handleApiError(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        final statusCode = error.response!.statusCode;
        final data = error.response!.data;
        
        switch (statusCode) {
          case 401:
            return TodoistAuthException();
          case 404:
            return TodoistApiException('Resource not found', statusCode: 404);
          case 400:
            return TodoistApiException('Bad request: ${data['error'] ?? 'Unknown error'}', statusCode: 400);
          default:
            return TodoistApiException('API error: ${data['error'] ?? 'Unknown error'}', statusCode: statusCode);
        }
      }
      return TodoistNetworkException(error.message ?? 'Unknown network error');
    }
    return TodoistApiException('Unexpected error: $error');
  }
}