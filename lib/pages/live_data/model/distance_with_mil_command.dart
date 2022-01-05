import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/icon_data.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';

class DistanceWithMILCommand extends VisibleObdCommand {
  DistanceWithMILCommand() : super('01 21', prio: 50);

  @override
  void performCalculations(List<int> data) {
    if (data.length >= 2) {
      result = 256 * data[0] + data[1];
      super.performCalculations(data);
    }
  }

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
