import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';

class BackButtonHandler extends StatefulWidget {
  const BackButtonHandler({super.key, this.quitDialog, required this.child});

  final Future<bool?> Function(BuildContext)? quitDialog;

  final Widget child;

  @override
  State<BackButtonHandler> createState() => _BackButtonHandlerState();
}

class _BackButtonHandlerState extends State<BackButtonHandler> {
  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(interceptor);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(interceptor);
    super.dispose();
  }

  Future<bool> interceptor(bool stopDefaultButtonEvent, RouteInfo info) async {
    final navigator = Navigator.of(context);

    if (navigator.canPop()) {
      navigator.pop();
      return true;
    } else {
      final exitApp = await widget.quitDialog?.call(context);
      return exitApp != true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
