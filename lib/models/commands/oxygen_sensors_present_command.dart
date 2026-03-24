import 'package:flutter/material.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';

/// PID 0x13 - Oxygen sensors present (in 2 banks)
/// 1 byte bitmask:
///   bits [7..4]: Bank2 S1..S4 present
///   bits [3..0]: Bank1 S1..S4 present
class OxygenSensorsPresentCommand extends VisibleObdCommand {
  OxygenSensorsPresentCommand() : super('0113', min: 0, max: 255, prio: 1);

  int _bitmask = 0;

  @override
  void performCalculations(List<int> data) {
    if (data.isNotEmpty) {
      _bitmask = data[0];
      result = _bitmask.toDouble();
      super.performCalculations(data);
    }
  }

  @override
  String get formattedResult {
    final b1 = _bitmask & 0x0F;
    final b2 = (_bitmask >> 4) & 0x0F;
    final b1Sensors = List.generate(4, (i) => (b1 >> i) & 1 == 1 ? 'S${i + 1}' : null)
        .whereType<String>()
        .join(', ');
    final b2Sensors = List.generate(4, (i) => (b2 >> i) & 1 == 1 ? 'S${i + 1}' : null)
        .whereType<String>()
        .join(', ');
    return 'B1:${b1Sensors.isEmpty ? '-' : b1Sensors} B2:${b2Sensors.isEmpty ? '-' : b2Sensors}';
  }

  @override
  String get description => 'Oxygen sensors present (2 banks)';

  @override
  String get name => 'O2 Sensors';

  @override
  String get unit => '';

  @override
  IconData get icon => Icons.sensors;
}
