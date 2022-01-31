import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/icon_data.dart';
import 'dart:ui';

import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';

class FuelInjectionTime extends VisibleObdCommand {
  FuelInjectionTime() : super('01 5D', min: -210, max: 302, prio: 0);

  @override
  Color get color {
    if (max * 0.8 < result) return dangerColor;
    if (max * 0.6 < result) return warningColor;
    return normalColor;
  }

  @override
  void performCalculations(List<int> data) {
    if (data.length > 2) {
      result = (256 * data[0] + data[1]) / 128 - 210;
      super.performCalculations(data);
    }
  }

  @override
  String get description => 'Fuel injection timing';

  @override
  IconData get icon => Icons.timelapse_outlined;

  @override
  String get name => 'Fuel inj. t';

  @override
  String get unit => '°';
}
