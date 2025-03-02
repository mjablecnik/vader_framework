import 'package:vader_app/vader_app.dart';

abstract class VaderModule {
  abstract final String name;
  abstract final List<GoRoute> routes;
  abstract final Injector? services;

  get injector {
    final injector = Injector();

    if (services != null) injector.addInjector(services!..commit());

    return injector;
  }
}
