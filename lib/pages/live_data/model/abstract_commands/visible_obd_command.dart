import 'package:flutter/material.dart';
import 'package:smart_car/app/resources/color_palette.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/obd_command.dart';

abstract class VisibleObdCommand extends ObdCommand {
  VisibleObdCommand(
    String command, {
    required num min,
    required num max,
    required int prio,
    this.range = 0.0,
    bool enableHistory = true,
  }) : super(command,
            min: min, max: max, prio: prio, enableHistorical: enableHistory);

  String get name;
  String get description;

  String get unit;
  String get formattedResult => '-.- $unit';
  String get formattedReactionTime => '$responseTime ms';

  double range;

  Color get normalColor => ColorPalette.normal;
  Color get warningColor => ColorPalette.warning;
  Color get dangerColor => ColorPalette.danger;

  Color get color {
    if (max * 0.8 < result) return dangerColor;
    if (max * 0.6 < result) return warningColor;
    return normalColor;
  }

  @override
  void performCalculations(List<int> data) {
    if (data.isNotEmpty) {
      super.performCalculations(data);
    }
  }

  IconData get icon => Icons.bar_chart;
}
