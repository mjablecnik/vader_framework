import 'package:flutter/material.dart';
import '../../../{{package.snakeCase()}}_exports.dart';
import 'package:storybook_toolkit/storybook_toolkit.dart';


//region Knobs
String textKnob(BuildContext context) => context.knobs.text(label: 'Button text', initial: 'Default text');

bool iconKnob(BuildContext context) => context.knobs.boolean(label: 'Show icon', initial: false);

String textKnobOptions(BuildContext context) => context.knobs.options(
      label: 'Button text',
      initial: 'Default text',
      options: [
        const Option(label: "Short text", value: "Short text"),
        const Option(label: "Long text", value: "Vítejte zde na našich stránkách."),
      ],
    );

onTap() => debugPrint("Test click.");
//endregion


{{name.camelCase()}}Story(BuildContext context) {
  return {{name.pascalCase()}}(
    text: textKnobOptions(context),
    onTap: onTap,
  );
}

{{name.camelCase()}}Story(BuildContext context) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    spacing: 30,
    children: [
      {{name.pascalCase()}}(
        text: textKnobOptions(context),
        onTap: onTap,
      ),
    ],
  );
}
