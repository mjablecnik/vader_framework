import 'dart:io';

import 'package:vader_console/app_info.dart';
import 'package:vader_console/commands.dart';
import 'package:vader_console/path.dart';

import 'args_parser.dart';
import 'exceptions.dart';

export 'path.dart';
export 'app_info.dart';
export 'commands.dart';
export 'user_input.dart';
export 'exceptions.dart';
export 'args_parser.dart';

Future<void> runCliApp<T extends Arguments>({
  required List<String> arguments,
  required List<Command> commands,
  required T Function(List<String>, List<Command>) parser,
  required Function(T) app,
}) async {
  try {
    final appInfo = AppInfo();
    final args = parser(arguments, commands);
    if (args.showHelp) {
      print('Name: ${appInfo.name}');
      print('Description: ${appInfo.description}');

      showHelp(commands);
    } else if (args.showVersion) {
      print("Version: ${appInfo.version}");
    } else {
      await app.call(args);
      exit(0);
    }
  } on MissingOptionException catch (error) {
    print(error.message);
    showHelp(commands);
  } on FormatException catch (error) {
    print(error.message);
    showHelp(commands);
  } catch (e) {
    print("$e\n");
  } finally {
    exit(1);
  }
}

showHelp(List<Command> commands) {
  print("\nUsage:");
  print(Arguments.getUsage(commands));
}

final path = Path();
