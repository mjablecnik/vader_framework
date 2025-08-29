import 'package:vader_app/vader_app.dart';

class {{name.pascalCase()}}Repository extends Repository {
  {{name.pascalCase()}}Repository({
    required super.httpClient,
    required super.storageClient,
  });

  Future<String> getSomething() async {
    return Future.value('Hello world');
  }
}
