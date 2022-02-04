import 'package:flutter/material.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/temp_obd_command.dart';

class IntakeAirTempCommand extends TempObdCommand {
  IntakeAirTempCommand() : super('010F', min: -40, max: 70, prio: 150);

  @override
  Color get color {
    if (result < 10) return Colors.blue;
    if (result < 25) return Colors.green;
    return Colors.red;
  }

  @override
  String get description => 'Show temperature of intake air';

  @override
  String get name => 'Air temp';
}
