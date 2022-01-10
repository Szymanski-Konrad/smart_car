import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/icon_data.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';

class FuelPressureCommand extends VisibleObdCommand {
  FuelPressureCommand() : super('01 0A', max: 765, prio: 1);

  @override
  void performCalculations(List<int> data) {
    if (data.isNotEmpty) {
      result = 3 * data[0];
      super.performCalculations(data);
    }
  }

  @override
  String get formattedResult => '$result $unit';

  @override
  String get description => 'Fuel pressure';

  @override
  IconData get icon => Icons.air;

  @override
  String get name => 'Fuel pressure';

  @override
  String get unit => 'kPa';
}
