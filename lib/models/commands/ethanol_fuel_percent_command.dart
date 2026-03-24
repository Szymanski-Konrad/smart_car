import 'package:flutter/material.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';

/// PID 0x52 - Ethanol fuel %
/// Formula: A / 2.55
/// Min: 0, Max: 100
class EthanolFuelPercentCommand extends VisibleObdCommand {
  EthanolFuelPercentCommand() : super('0152', min: 0, max: 100, prio: 5);

  @override
  void performCalculations(List<int> data) {
    if (data.isNotEmpty) {
      result = data[0] / 2.55;
      super.performCalculations(data);
    }
  }

  @override
  Color get color {
    if (result > 85) return Colors.green;
    if (result > 50) return Colors.orange;
    return normalColor;
  }

  @override
  String get formattedResult => '${result.toStringAsFixed(1)} $unit';

  @override
  String get description => 'Ethanol fuel percentage (E85 content)';

  @override
  IconData get icon => Icons.eco;

  @override
  String get name => 'Ethanol %';

  @override
  String get unit => '%';
}
