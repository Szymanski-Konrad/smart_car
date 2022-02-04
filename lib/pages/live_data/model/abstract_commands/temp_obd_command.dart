import 'package:flutter/material.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';

abstract class TempObdCommand extends VisibleObdCommand {
  TempObdCommand(
    String command, {
    required int prio,
    double min = -40,
    double max = 215,
    bool enableHistory = false,
  }) : super(command,
            min: min, max: max, prio: prio, enableHistory: enableHistory);

  @override
  IconData get icon => Icons.thermostat;

  @override
  String get formattedResult =>
      result.isFinite ? '${result.toInt()} °C' : super.formattedResult;

  @override
  String get unit => '°C';

  @override
  void performCalculations(List<int> data) {
    if (data.isNotEmpty) {
      result = data[0] - 40;
      super.performCalculations(data);
    }
  }
}
