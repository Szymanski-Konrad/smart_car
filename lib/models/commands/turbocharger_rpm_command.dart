import 'package:flutter/material.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';

/// PID 0x74 - Turbocharger RPM
/// Formula: ((256 * A) + B) for turbo A, ((256 * C) + D) for turbo B
/// Unit is typically scaled by manufacturer
/// Min: 0, Max: 65535
class TurbochargerRpmCommand extends VisibleObdCommand {
  TurbochargerRpmCommand() : super('0174', min: 0, max: 400000, prio: 2);

  int turboARpm = 0;
  int turboBRpm = 0;

  @override
  void performCalculations(List<int> data) {
    if (data.length >= 2) {
      // Turbo A RPM (primary)
      turboARpm = 256 * data[0] + data[1];
      result = turboARpm.toDouble();

      if (data.length >= 4) {
        // Turbo B RPM (if present)
        turboBRpm = 256 * data[2] + data[3];
      }
      super.performCalculations(data);
    }
  }

  @override
  Color get color {
    if (result > 200000) return dangerColor;
    if (result > 150000) return warningColor;
    return normalColor;
  }

  @override
  String get formattedResult {
    if (turboBRpm > 0) {
      return 'A: ${(turboARpm / 1000).toStringAsFixed(0)}k, B: ${(turboBRpm / 1000).toStringAsFixed(0)}k';
    }
    return '${(turboARpm / 1000).toStringAsFixed(1)}k $unit';
  }

  @override
  String get description => 'Turbocharger RPM';

  @override
  IconData get icon => Icons.cyclone;

  @override
  String get name => 'Turbo RPM';

  @override
  String get unit => 'RPM';
}
