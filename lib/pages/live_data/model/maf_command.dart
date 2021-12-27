import 'package:flutter/material.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';

class MafCommand extends VisibleObdCommand {
  MafCommand() : super('01 10', min: 0, max: 100, prio: 0);

  @override
  String get description => 'Current MAF (grams of air per second)';

  @override
  String get name => 'MAF';

  @override
  void performCalculations(List<int> data) {
    previousResult = result;
    result = (256 * data[0] + data[1]) / 100;
    super.performCalculations(data);
  }

  @override
  String get unit => 'g/s';

  @override
  IconData get icon => Icons.air;

  /// get fuelFlow in [l/h]
  /// [fuelDensity] - kilograms of fuel in m3
  /// [airFuelRatio] - current air fuel ratio for fuel type
  double fuelFlow(double load,
      {double fuelDensity = 740, double airFuelRatio = 14.7}) {
    if (result > 0) {
      return 10 * (load / 100 * result * 3600) / (fuelDensity * airFuelRatio);
    }
    return 0;
  }

  /// Calculate fuel consumption per 100 km
  /// [speed] - current speed of vehicle
  double fuel100km(int speed, double load) {
    if (speed > 0) {
      return (fuelFlow(load) / speed) * 100;
    }
    return 0;
  }

  /// Get fuel used between command calls
  double fuelUsed(double load) {
    if (result > 0) {
      return differenceMiliseconds * (fuelFlow(load) / (3600 * 1000));
    }
    return 0;
  }

  @override
  String get formattedResult => result.isFinite
      ? '${result.toStringAsFixed(2)} $unit'
      : super.formattedResult;
}
