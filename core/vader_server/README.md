# vader_server

A modular server framework for Dart applications built on top of Serinus.

## Features

- Modular architecture for organizing server components
- Dependency injection system
- Controller-based routing
- Middleware support
- Standardized API responses
- CORS support
- Request/response logging
- Hot reloading for development
- MCP (Machine Conversation Protocol) server support
- Dual HTTP/MCP handlers for unified API endpoints

## Installation

Add the following dependency to your `pubspec.yaml` file:

```yaml
dependencies:
  vader_server: ^0.2.1
```

Then run:

```sh
dart pub get
```

## Usage

### 1) Create a Module

Modules are the building blocks of your application. They contain controllers, middlewares, and services.

```dart
import 'package:vader_server/vader_server.dart';

class AppModule extends VaderModule {
  
  @override
  Future<Injector> services(Injector i) async {
    i.addSingleton(MyService.new);
    return i;
  }

  @override
  List<Controller> get controllers => [TaskController()];

  @override
  List<Middleware> get middlewares => [];
}
```

### 2) Create a Controller

Controllers handle HTTP requests and define routes.

```dart
import 'package:vader_server/vader_server.dart';
import 'package:vader_server/api_response.dart';

class TaskController extends Controller {
  TaskController({super.path = '/task'}) {
    // HTTP routes
    on(Route.get('/list'), listTasks);
    on(Route.post('/'), createTask);
    on(Route.delete('/<id>'), deleteTask);
    
    // MCP tools
    onMcp(TaskTools.listTasks, listTasks);
    onMcp(TaskTools.createTask, createTask);
    onMcp(TaskTools.deleteTask, deleteTask);
  }

  Future<ApiResponse> listTasks(HandlerContext context) async {
    try {
      final taskService = injector.use<TaskService>();
      final tasks = await taskService.listAllTasks();
      return SuccessResponse.ok(data: tasks);
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
    
    // Implementation...
    return SuccessResponse.created(data: task);
  }
  
  Future<ApiResponse> deleteTask(HandlerContext context) async {
    // Implementation...
    return SuccessResponse.ok();
  }
}

// MCP Tool definitions
class TaskTools {
  static final listTasks = McpTool(
    name: 'list_tasks',
    description: 'List all tasks',
    inputSchema: {'type': 'object', 'properties': {}},
  );
  
  static final createTask = McpTool(
    name: 'create_task',
    description: 'Create a new task',
    inputSchema: {
      'type': 'object',
      'properties': {
        'name': {'type': 'string', 'description': 'Name of the task'},
        // Other properties...
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
```

### 3) Set Up the Server

In your main function, initialize and run the server with your modules.

```dart
import 'package:vader_server/vader_server.dart';

Future<void> main(List<String> arguments) async {
  await VaderServer(
    modules: [AppModule(), TaskModule()],
    config: VaderServerConfig(
      port: 8000,
      enableCorsHeaders: true,
      isDebugMode: true,
    ),
    mcpConfig: VaderMcpConfig(
      port: 8080,
      isDebugMode: true,
    ),
  ).run();
}
```

### 4) API Responses

The package provides standardized API responses:

```dart
// Success response
return SuccessResponse.ok(data: myData);

// Error response
return ErrorResponse.notFound(message: "Resource not found");
```



## MCP Server Support

Vader Server includes built-in support for MCP (Machine Conversation Protocol) servers, allowing you to expose your API endpoints as MCP tools that can be used by AI assistants.

### Configuring MCP Server

```dart
await VaderServer(
  modules: [AppModule(), TaskModule()],
  config: VaderServerConfig(isDebugMode: true),
  mcpConfig: VaderMcpConfig(
    name: 'My MCP Server',
    port: 8080,
    isDebugMode: true,
  ),
).run();
```

### Creating MCP Tools

You can expose your controller methods as MCP tools using the `onMcp` method:

```dart
class TaskController extends Controller {
  TaskController({super.path = '/task'}) {
    // HTTP routes
    on(Route.get('/list'), listTasks);
    
    // MCP tools
    onMcp(TaskTools.listTasks, listTasks);
  }
  
  // Handler that works for both HTTP and MCP
  Future<ApiResponse> listTasks(HandlerContext context) async {
    // Implementation...
  }
}

// Define your MCP tools
class TaskTools {
  static final listTasks = McpTool(
    name: 'list_tasks',
    description: 'List all tasks',
    inputSchema: {'type': 'object', 'properties': {}},
  );
}
```

This allows you to reuse the same business logic for both HTTP endpoints and MCP tools.


## Author

👤 **Martin Jablečník**

* Website: [martin-jablecnik.cz](https://www.martin-jablecnik.cz)
* Github: [@mjablecnik](https://github.com/mjablecnik)
* Blog: [dev.to/mjablecnik](https://dev.to/mjablecnik)


## Show your support

Give a ⭐️ if this project helped you!

<a href="https://www.patreon.com/mjablecnik">
  <img src="https://c5.patreon.com/external/logo/become_a_patron_button@2x.png" width="160">
</a>


## 📝 License

Copyright © 2025 [Martin Jablečník](https://github.com/mjablecnik).<br />
This project is licensed under [MIT License](https://github.com/mjablecnik/vader_framework/blob/master/core/vader_server/LICENSE).
