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

## Installation

Add the following dependency to your `pubspec.yaml` file:

```yaml
dependencies:
  vader_server: ^0.1.0
```

Then run:

```sh
dart pub get
```

## Usage

### 1) Create a Module

Modules are the building blocks of your application. They contain controllers, middlewares, and services.

```dart
import 'package:vader_server/vader_serinus_server.dart';

class AppModule extends VaderModule {
  Injector? _injector;

  @override
  Injector? get services {
    if (_injector != null) return _injector;

    _injector = Injector();
    _injector!.addSingleton(MyService.new);
    
    return _injector!;
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
import 'package:vader_server/vader_serinus_server.dart';
import 'package:vader_server/api_response.dart';

class TaskController extends Controller {
  TaskController({super.path = '/task'}) {
    on(Route.get('/list'), _listTasks);
    on(Route.post('/'), _createTask);
  }

  Future<ApiResponse> _listTasks(RequestContext context) async {
    try {
      final taskService = injector.use<TaskService>();
      final tasks = await taskService.listAllTasks();
      return SuccessResponse.ok(data: tasks);
    } catch (e) {
      return ErrorResponse.internalServerError(message: e.toString());
    }
  }

  Future<ApiResponse> _createTask(RequestContext context) async {
    // Implementation...
  }
}
```

### 3) Set Up the Server

In your main function, initialize and run the server with your modules.

```dart
import 'package:vader_server/vader_serinus_server.dart';

Future<void> main(List<String> arguments) async {
  await VaderServer(
    modules: [AppModule(), TaskModule()],
    config: VaderServerConfig(
      port: 8000,
      enableResponseLog: true,
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
