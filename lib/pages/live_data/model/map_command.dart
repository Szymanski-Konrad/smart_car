import 'package:flutter/material.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';

class MapCommand extends VisibleObdCommand {
  MapCommand() : super('01 0B', min: 0, max: 255, prio: 0);

  @override
  String get description => 'Current MAP (Manifold Absolute pressure)';

  @override
  String get name => 'MAP';

  @override
  void performCalculations(List<int> data) {
    if (data.isNotEmpty) {
      previousResult = result;
      result = data[0];
      super.performCalculations(data);
    }
  }

  @override
  String get unit => 'kPa';

  @override
  IconData get icon => Icons.air;

  double gramsOfAir() {
    return 0.0;
  }

  /// get fuelFlow in [l/h]
  /// [fuelDensity] - kilograms of fuel in m3
  /// [airFuelRatio] - current air fuel ratio for fuel type
  double fuelFlow(double load,
      {double fuelDensity = 740, double airFuelRatio = 14.7}) {
    if (result > 0) {
      // return 10 * (load / 100 * result * 3600) / (fuelDensity * airFuelRatio);
      return (result * 3600) / (fuelDensity * airFuelRatio);
    }
    return 0;
  }

  /// Calculate fuel consumption per 100 km
  /// [speed] - current speed of vehicle
  double fuel100km(int speed, double load, double longTerm, double shortTerm) {
    if (speed > 0) {
      return (fuelFlow(load) * longTerm * shortTerm / speed) * 100;
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
      ? '${result.toStringAsFixed(0)} $unit'
      : super.formattedResult;
}
