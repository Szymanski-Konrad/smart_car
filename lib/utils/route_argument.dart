import 'package:flutter/material.dart';

mixin RouteArgument<T> on Widget {
  T getArgument(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments == null || arguments is! T) {
      throw TypeError();
    }
    return arguments as T;
  }

  T? tryGetArguments(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments == null || arguments is! T) {
      return null;
    }
    return arguments as T;
  }
}
