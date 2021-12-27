import 'package:flutter/material.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/percent_obd_command.dart';

class ThrottlePositionCommand extends PercentObdCommand {
  ThrottlePositionCommand() : super('01 11', prio: 1);

  @override
  String get description => 'Throttle position';

  @override
  IconData get icon => Icons.align_vertical_center_outlined;

  @override
  String get name => 'Throttle';
}
