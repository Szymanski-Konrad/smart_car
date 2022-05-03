import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_car/feautures/alert_center/alert.dart';

class PlatformDialog extends StatelessWidget {
  const PlatformDialog({required this.alert});

  final Alert alert;

  @override
  Widget build(BuildContext context) {
    final actions = alert.actions.map((option) {
      return _PlatformDialogAction(
          text: option.title,
          isDestructiveAction: option.isDestructive,
          isDefaultAction: option.isDefault,
          onPressed: () {
            Navigator.of(context).pop();
            option.onTap?.call();
          });
    }).toList();

    if (Platform.isIOS) {
      return _buildCupertino(actions);
    } else {
      return _buildMaterial(actions);
    }
  }

  Widget _buildCupertino(List<_PlatformDialogAction> actions) {
    final description = alert.description;
    return CupertinoAlertDialog(
      title: Text(alert.title),
      content: description != null ? Text(description) : null,
      actions: actions.map((action) => action.iOSButton).toList(),
    );
  }

  Widget _buildMaterial(List<_PlatformDialogAction> actions) {
    final description = alert.description;
    return AlertDialog(
      title: Text(alert.title),
      content: description != null ? Text(description) : null,
      actions: actions.map((action) => action.androidButton).toList(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
    );
  }

  void show(BuildContext context) {
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (_) => this,
        barrierDismissible: false,
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => this,
        barrierDismissible: false,
      );
    }
  }
}

class _PlatformDialogAction {
  const _PlatformDialogAction({
    required this.text,
    this.onPressed,
    this.isDestructiveAction = false,
    this.isDefaultAction = false,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isDestructiveAction;
  final bool isDefaultAction;

  Widget get iOSButton {
    return CupertinoDialogAction(
      child: Text(text),
      onPressed: onPressed,
      isDestructiveAction: isDestructiveAction,
      isDefaultAction: isDefaultAction,
    );
  }

  Widget get androidButton {
    return TextButton(
      child: Text(text),
      onPressed: onPressed,
    );
  }
}
