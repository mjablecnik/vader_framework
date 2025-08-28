import 'package:auto_injector/auto_injector.dart';
import 'package:mocktail/mocktail.dart';

class MockInjector extends Mock implements Injector {}

class Injector {
  Injector();

  final AutoInjector _injector = AutoInjector();

  bool isCommited = false;

  void addInjector(Injector injector) => _injector.addInjector(injector._injector);

  T use<T>({String? key}) {
    return _injector.get<T>(key: key);
  }

  T? tryUse<T>({String? key}) {
    return _injector.tryGet<T>(key: key);
  }

  addInstance<T>(T instance, {String? key}) {
    _injector.addInstance(instance, key: key);
  }

  waitFor<T>(Function() cmd) {
    if (_injector.tryGet<T>() == null) {
      Future.delayed(Duration(milliseconds: 100), () => waitFor<T>(cmd));
    } else {
      _injector.uncommit();
      cmd.call();
      _injector.commit();
    }
  }

  addLazyInstance<T>(Future<T> instance, {String? key}) {
    instance.then((e) {
      if (isCommited) {
        _injector.uncommit();
        _injector.addInstance(e, key: key);
        _injector.commit();
      } else {
        _injector.addInstance(e, key: key);
      }
    });
  }

  addSingleton<T>(Function constructor, {String? key}) {
    _injector.addSingleton(constructor, key: key);
  }

  add<T>(Function constructor, {String? key}) {
    _injector.addSingleton(constructor, key: key);
  }

  reset() {
    _injector.disposeRecursive();
  }

  commit() {
    if (!isCommited) {
      _injector.commit();
      isCommited = true;
    }
  }

  uncommit() {
    if (isCommited) {
      _injector.uncommit();
      isCommited = false;
    }
  }
}
