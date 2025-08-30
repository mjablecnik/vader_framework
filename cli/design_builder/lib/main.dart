import 'dart:io';

import 'package:design_builder/arguments.dart';
import 'package:design_builder/builders/design_builder.dart';
import 'package:vader_console/vader_console.dart';
import 'package:yaml/yaml.dart';

void main(List<String> args) {
  runCliApp(
    arguments: args,
    commands: commands,
    parser: CliArguments.parse,
    app: (CliArguments args) {
      String getPackageName() {
        final String projectRoot = path.script.parent.path;
        final pubspecFile = File(path.join(projectRoot, 'pubspec.yaml'));
        if (!pubspecFile.existsSync()) {
          stdout.writeln('Script is not in your project.');
          exit(1);
        }

        return args.package ?? loadYaml(pubspecFile.readAsStringSync())["name"];
      }

      final sandbox = args.isDevModeEnabled ? "sandbox/" : "";
      if (args.isDevModeEnabled) print("Development mode is enabled!\n");

      DesignBuilder(
        sourcePoint: sandbox + (args.source ?? 'src'),
        targetPoint: sandbox + (args.output ?? 'out'),
        storybookPoint: sandbox + (args.storybook ?? 'storybook'),
        packageName: getPackageName(),
        themes: args.themes!,
      ).run();
    },
  );
}