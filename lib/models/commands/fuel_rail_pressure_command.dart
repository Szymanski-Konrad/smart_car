import 'package:flutter/material.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';

class FuelRailPressureCommand extends VisibleObdCommand {
  FuelRailPressureCommand() : super('01 22', prio: 1, min: 0, max: 5000);

  @override
  void performCalculations(List<int> data) {
    if (data.length >= 2) {
      result = 0.079 * (256 * data[0] + data[1]);
      super.performCalculations(data);
    }
  }

  @override
  String get description => 'Fuel rail pressure';

  @override
  IconData get icon => Icons.scatter_plot_sharp;

  @override
  String get name => 'Rail Press.';

  @override
  String get unit => 'kPa';
}
