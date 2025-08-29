import 'package:{{package.snakeCase()}}_app/features/app/app_module.dart';
import 'package:{{package.snakeCase()}}_app/features/{{name.snakeCase()}}/pages/{{name.snakeCase()}}_page.dart';
import 'package:{{package.snakeCase()}}_app/features/{{name.snakeCase()}}/{{name.snakeCase()}}_repository.dart';
import 'package:vader_app/vader_app.dart';

class {{name.pascalCase()}}Module extends AppModule {
  @override
  List<RouteBase> get routes => [${{name.camelCase()}}Route];

  @override
  Injector? get services {
    return super.services!
      ..addSingleton({{name.pascalCase()}}Repository.new);
  }
}
