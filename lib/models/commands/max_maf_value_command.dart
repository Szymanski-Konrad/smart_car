import 'package:flutter/material.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';

/// PID 0x50 - Maximum value for air flow rate from MAF sensor
/// 4 bytes: A = max MAF (g/s), B-D are 0x00 padding
/// Formula: result = A * 10 g/s (range 0–2550 g/s)
class MaxMafValueCommand extends VisibleObdCommand {
  MaxMafValueCommand() : super('0150', min: 0, max: 2550, prio: 1);

  @override
  void performCalculations(List<int> data) {
    if (data.isNotEmpty) {
      result = data[0] * 10.0;
      super.performCalculations(data);
    }
  }

  @override
  String get formattedResult =>
      result.isFinite ? '${result.toStringAsFixed(0)} $unit' : super.formattedResult;

  @override
  String get description => 'Maximum air flow rate from MAF sensor';

  @override
  String get name => 'Max MAF';

  @override
  String get unit => 'g/s';

  @override
  IconData get icon => Icons.air;
}
