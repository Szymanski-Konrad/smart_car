import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/icon_data.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';

class EngineFuelRateCommand extends VisibleObdCommand {
  EngineFuelRateCommand() : super('01 5E', prio: 1);

  @override
  void performCalculations(List<int> data) {
    if (data.length >= 2) {
      result = (256 * data[0] + data[1]) / 20;
      super.performCalculations(data);
    }
  }

  @override
  String get formattedResult => '${result.toStringAsFixed(1)} $unit';

  @override
  String get description => 'Engine fuel rate';

  @override
  IconData get icon => Icons.local_gas_station;

  @override
  String get name => 'Fuel rate';

  @override
  String get unit => 'L/h';
}
