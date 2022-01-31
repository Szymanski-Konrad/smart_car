import 'package:flutter/material.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';

class TimingAdvanceCommand extends VisibleObdCommand {
  TimingAdvanceCommand() : super('01 0E', min: -64, max: 63.5, prio: 1);

  @override
  void performCalculations(List<int> data) {
    if (data.isNotEmpty) {
      result = data[0] / 2 - 64;
      super.performCalculations(data);
    }
  }

  @override
  Color get color {
    if (max * 0.9 < result) return dangerColor;
    if (max * 0.8 < result) return warningColor;
    return normalColor;
  }

  @override
  String get formattedResult => '$result $unit';

  @override
  String get description => 'Timing advance';

  @override
  IconData get icon => Icons.timelapse;

  @override
  String get name => 'Timing adv.';

  @override
  String get unit => '°';
}
