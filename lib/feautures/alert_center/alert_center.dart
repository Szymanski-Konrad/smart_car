import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:smart_car/feautures/alert_center/alert.dart';

abstract class AlertCenter {
  AlertCenter._();

  static GlobalKey? _globalKey;

  static void initialize({required GlobalKey globalKey}) {
    _globalKey = globalKey;
  }

  static void show(Alert alert) {
    final context = _currentContext;

    // Non-cancel actions (e.g. "Dodaj" in refuel alert) shown as a button
    final mainActions = alert.actions.where((a) => !a.isCancelAction).toList();

    Widget? mainButton;
    if (mainActions.isNotEmpty) {
      final action = mainActions.first;
      mainButton = TextButton(
        onPressed: action.onTap,
        style: TextButton.styleFrom(foregroundColor: Colors.white),
        child: Text(
          action.title.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    }

    final description = alert.description;

    Flushbar(
      title: alert.title,
      message: description,
      flushbarPosition: FlushbarPosition.TOP,
      duration: const Duration(seconds: 6),
      animationDuration: const Duration(milliseconds: 400),
      icon: const Icon(
        Icons.warning_amber_rounded,
        color: Colors.orange,
        size: 28,
      ),
      backgroundColor: const Color(0xFF1E1E2E),
      borderRadius: BorderRadius.circular(12),
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      titleColor: Colors.white,
      messageColor: Colors.white70,
      mainButton: mainButton,
      isDismissible: true,
      dismissDirection: FlushbarDismissDirection.HORIZONTAL,
    ).show(context);
  }

  static BuildContext get _currentContext {
    final currentContext = _globalKey?.currentContext;
    if (currentContext == null) {
      throw ArgumentError.notNull('Current context is nullable');
    }
    return currentContext;
  }
}
