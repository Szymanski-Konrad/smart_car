import 'package:flutter/material.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/temp_obd_command.dart';

class IntakeAirTempCommand extends TempObdCommand {
  IntakeAirTempCommand() : super('01 0F', min: -40, max: 70, prio: 150);

  @override
  Color get color {
    //TODO: Return color depends on temperature, if is cold - blue, if hot - red itd.
    return normalColor;
  }

  @override
  String get description => 'Show temperature of intake air';

  @override
  String get name => 'Air temp';
}
