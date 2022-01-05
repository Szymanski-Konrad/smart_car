import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/icon_data.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';

class TimingAdvanceCommand extends VisibleObdCommand {
  TimingAdvanceCommand() : super('01 0E', prio: 1);

  @override
  void performCalculations(List<int> data) {
    if (data.isNotEmpty) {
      result = data[0] / 2 - 64;
      super.performCalculations(data);
    }
  }

  @override
  String get description => 'Timing advance';

  @override
  IconData get icon => Icons.timelapse;

  @override
  String get name => 'Timing advance';

  @override
  String get unit => '°';
}
