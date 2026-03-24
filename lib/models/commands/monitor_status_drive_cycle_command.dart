import 'package:flutter/material.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';

/// PID 0x41 - Monitor status this drive cycle
/// 4 bytes, same structure as PID 0x01.
/// Byte A: bit5 = MIL on/off, bits4..0 = number of DTCs in this drive cycle
/// Bytes B-D: individual monitor ready/not-ready flags
class MonitorStatusDriveCycleCommand extends VisibleObdCommand {
  MonitorStatusDriveCycleCommand() : super('0141', min: 0, max: 127, prio: 1);

  bool milOn = false;
  int dtcCount = 0;

  @override
  void performCalculations(List<int> data) {
    if (data.length >= 4) {
      milOn = (data[0] >> 5) & 1 == 1;
      dtcCount = data[0] & 0x1F;
      result = dtcCount.toDouble();
      super.performCalculations(data);
    }
  }

  @override
  String get formattedResult =>
      'MIL:${milOn ? 'ON' : 'off'} ${dtcCount}DTC';

  @override
  Color get color {
    if (milOn) return dangerColor;
    if (dtcCount > 0) return warningColor;
    return normalColor;
  }

  @override
  String get description => 'Monitor status this drive cycle';

  @override
  String get name => 'Monitor';

  @override
  String get unit => 'DTC';

  @override
  IconData get icon => Icons.warning_amber;
}
