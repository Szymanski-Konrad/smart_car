import 'package:flutter/material.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';

class CommandedAirFuelRatioCommand extends VisibleObdCommand {
  CommandedAirFuelRatioCommand()
      : super('01 44', max: 2, min: 0, prio: 0, enableHistory: false);

  @override
  Color get color {
    if (max * 0.9 < result) return dangerColor;
    if (max * 0.8 < result) return warningColor;
    return normalColor;
  }

  @override
  String get description => 'Commanded Air Fuel Ratio command';

  @override
  String get formattedResult => '${result.toStringAsFixed(3)} $unit';

  @override
  void performCalculations(List<int> data) {
    if (data.length >= 2) {
      result = (2 / 65536) * (256 * data[0] + data[1]);
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
