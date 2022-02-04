import 'package:flutter/material.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/temp_obd_command.dart';

class OilTempCommand extends TempObdCommand {
  OilTempCommand() : super('015C', min: -40, max: 215, prio: 50);

  @override
  Color get color {
    if (max * 0.9 < result) return dangerColor;
    if (max * 0.8 < result) return warningColor;
    return normalColor;
  }

  @override
  String get description => 'Engine oil temperature';

  @override
  String get name => 'Oil Temp';
}
