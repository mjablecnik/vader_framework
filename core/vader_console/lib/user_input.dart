import 'dart:io';

import 'package:cli_menu/cli_menu.dart';

class UserInput {
  static String prompt({required String message, String? defaultValue}) {
    stdout.write("\n$message: ");
    final String? result = stdin.readLineSync();

    if (result == null || result.isEmpty) {
      return defaultValue ?? prompt(message: message);
    }
    return result;
  }

  static bool question({required String question}) {
    stdout.write("\n$question (y/N) ");
    final response = stdin.readLineSync();
    return response?.toLowerCase() == 'yes' || response == 'Y' || response == 'y';
  }

  static String menu({required String message, required List<String> items}) {
    stdout.write("\n$message: ");
    final result = Menu(items).choose().toString();
    return result;
  }
}
