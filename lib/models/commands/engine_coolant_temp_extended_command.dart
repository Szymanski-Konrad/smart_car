import 'package:flutter/material.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';

/// PID 0x67 - Engine coolant temperature (extended, multi-sensor)
/// 3 bytes:
///   A = sensor bit mask (bit0 = sensor 1 present, bit1 = sensor 2 present)
///   B = sensor 1 temperature: B - 40 °C
///   C = sensor 2 temperature: C - 40 °C
/// Primary result = sensor 1 temperature.
/// Used as fallback when PID 0x05 is not supported by the vehicle.
class EngineCoolantTempExtendedCommand extends VisibleObdCommand {
  EngineCoolantTempExtendedCommand()
      : super('0167', min: -40, max: 215, prio: 0);

  double sensor1 = double.nan;
  double sensor2 = double.nan;
  bool hasSensor1 = false;
  bool hasSensor2 = false;

  @override
  void performCalculations(List<int> data) {
    if (data.length >= 3) {
      hasSensor1 = (data[0] & 0x01) == 1;
      hasSensor2 = (data[0] & 0x02) == 2;
      sensor1 = data[1] - 40.0;
      sensor2 = data[2] - 40.0;
      result = hasSensor1 ? sensor1 : sensor2;
      super.performCalculations(data);
    }
  }

  @override
  String get formattedResult {
    if (hasSensor1) return '${sensor1.toInt()} $unit${hasSensor2 ? ' (S2:${sensor2.toInt()}°C)' : ''}';
    if (hasSensor2) return '${sensor2.toInt()} $unit';
    return super.formattedResult;
  }

  @override
  String get description => 'Engine coolant temperature (extended)';

  @override
  String get name => 'Coolant Ext';

  @override
  String get unit => '°C';

  @override
  IconData get icon => Icons.thermostat;
}
