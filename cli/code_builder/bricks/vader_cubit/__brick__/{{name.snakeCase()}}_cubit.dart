import 'package:{{package.snakeCase()}}_app/features/app/logic/{{name.snakeCase()}}_state.dart';
import 'package:{{package.snakeCase()}}_app/features/app/data/{{name.snakeCase()}}_repository.dart';
import 'package:vader_app/vader_app.dart';

class {{name.pascalCase()}}Cubit extends Cubit<{{name.pascalCase()}}State> {
  {{name.pascalCase()}}Cubit({required this.repository}): super({{name.pascalCase()}}State.init()) {
    load{{name.pascalCase()}}();
  }

late final repository {{name.pascalCase()}}Repository;

void update({{name.pascalCase()}}State state) {
  emit(state);
}

Future<void> load{{name.pascalCase()}}() async {
  update({{name.pascalCase()}}State.loading());
  try {
    final result = await repository.get{{name.pascalCase()}}();
    update({{name.pascalCase()}}State.loaded(result));
  } catch (e) {
    update({{name.pascalCase()}}State.failed(e));
  }
  }
}