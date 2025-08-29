import 'package:vader_app/vader_app.dart';

part '{{name.snakeCase()}}_state.freezed.dart';

@freezed
sealed class {{name.pascalCase()}}State with _${{name.pascalCase()}}State {
  const {{name.pascalCase()}}State._();

  const factory {{name.pascalCase()}}State.init([T? {{name.camelCase()}}]) = {{name.pascalCase()}}StateInit;

  const factory {{name.pascalCase()}}State.loading() = {{name.pascalCase()}}StateLoading;

  const factory {{name.pascalCase()}}State.failed(dynamic error) = {{name.pascalCase()}}StateFailed;

  const factory {{name.pascalCase()}}State.loaded(T {{name.camelCase()}}) = {{name.pascalCase()}}StateLoaded;
}