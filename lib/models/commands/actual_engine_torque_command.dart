import 'package:flutter/material.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';

/// PID 0x62 - Actual engine - percent torque
/// Formula: A - 125
/// Min: -125, Max: 130
class ActualEngineTorqueCommand extends VisibleObdCommand {
  ActualEngineTorqueCommand() : super('0162', min: -125, max: 130, prio: 2);

  @override
  void performCalculations(List<int> data) {
    if (data.isNotEmpty) {
      result = data[0] - 125;
      super.performCalculations(data);
    }
  }

  @override
  Color get color {
    if (result > 80) return dangerColor;
    if (result > 50) return warningColor;
    if (result < 0) return Colors.blue;
    return normalColor;
  }

  @override
  String get formattedResult => '${result.toStringAsFixed(0)} $unit';

  @override
  String get description => 'Actual engine percent torque';

  @override
  IconData get icon => Icons.rotate_right;

  @override
  String get name => 'Actual Torque';

  @override
  String get unit => '%';
}
