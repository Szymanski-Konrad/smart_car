import 'package:flutter/material.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';

class MapCommand extends VisibleObdCommand {
  MapCommand() : super('01 0B', min: 0, max: 255, prio: 0);

  @override
  String get description => 'Current MAP (Manifold Absolute pressure)';

  @override
  String get name => 'MAP';

  @override
  void performCalculations(List<int> data) {
    if (data.isNotEmpty) {
      previousResult = result;
      result = data[0];
      super.performCalculations(data);
    }
  }

  @override
  String get unit => 'kPa';

  @override
  IconData get icon => Icons.air;

  double gramsOfAir() {
    return 0.0;
  }

  String get formattedResult =>
      result.isFinite ? '$result $unit' : super.formattedResult;
}
