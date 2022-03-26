import 'package:flutter/material.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';

class MafCommand extends VisibleObdCommand {
  MafCommand() : super('0110', min: 0, max: 100, prio: 0, enableHistory: true);

  @override
  Color get color {
    if (max * 0.9 < result) return dangerColor;
    if (max * 0.8 < result) return warningColor;
    return normalColor;
  }

  @override
  String get description => 'Current MAF (grams of air per second)';

  @override
  String get name => 'MAF';

  @override
  void performCalculations(List<int> data) {
    if (data.length >= 2) {
      result = 2 * (256 * data[0] + data[1]) / 100;
      super.performCalculations(data);
    }
  }

  @override
  String get unit => 'g/s';

  @override
  IconData get icon => Icons.air;

  /// get fuelFlow in [l/h]
  /// [fuelDensity] - kilograms of fuel in m3
  /// [airFuelRatio] - current air fuel ratio for fuel type
  void calculateFuelFlow({
    double fuelDensity = 740,
    double airFuelRatio = 14.7,
    double trimTerm = 1.0,
  }) {
    if (result > 0) {
      _fuelFlow = (result * trimTerm * 3600) / airFuelRatio / fuelDensity;
    } else {
      _fuelFlow = 0;
    }
  }

  double _fuelFlow = 0;

  /// Calculate fuel consumption per 100 km
  /// [speed] - current speed of vehicle
  double fuel100km(
    int speed,
    double longTerm,
    double shortTerm,
    double airFuelRatio,
  ) {
    final trimTerm = 1 + longTerm + shortTerm;
    calculateFuelFlow(airFuelRatio: airFuelRatio, trimTerm: trimTerm);
    if (speed > 0) {
      return (_fuelFlow / speed) * 100;
    }
    return _fuelFlow;
  }

  /// Get fuel used between command calls
  double fuelUsed() {
    if (_fuelFlow > 0) {
      return differenceMiliseconds * _fuelFlow / 3600000;
    }
    return 0;
  }

  @override
  String get formattedResult => result.isFinite
      ? '${result.toStringAsFixed(2)} $unit'
      : super.formattedResult;
}
