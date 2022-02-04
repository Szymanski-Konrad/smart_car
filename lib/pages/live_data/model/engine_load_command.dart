import 'package:flutter/material.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/percent_obd_command.dart';

class EngineLoadCommand extends PercentObdCommand {
  EngineLoadCommand() : super('0104', prio: 0);

  @override
  Color get color {
    if (max * 0.8 < result) return dangerColor;
    if (max * 0.6 < result) return warningColor;
    return normalColor;
  }

  @override
  String get description => 'How much load is on engine';

  @override
  String get name => 'Engine load';

  @override
  IconData get icon => Icons.toys;
}
