import 'package:flutter/material.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';

/// PID 0x64 - Engine percent torque data
/// Returns torque at: idle, point 1, point 2, point 3, point 4
/// Each value: A - 125 (range: -125 to 130)
class EnginePercentTorqueDataCommand extends VisibleObdCommand {
  EnginePercentTorqueDataCommand()
    : super('0164', min: -125, max: 130, prio: 5);

  int idleTorque = 0;
  int torquePoint1 = 0;
  int torquePoint2 = 0;
  int torquePoint3 = 0;
  int torquePoint4 = 0;

  @override
  void performCalculations(List<int> data) {
    if (data.length >= 5) {
      idleTorque = data[0] - 125;
      torquePoint1 = data[1] - 125;
      torquePoint2 = data[2] - 125;
      torquePoint3 = data[3] - 125;
      torquePoint4 = data[4] - 125;
      result = idleTorque.toDouble(); // Primary result is idle torque
      super.performCalculations(data);
    }
  }

  @override
  String get formattedResult =>
      'Idle: $idleTorque%, P1: $torquePoint1%, P2: $torquePoint2%';

  @override
  String get description =>
      'Engine percent torque data at various operating points';

  @override
  IconData get icon => Icons.data_usage;

  @override
  String get name => 'Torque Data';

  @override
  String get unit => '%';
}
