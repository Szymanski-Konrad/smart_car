import 'package:flutter/material.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';

/// PID 0x68 - Intake air temperature sensor (extended, multi-sensor)
/// 5 bytes:
///   A = sensor bit mask (bits 0-3: sensors 1-4 present)
///   B = sensor 1 temperature: B - 40 °C
///   C = sensor 2 temperature: C - 40 °C
///   D = sensor 3 temperature: D - 40 °C
///   E = sensor 4 temperature: E - 40 °C
/// Primary result = first available sensor temperature.
/// Used as fallback when PID 0x0F is not supported by the vehicle.
class IntakeAirTempExtendedCommand extends VisibleObdCommand {
  IntakeAirTempExtendedCommand() : super('0168', min: -40, max: 215, prio: 0);

  final List<double> sensors = [double.nan, double.nan, double.nan, double.nan];
  int _presentMask = 0;

  @override
  void performCalculations(List<int> data) {
    if (data.length >= 5) {
      _presentMask = data[0];
      for (int i = 0; i < 4; i++) {
        sensors[i] = data[i + 1] - 40.0;
      }
      // Use the first present sensor as the primary result
      for (int i = 0; i < 4; i++) {
        if ((_presentMask >> i) & 1 == 1) {
          result = sensors[i];
          break;
        }
      }
      super.performCalculations(data);
    }
  }

  @override
  String get formattedResult {
    final parts = <String>[];
    for (int i = 0; i < 4; i++) {
      if ((_presentMask >> i) & 1 == 1) {
        parts.add('S${i + 1}:${sensors[i].toInt()}°C');
      }
    }
    return parts.isEmpty ? super.formattedResult : parts.join(' ');
  }

  @override
  String get description => 'Intake air temperature (extended, multi-sensor)';

  @override
  String get name => 'IAT Ext';

  @override
  String get unit => '°C';

  @override
  IconData get icon => Icons.thermostat;
}
