import 'package:flutter/material.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/percent_obd_command.dart';

/// PID 0x5A - Relative accelerator pedal position
/// Formula: (100 / 255) * A
/// Min: 0, Max: 100
class RelativeAcceleratorPedalPositionCommand extends PercentObdCommand {
  RelativeAcceleratorPedalPositionCommand()
    : super('015A', min: 0, max: 100, prio: 1);

  @override
  Color get color {
    if (result > 80) return dangerColor;
    if (result > 50) return warningColor;
    return normalColor;
  }

  @override
  String get description => 'Relative accelerator pedal position';

  @override
  IconData get icon => Icons.directions_car;

  @override
  String get name => 'Pedal Position';
}
