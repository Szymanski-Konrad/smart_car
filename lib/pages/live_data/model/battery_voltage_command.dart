import 'package:flutter/material.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';

class BatteryVoltageCommand extends VisibleObdCommand {
  BatteryVoltageCommand()
      : super('ATRV', min: 0, max: 20, prio: 5, enableHistory: true);

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
    if (data.isNotEmpty) {
      result = data[0] / 10;
      super.performCalculations(data);
    }
  }

  @override
  String get description => 'Napięcie akumulatora';

  @override
  IconData get icon => Icons.electrical_services;

  @override
  String get name => 'Napięcie akumulatora';

  @override
  String get unit => 'V';
}
