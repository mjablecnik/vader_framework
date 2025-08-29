import 'package:flutter/material.dart';
import 'package:theme_tailor_annotation/theme_tailor_annotation.dart';

@tailorMixinComponent
class {{name.pascalCase()}}Style {
  const {{name.pascalCase()}}Style({
    required this.color,
  });

  @override
  final Color color;
}
