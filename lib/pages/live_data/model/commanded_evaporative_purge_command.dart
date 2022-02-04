import 'package:flutter/material.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/percent_obd_command.dart';

class CommandedEvaporativePurgeCommand extends PercentObdCommand {
  CommandedEvaporativePurgeCommand() : super('012E', prio: 2);

  @override
  Color get color {
    if (max * 0.9 < result) return dangerColor;
    if (max * 0.8 < result) return warningColor;
    return normalColor;
  }

  @override
  String get description => 'Commanded evaporative purge';

  @override
  IconData get icon => Icons.elevator_sharp;

  @override
  String get name => 'Purge';
}
