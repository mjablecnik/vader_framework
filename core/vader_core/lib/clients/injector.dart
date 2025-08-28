import 'package:auto_injector/auto_injector.dart';
import 'package:mocktail/mocktail.dart';

class MockInjector extends Mock implements Injector {}

class Injector {
  Injector();

  final AutoInjector _injector = AutoInjector();

  bool isCommitted = false;

  void addInjector(Injector injector) => _injector.addInjector(injector._injector);

  @Deprecated('Use .get() method instead.')
  T use<T>({String? key}) {
    return _injector.get<T>(key: key);
  }

  @Deprecated('Use .tryGet() method instead.')
  T? tryUse<T>({String? key}) {
    return _injector.tryGet<T>(key: key);
  }

  T get<T>({String? key}) {
    return _injector.get<T>(key: key);
  }

  T? tryGet<T>({String? key}) {
    return _injector.tryGet<T>(key: key);
  }

  void addInstance<T>(T instance, {String? key}) {
    _injector.addInstance<T>(instance, key: key);
  }

  void waitFor<T>(Function() cmd, {Duration duration = const Duration(milliseconds: 100)}) {
    if (_injector.tryGet<T>() == null) {
      Future.delayed(duration, () => waitFor<T>(cmd));
    } else {
      uncommit();
      cmd.call();
      commit();
    }
  }

  void addLazyInstance<T>(Future<T> instance, {String? key}) {
    instance.then((e) {
      if (isCommitted) {
        uncommit();
        _injector.addInstance<T>(e, key: key);
        commit();
      } else {
        _injector.addInstance<T>(e, key: key);
      }
    });
  }

  void addSingleton<T>(Function constructor, {String? key}) {
    _injector.addSingleton<T>(constructor);
  }

  void add<T>(Function constructor, {String? key}) {
    _injector.addSingleton<T>(constructor, key: key);
  }

  void reset() {
    _injector.disposeRecursive();
  }

  void commit() {
    if (!isCommitted) {
      _injector.commit();
      isCommitted = true;
    }
  }

  void uncommit() {
    if (isCommitted) {
      _injector.uncommit();
      isCommitted = false;
    }
  }
}
