import 'package:vader_app/vader_app.dart';

part '{{name.snakeCase()}}.freezed.dart';

part '{{name.snakeCase()}}.g.dart';

@freezed
abstract class {{name.pascalCase()}} extends VaderEntity with _${{name.pascalCase()}} {
  const {{name.pascalCase()}}._();

  const factory {{name.pascalCase()}}({
    @JsonKey(name: "username") required String userName,
    /*
      Add other properties here..
     */
  }) = _{{name.pascalCase()}};

  factory {{name.pascalCase()}}.fromJson(Map<String, Object?> json) => _${{name.pascalCase()}}FromJson(json);
}
