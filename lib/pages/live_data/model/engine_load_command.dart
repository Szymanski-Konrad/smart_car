import 'package:flutter/material.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/percent_obd_command.dart';

class EngineLoadCommand extends PercentObdCommand {
  EngineLoadCommand() : super('01 04', prio: 0);

  @override
  String get description => 'How much load is on engine';

  @override
  String get name => 'Engine load';

  @override
  IconData get icon => Icons.toys;
}
