import 'package:flutter/material.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';

/// PID 0x65 - Auxiliary input / output supported
/// 5 bytes bitmask (A = general support byte, B-E = individual I/O bits)
/// Displayed as raw hex for diagnostic purposes.
class AuxiliaryIOSupportedCommand extends VisibleObdCommand {
  AuxiliaryIOSupportedCommand() : super('0165', min: 0, max: 255, prio: 1);

  String _hexDisplay = '--';

  @override
  void performCalculations(List<int> data) {
    if (data.length >= 5) {
      _hexDisplay = data.take(5).map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase()).join(' ');
      result = data[0].toDouble();
      super.performCalculations(data);
    }
  }

  @override
  String get formattedResult => _hexDisplay;

  @override
  String get description => 'Auxiliary input/output supported bitmask';

  @override
  String get name => 'Aux I/O';

  @override
  String get unit => '';

  @override
  IconData get icon => Icons.device_hub;
}
