import 'package:flutter/material.dart';
import '{{name.snakeCase()}}.style.dart';

class {{name.pascalCase()}} extends StatelessWidget {
  const {{name.pascalCase()}}({
    super.key,
    required this.text,
    this.onTap,
    this.style,
  });

  final String text;
  final GestureTapCallback? onTap;
  final {{name.pascalCase()}}Style? style;

  @override
  Widget build(BuildContext context) {
    final currentStyle = style!;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 200,
        height: 42,
        child: Text(text),
      ),
    );
  }
}
