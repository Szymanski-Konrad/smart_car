import 'package:flutter/material.dart';
import 'package:smart_car/feautures/alert_center/alert.dart';
import 'package:smart_car/feautures/alert_center/platform_dialog.dart';

abstract class AlertCenter {
  AlertCenter._();

  static GlobalKey? _globalKey;

  static void initialize({required GlobalKey globalKey}) {
    _globalKey = globalKey;
  }

  static void show(Alert alert) {
    final context = _currentContext;
    final dialog = PlatformDialog(alert: alert);
    dialog.show(context);
  }

  static BuildContext get _currentContext {
    final currentContext = _globalKey?.currentContext;
    if (currentContext == null) {
      throw ArgumentError.notNull('Current context is nullable');
    }
    return currentContext;
  }
}
