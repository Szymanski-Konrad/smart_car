import 'package:flutter/material.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';

class SpeedCommand extends VisibleObdCommand {
  SpeedCommand() : super('01 0D', prio: 0);

  double get traveledDistance => result * 1000 * responseTime / 3600000;

  @override
  String get description => 'Speed of the vehicle';

  @override
  String get name => 'Speed';

  @override
  void performCalculations(List<int> data) {
    if (data.isNotEmpty) {
      previousResult = result;
      result = data[0];
      super.performCalculations(data);
    }
  }

  @override
  String get unit => 'km/h';

  @override
  double? get max => 255;

  @override
  double? get min => 0;

  @override
  IconData get icon => Icons.speed;

  /// Return distance traveled between pid readings in [kilometers]
  double get distanceTraveled {
    if (differenceMiliseconds == 0 || result == 0) return 0;
    return (result / 3600000) * differenceMiliseconds;
  }

  /// Return acceleration in m/s
  double acceleration() {
    if (historyData.isEmpty || historyData.length < 2) return 0;
    final speedDiff = historyData[historyData.length - 1] -
        historyData[historyData.length - 2];
    return (speedDiff * 1000 / 3600) / (differenceMiliseconds / 1000);
  }

  @override
  String get formattedResult =>
      result.isFinite ? '$result $unit' : super.formattedResult;
}
