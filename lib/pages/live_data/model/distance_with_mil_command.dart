import 'package:flutter/material.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';

class DistanceWithMILCommand extends VisibleObdCommand {
  DistanceWithMILCommand() : super('0121', min: 0, max: 65535, prio: 50);

  @override
  Color get color {
    if (result > 0) return warningColor;
    if (result > 100) return dangerColor;
    return normalColor;
  }

  @override
  void performCalculations(List<int> data) {
    if (data.length >= 2) {
      result = 256 * data[0] + data[1];
      super.performCalculations(data);
    }
  }

  @override
  String get formattedResult => '$result $unit';

  @override
  String get description =>
      'Distance traveled with malfunction indicator lam (MIL) on';

  @override
  IconData get icon => Icons.add_road_outlined;

  @override
  String get name => 'MIL';

  @override
  String get unit => 'km';
}
