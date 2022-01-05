import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/icon_data.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/percent_obd_command.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';

class CommandedEvaporativePurgeCommand extends PercentObdCommand {
  CommandedEvaporativePurgeCommand() : super('01 2E', prio: 2);

  @override
  String get description => 'Commanded evaporative purge';

  @override
  IconData get icon => Icons.elevator_sharp;

  @override
  String get name => 'Purge';
}
