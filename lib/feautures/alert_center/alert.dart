import 'package:flutter/material.dart';

@immutable
class Alert {
  const Alert({
    required this.title,
    this.description,
    required this.actions,
  });

  /// Creates [Alert] with default Cancel action.
  factory Alert.dismissible({
    required String title,
    String? description,
    List<AlertAction>? actions,
    String dismissibleTitle = 'Ok',
  }) {
    return Alert(
      title: title,
      description: description,
      actions: [
        ...?actions,
        AlertAction(title: dismissibleTitle, isCancelAction: true),
      ],
    );
  }

  /// Alert title.
  final String title;

  /// Optional alert description.
  final String? description;

  /// Alert actions.
  final List<AlertAction> actions;
}

@immutable
class AlertAction {
  const AlertAction({
    required this.title,
    this.onTap,
    this.isDestructive = false,
    this.isDefault = false,
    this.isCancelAction = false,
  });

  final String title;
  final VoidCallback? onTap;
  final bool isDestructive;
  final bool isDefault;
  final bool isCancelAction;
}
