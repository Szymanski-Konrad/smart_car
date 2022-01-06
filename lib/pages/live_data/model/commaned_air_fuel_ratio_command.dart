import 'package:flutter/material.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';

class CommandedAirFuelRatioCommand extends VisibleObdCommand {
  CommandedAirFuelRatioCommand() : super('01 44', prio: 0);

  @override
  String get description => 'Commanded Air Fuel Ratio command';

  @override
  String get formattedResult => '$result $unit';

  @override
  void performCalculations(List<int> data) {
    if (data.length >= 2) {
      result = (2 / 65536) * (256 * data[0] + data[1]);
      print(result);
      super.performCalculations(data);
    }
  }

  @override
  IconData get icon => Icons.rate_review;

  @override
  String get name => 'Air-Fuel ratio';

  @override
  String get unit => '';
}
