import 'dart:io';

import 'package:design_builder/utils.dart';
import 'package:recase/recase.dart';

class ComponentBuilder {
  const ComponentBuilder({required this.packageName, required this.inputPath, required this.outputPath});

  final String packageName;
  final String inputPath;
  final String outputPath;

  void buildWidget(String path, String fileName) {
    ReCase name = ReCase(fileName);
    final designPathStyle = path
        .replaceFirst(inputPath, '')
        .replaceFirst(name.snakeCase, '')
        .split('/')
        .map((e) => e.isEmpty ? e : '${e}Style')
        .join('.');

    final file = File('$path/${name.snakeCase}.dart');
    String code = file
        .readAsStringSync()
        .replaceAll(" = style!", " = (style ?? context.designTheme.$designPathStyle${name.camelCase}Style)")
        .replaceAll(
          " = widget.style!",
          " = (widget.style ?? context.designTheme.$designPathStyle${name.camelCase}Style)",
        );

    code =
        "import 'package:$packageName/$packageName.dart';\n"
        "${Utils.removeSrcExportsFromString(code, packageName: packageName)}";

    path = Directory(path.replaceFirst(inputPath, '')).parent.path;
    final outputFile = File('$outputPath$path/${name.snakeCase}/${name.snakeCase}.dart');
    outputFile.writeAsStringSync(code);
  }

  void buildStyle(String path, String fileName) {
    ReCase name = ReCase(fileName);
    final file = File('$path/${name.snakeCase}.style.dart');

    String code = file.readAsStringSync().replaceAll(
      "@tailorMixinComponent",
      "\npart '${name.snakeCase}.style.tailor.dart';\n\n@tailorMixinComponent",
    );
    final classLine = code.split('\n').where((element) => element.contains("class")).first;
    final replaceClassLine = classLine.replaceAll(
      ' {',
      ' extends ThemeExtension<${name.pascalCase}Style> with _\$${name.pascalCase}StyleTailorMixin {',
    );
    code = code.replaceAll(classLine, replaceClassLine);

    path = Directory(path.replaceFirst(inputPath, '')).parent.path;

    if (path == 'src/' || path == 'src/design') path = '';
    if (name.snakeCase == 'design') fileName = '';

    final fullPath =
        '$outputPath$path/${name.snakeCase == 'design' ? '' : name.snakeCase}/${name.snakeCase}.style.dart';
    final outputFile = File(fullPath);
    outputFile.writeAsStringSync(code);
  }

  void buildTheme(String path, String fileName) {
    ReCase name = ReCase(fileName);
    final file = File('$path/${name.snakeCase}.theme.dart');

    String code =
        "import 'package:$packageName/$packageName.dart';\n"
        "${Utils.removeSrcExportsFromString(file.readAsStringSync(), packageName: packageName)}";

    path = Directory(path.replaceFirst(inputPath, '')).parent.path;

    if (path == 'src/' || path == 'src/design') path = '';
    if (name.snakeCase == 'design') fileName = '';

    final fullPath =
        '$outputPath$path/${name.snakeCase == 'design' ? '' : name.snakeCase}/${name.snakeCase}.theme.dart';
    final outputFile = File(fullPath);
    outputFile.writeAsStringSync(code);
  }
}
