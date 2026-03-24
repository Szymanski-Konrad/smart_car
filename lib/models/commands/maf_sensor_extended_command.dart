import 'package:flutter/material.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';

/// PID 0x66 - Mass air flow sensor (extended, multi-sensor)
/// 5 bytes:
///   A = sensor type bits (bit0 = sensor A present, bit1 = sensor B present)
///   B-C = sensor A reading: (256*B + C) / 32 g/s
///   D-E = sensor B reading: (256*D + E) / 32 g/s
/// Primary result = sensor A value (or sensor B if A unavailable)
class MafSensorExtendedCommand extends VisibleObdCommand {
  MafSensorExtendedCommand() : super('0166', min: 0, max: 655, prio: 1);

  double sensorA = 0;
  double sensorB = 0;
  bool hasSensorA = false;
  bool hasSensorB = false;

  @override
  void performCalculations(List<int> data) {
    if (data.length >= 5) {
      hasSensorA = (data[0] & 0x01) == 1;
      hasSensorB = (data[0] & 0x02) == 2;
      sensorA = (256 * data[1] + data[2]) / 32.0;
      sensorB = (256 * data[3] + data[4]) / 32.0;
      result = hasSensorA ? sensorA : sensorB;
      super.performCalculations(data);
    }
  }

  @override
  String get formattedResult {
    final parts = <String>[];
    if (hasSensorA) parts.add('A:${sensorA.toStringAsFixed(2)}');
    if (hasSensorB) parts.add('B:${sensorB.toStringAsFixed(2)}');
    return parts.isEmpty ? super.formattedResult : '${parts.join(' ')} $unit';
  }

  @override
  String get description => 'Extended MAF sensor (multi-sensor)';

  @override
  String get name => 'MAF Ext';

  @override
  String get unit => 'g/s';

  @override
  IconData get icon => Icons.air;
}
