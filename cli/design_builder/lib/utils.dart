class Utils {
  static String removeSrcExportsFromString(String text, {required String packageName}) =>
      text.split('\n').where((e) => !e.contains("/${packageName}_exports.dart")).join('\n');
}
