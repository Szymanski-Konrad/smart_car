import 'package:flutter/material.dart';

class Navigation {
  Navigation._(this.key);

  final GlobalKey<NavigatorState> key;

  static late final Navigation _instance =
      Navigation._(GlobalKey<NavigatorState>());

  static Navigation get instance {
    return _instance;
  }

  Future<dynamic> push(String route, {Object? arguments}) {
    return _currentState.pushNamed(route, arguments: arguments);
  }

  Future<dynamic> pushReplacement(String route, {Object? arguments}) {
    return _currentState.pushReplacementNamed(route, arguments: arguments);
  }

  void popUntil() {
    return _currentState.popUntil((route) => route.isFirst);
  }

  Future<dynamic> pushAndRemoveUntil(String route, RoutePredicate predicate,
      {Object? arguments}) {
    return _currentState.pushNamedAndRemoveUntil(
      route,
      predicate,
      arguments: arguments,
    );
  }

  void pop<T extends Object?>([T? result]) {
    _currentState.pop(result);
  }

  NavigatorState get _currentState {
    final currentState = key.currentState;
    if (currentState == null) {
      throw ArgumentError.notNull('Current context is nullable');
    }
    return currentState;
  }
}
