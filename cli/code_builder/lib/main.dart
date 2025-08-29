import 'dart:io';

import 'package:mason/mason.dart';
import 'package:vader_console/vader_console.dart';
import 'package:code_builder/arguments.dart';

void main(List<String> args) {
  runCliApp(
    arguments: args,
    commands: commands,
    parser: CliArguments.parse,
    app: (args) async {
      final String projectRoot = path.script.parent.path;
      final pubspecExists = File(path.join(projectRoot, 'pubspec.yaml')).existsSync();
      if (!pubspecExists) {
        stdout.writeln('Script is not in your project.');
        exit(1);
      }

      String type = args.type ?? selectType(args.rootDirectoryPath);

      final String output =
          args.output ?? UserInput.prompt(message: "Output in root directory (${args.rootDirectoryPath})");

      await runGenerator(
        rootDirectoryPath: args.rootDirectoryPath,
        type: type,
        output: output,
        package: args.package,
        name: args.name ?? UserInput.prompt(message: '${type.capitalize} name'),
      );

      exit(0);
    },
  );
}

extension StringExt on String {
  String get capitalize {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

String selectType(String rootDirectoryPath) {
  final types =
      Directory(path.joinAll([rootDirectoryPath, 'bricks']))
          .listSync()
          .map((e) => path.basename(e.path))
          .where((element) => element.contains('vader_'))
          .map((e) => e.replaceFirst('vader_', ''))
          .toList();

  print('Select type of code to generate:');
  final menu = Menu(types);
  final result = menu.choose();
  return result.value;
}

Future<void> runGenerator({
  required String rootDirectoryPath,
  required String type,
  required String output,
  required String package,
  required String name,
}) async {
  final brickPath = Brick.path(path.join(path.script.parent.path, 'bricks', 'vader_$type'));
  final generator = await MasonGenerator.fromBrick(brickPath);

  final target = DirectoryGeneratorTarget(Directory(path.joinAll([rootDirectoryPath, ...path.split(output)])));

  await generator.generate(target, vars: <String, dynamic>{'name': name, 'package': package});

  stdout.writeln("${type.capitalize} with name '$name' was successfully created.");
}
