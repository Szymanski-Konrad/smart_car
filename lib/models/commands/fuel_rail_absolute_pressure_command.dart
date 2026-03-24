import 'package:flutter/material.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';

/// PID 0x59 - Fuel rail absolute pressure
/// Formula: ((256 * A) + B) * 10
/// Min: 0, Max: 655350 kPa
class FuelRailAbsolutePressureCommand extends VisibleObdCommand {
  FuelRailAbsolutePressureCommand()
    : super('0159', min: 0, max: 655350, prio: 3);

  @override
  void performCalculations(List<int> data) {
    if (data.length >= 2) {
      result = (256 * data[0] + data[1]) * 10;
      super.performCalculations(data);
    }
  }

  @override
  Color get color {
    if (result > max * 0.9) return dangerColor;
    if (result > max * 0.7) return warningColor;
    return normalColor;
  }

  @override
  String get formattedResult => '${(result / 1000).toStringAsFixed(1)} $unit';

  @override
  String get description => 'Fuel rail absolute pressure';

  @override
  IconData get icon => Icons.compress;

  @override
  String get name => 'Fuel Rail Pressure';

  @override
  String get unit => 'MPa';
}
