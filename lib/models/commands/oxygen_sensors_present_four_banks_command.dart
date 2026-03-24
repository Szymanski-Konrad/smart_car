import 'package:flutter/material.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';

/// PID 0x1D - Oxygen sensors present (in 4 banks)
/// 1 byte bitmask:
///   bit7=B1S1, bit6=B1S2, bit5=B2S1, bit4=B2S2,
///   bit3=B3S1, bit2=B3S2, bit1=B4S1, bit0=B4S2
class OxygenSensorsPresentFourBanksCommand extends VisibleObdCommand {
  OxygenSensorsPresentFourBanksCommand()
    : super('011D', min: 0, max: 255, prio: 1);

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
    final sensors = <String>[];
    final layout = [
      (7, 'B1S1'),
      (6, 'B1S2'),
      (5, 'B2S1'),
      (4, 'B2S2'),
      (3, 'B3S1'),
      (2, 'B3S2'),
      (1, 'B4S1'),
      (0, 'B4S2'),
    ];
    for (final (bit, label) in layout) {
      if ((_bitmask >> bit) & 1 == 1) sensors.add(label);
    }
    return sensors.isEmpty ? 'none' : sensors.join(' ');
  }

  @override
  String get description => 'Oxygen sensors present (4 banks)';

  @override
  String get name => 'O2 Sensors 4B';

  @override
  String get unit => '';

  @override
  IconData get icon => Icons.sensors;
}
