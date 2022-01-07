import 'package:flutter/material.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';

class RpmCommand extends VisibleObdCommand {
  RpmCommand() : super('01 0C', min: 0, max: 7000, prio: 0);

  @override
  String get description => 'Engine rotation speed';

  @override
  String get name => 'RPM';

  @override
  void performCalculations(List<int> data) {
    if (data.length >= 2) {
      result = (256 * data[0] + data[1]) / 4;
      super.performCalculations(data);
    }
  }

  @override
  String get unit => 'rpm';

  @override
  IconData get icon => Icons.speed;

  @override
  String get formattedResult =>
      result.isFinite ? '${result.toInt()}' : super.formattedResult;
}
