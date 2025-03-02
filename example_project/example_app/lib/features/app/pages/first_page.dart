import 'package:example_design/example_design.dart';
import 'package:flutter/material.dart';
import 'package:vader_app/vader_app.dart';

class FirstPage extends StatelessWidget {
  const FirstPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      title: "First page",
      child: Center(
        child: PrimaryButton(
          text: "Go to next page",
          size: ButtonSize.medium,
          onTap: () {
            context.push('/Second');
          },
        ),
      ),
    );
  }
}
