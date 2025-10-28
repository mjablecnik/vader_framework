import 'dart:io';

import 'package:design_builder/builders/component_builder.dart';
import 'package:design_builder/builders/export_builder.dart';
import 'package:design_builder/builders/storybook_builder.dart';
import 'package:design_builder/builders/style_builder.dart';
import 'package:design_builder/builders/theme_builder.dart';
import 'package:design_builder/utils.dart';
import 'package:recase/recase.dart';

class DesignBuilder {
  DesignBuilder({
    required this.sourcePoint,
    required this.targetPoint,
    required this.storybookPoint,
    required this.packageName,
    required this.themes,
  }) {
    _exportBuilder = ExportBuilder(sourcePoint: sourcePoint, packageName: packageName);
  }

  final String sourcePoint;
  final String targetPoint;
  final String storybookPoint;
  final String packageName;
  final List<String> themes;
  late final ExportBuilder _exportBuilder;

  String get inputDesignPath => "$sourcePoint/design/";

  String get outputDesignPath => '$targetPoint/design/';

  String get inputThemePath => "$sourcePoint/theme/";

  String get outputThemePath => '$targetPoint/theme/';

  String get inputConstantsPath => "$sourcePoint/constants/";

  String get outputConstantsPath => '$targetPoint/constants/';

  run() {
    final (:directories, :files) = getSourcePaths();

    directoryStructureProcess(directories);
    fileStructureProcess(files);
    _copyConstantsDirectory(Directory(inputConstantsPath), Directory(outputConstantsPath));

    _exportBuilder.build(targetPoint);
  }

  void _copyConstantsDirectory(Directory source, Directory target) {
    source.listSync().forEach((element) {
      if (element is File) {
        final file = File(element.path);
        final targetFile = File('${target.path}/${file.path.split('/').last}');
        targetFile.createSync(recursive: true);
        String content = file.readAsStringSync();

        if (content.contains("/${packageName}_exports.dart';")) {
          content =
              "import 'package:$packageName/$packageName.dart';\n"
              "${Utils.removeSrcExportsFromString(content, packageName: packageName)}";
        }

        targetFile.writeAsStringSync(content);
        _exportBuilder.add(element.path);
      } else if (element is Directory) {
        final targetElement = Directory('${target.path}/${element.path.split('/').last}');
        targetElement.createSync(recursive: true);
        _copyConstantsDirectory(element, targetElement);
      }
    });
  }

  void fileStructureProcess(List<String> filePaths) {
    print("Building file structure...");

    final storybookBuilder = StorybookBuilder(packageName, storybookPoint);
    final themeBuilder = ThemeBuilder(packageName, themes);
    final componentBuilder = ComponentBuilder(
      packageName: packageName,
      inputPath: inputDesignPath,
      outputPath: outputDesignPath,
    );

    for (String filePath in filePaths) {
      final pathList = filePath.split('/');
      final fileList = pathList.last.split('.');

      final fileType = fileList.last;
      if (fileType != 'dart') continue;

      final type = fileList[1];
      final name = fileList.first;
      final path = pathList.sublist(0, pathList.length - 1).join('/');

      switch (type) {
        case 'widget' || 'dart':
          componentBuilder.buildWidget(path, name);
          _exportBuilder.add(filePath);
          break;
        case 'style':
          componentBuilder.buildStyle(path, name);
          _exportBuilder.add(filePath);
          break;
        case 'story':
          storybookBuilder.buildStory(path, name);
          break;
        case 'theme':
          componentBuilder.buildTheme(path, name);
          themeBuilder.addTheme(path, name);
          _exportBuilder.add(filePath);
      }
    }
    themeBuilder.buildThemeModes(inputPath: inputThemePath, outputPath: outputThemePath);
    storybookBuilder.buildAllStoriesList();
  }

  void directoryStructureProcess(List<String> directories) {
    Map<String, List<String>> styles = {};

    // Prepare directory structure
    print("Building directory structure...");
    for (var directory in directories) {
      directory = directory.replaceFirst("$sourcePoint/", '');

      final pathList = directory.split('/');
      final styleName = ReCase(pathList.last);

      final key = [...pathList.sublist(0, pathList.length - 1), ''].join('/');
      styles[key] = [...styles[key] ?? [], styleName.snakeCase];

      Directory('$targetPoint/$directory').createSync(recursive: true);
    }

    // Build directory styles
    print("Building directory styles...");
    for (final style in styles.entries) {
      final styleKeyList = style.key.split('/');
      final styleName = ReCase(styleKeyList[styleKeyList.length - 2]);
      final styleCode =
          StyleBuilder(
            packageName: packageName,
            className: styleName.originalText == 'design' ? "DesignTheme" : "${styleName.pascalCase}Style",
            fileName: styleName.snakeCase,
            filePath: style.key,
            styles: style.value,
          ).build();

      final fileType = styleName.originalText == 'design' ? 'theme' : 'style';
      final filePath = "${style.key}${styleName.snakeCase}.$fileType.dart";
      File('$targetPoint/$filePath').writeAsStringSync(styleCode);

      _exportBuilder.addDirectory('package:$packageName/$filePath');
    }
  }

  ({List<String> directories, List<String> files}) getSourcePaths() {
    final result = _getSubdirectoriesAndFiles(inputDesignPath);
    final List<String> directories = [];
    final List<String> filePaths = [];
    for (final r in result) {
      if (r.isDirectory) {
        directories.add(r.path);
      } else {
        filePaths.add(r.path);
      }
    }
    return (directories: directories, files: filePaths);
  }

  /// This function was generated by AI
  List<({String path, bool isDirectory})> _getSubdirectoriesAndFiles(String path) {
    final directory = Directory(path);
    final subdirectories = directory.listSync().whereType<Directory>().toList();
    final files = directory.listSync().whereType<File>().toList();

    List<({String path, bool isDirectory})> result = [];

    for (final subdirectory in subdirectories) {
      result.add((path: subdirectory.path, isDirectory: true));
      result.addAll(_getSubdirectoriesAndFiles(subdirectory.path));
    }

    for (final file in files) {
      result.add((path: file.path, isDirectory: false));
    }

    return result;
  }
}
