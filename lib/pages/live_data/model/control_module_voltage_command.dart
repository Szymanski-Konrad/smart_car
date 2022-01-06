import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/icon_data.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';

class ControlModuleVoltageCommand extends VisibleObdCommand {
  ControlModuleVoltageCommand() : super('01 42', prio: 5);

  @override
  String get formattedResult => '$result $unit';

  @override
  void performCalculations(List<int> data) {
    if (data.length >= 2) {
      result = (256 * data[0] + data[1]) / 1000;
      super.performCalculations(data);
    }
  }

  @override
  String get description => 'Control module voltage';

  @override
  IconData get icon => Icons.electrical_services;

  @override
  String get name => 'Voltage';

  @override
  String get unit => 'V';
}
