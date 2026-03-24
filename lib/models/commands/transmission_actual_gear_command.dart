import 'package:flutter/material.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';

/// PID 0xA4 - Transmission Actual Gear
/// Formula: ((256 * A) + B) / 1000 for gear ratio
/// C is the actual gear number
/// D is requested gear number
class TransmissionActualGearCommand extends VisibleObdCommand {
  TransmissionActualGearCommand() : super('01A4', min: 0, max: 10, prio: 1);

  double gearRatio = 0.0;
  int actualGear = 0;
  int requestedGear = 0;

  @override
  void performCalculations(List<int> data) {
    if (data.length >= 4) {
      gearRatio = (256 * data[0] + data[1]) / 1000;
      actualGear = data[2];
      requestedGear = data[3];
      result = actualGear.toDouble();
      super.performCalculations(data);
    }
  }

  @override
  Color get color {
    if (actualGear == 0) return Colors.grey;
    if (actualGear != requestedGear) return warningColor;
    return normalColor;
  }

  @override
  String get formattedResult {
    if (actualGear == 0) return 'N';
    if (actualGear == 255) return 'P';
    return '$actualGear (${gearRatio.toStringAsFixed(2)})';
  }

  @override
  String get description => 'Transmission actual gear and ratio';

  @override
  IconData get icon => Icons.settings;

  @override
  String get name => 'Gear';

  @override
  String get unit => '';

  /// Returns gear as string (N, P, R, or number)
  String get gearDisplay {
    switch (actualGear) {
      case 0:
        return 'N';
      case 255:
        return 'P';
      case 126:
        return 'R';
      default:
        return actualGear.toString();
    }
  }
}
