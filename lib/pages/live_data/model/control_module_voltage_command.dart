import 'package:flutter/material.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';

class ControlModuleVoltageCommand extends VisibleObdCommand {
  ControlModuleVoltageCommand()
      : super('0142', min: 0, max: 20, prio: 5, enableHistory: false);

  @override
  Color get color {
    if (max * 0.7 > result) return warningColor;
    if (max * 0.68 > result) return dangerColor;
    return normalColor;
  }

  @override
  String get formattedResult => '${result.toStringAsFixed(2)} $unit';

  @override
  void performCalculations(List<int> data) {
    if (data.length >= 2) {
      result = (256 * data[0] + data[1]) / 1000;
      super.performCalculations(data);
    }
  }

  @override
  String get description => 'Control module voltage';

  @override
  IconData get icon => Icons.electrical_services;

  @override
  String get name => 'Voltage';

  @override
  String get unit => 'V';
}
