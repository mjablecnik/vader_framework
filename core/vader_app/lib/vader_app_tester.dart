import 'package:vader_app/vader_app.dart';

class VaderAppTester {
  const VaderAppTester({required this.modules});

  final List<VaderModule> modules;

  Future<VaderAppTester> init({Duration? waitTime}) async {
    setupModules();
    await Future.delayed(waitTime ?? Duration(milliseconds: 1000));
    return this;
  }

  void setupModules() {
    for (var module in modules) {
      final moduleServices = module.getServices();
      if (moduleServices != null) {
        injector.addInjector(moduleServices);
      }
    }
    injector.commit();
  }
}
