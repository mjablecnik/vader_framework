import 'dart:io';

import 'package:vader_console/vader_console.dart';

List<Command> commands = [
  Command(
    flag: 't',
    name: 'type',
    commandType: CommandType.option,
    commandHelp: 'Type of created code.',
  ),
  Command(
    flag: 'n',
    name: 'name',
    commandType: CommandType.option,
    commandHelp: 'Component name.',
  ),
  Command(
    flag: 'p',
    name: 'package',
    commandType: CommandType.option,
    commandHelp: 'Package name.',
  ),
  Command(
    flag: 'd',
    name: 'directory',
    commandType: CommandType.option,
    commandHelp: 'Root directory for output.',
  ),
  Command(
    flag: 'o',
    name: 'output',
    commandType: CommandType.option,
    commandHelp: 'Output directory.',
  ),
  ...CoreCommands.list,
];

class CliArguments extends Arguments {
  CliArguments({
    required super.showVersion,
    required super.showHelp,
    required super.isVerbose,
    required this.type,
    required this.package,
    required this.name,
    required this.output,
    required this.rootDirectoryPath,
  });

  final String? type;
  final String package;
  final String? name;
  final String? output;
  final String rootDirectoryPath;

  static CliArguments parse(List<String> arguments, List<Command> commands) {
    final results = ArgumentParser(commands).parse(arguments);
    return CliArguments(
      showHelp: results.wasParsed(CoreCommands.help.name),
      isVerbose: results.wasParsed(CoreCommands.verbose.name),
      showVersion: results.wasParsed(CoreCommands.version.name),
      type: Arguments.getOptionOrNull(results, option: "type"),
      package: Arguments.getOptionOrThrow(results, option: "package"),
      name: Arguments.getOptionOrNull(results, option: "name"),
      output: Arguments.getOptionOrNull(results, option: "output"),
      rootDirectoryPath: Arguments.getOptionOrNull(results, option: "directory") ?? Directory.current.path,
    );
  }
}
