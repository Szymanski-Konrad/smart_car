import 'package:flutter/material.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/temp_obd_command.dart';

class EngineCoolantCommand extends TempObdCommand {
  EngineCoolantCommand() : super('01 05', min: -40, max: 120, prio: 20);

  @override
  Color get color {
    if (result < 50) return dangerColor;
    if (result < 70) return warningColor;
    if (result >= 70 && result <= 100) return normalColor;
    if (result > 100) return warningColor;
    if (result > 110) return dangerColor;
    return normalColor;
  }

  @override
  void performCalculations(List<int> data) {
    super.performCalculations(data);
    if (result > 80) {
      priority = 80;
    } else {
      priority = 20;
    }
  }

  @override
  String get description => 'Coolant temperature of engine';

  @override
  String get name => 'Engine temp';
}
