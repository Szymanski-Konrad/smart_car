import 'package:flutter/material.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';

class RunTimeSinceStartCommand extends VisibleObdCommand {
  RunTimeSinceStartCommand() : super('011F', min: 0, max: 65535, prio: 5);

  @override
  String get description => 'Run time since start';

  @override
  void performCalculations(List<int> data) {
    if (data.length >= 2) {
      result = 256 * data[0] + data[1];
      super.performCalculations(data);
    }
  }

  @override
  Color get color {
    return normalColor;
  }

  @override
  String get formattedResult => '$result $unit';

  @override
  IconData get icon => Icons.timelapse;

  @override
  String get name => 'Run time';

  @override
  String get unit => 's';
}
