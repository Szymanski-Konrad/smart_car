import 'package:flutter/material.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/percent_obd_command.dart';

class FuelLevelCommand extends PercentObdCommand {
  FuelLevelCommand() : super('01 2F', prio: 150);

  @override
  int get priority => 100;

  @override
  String get description => 'Show current level of fuel in tank';

  @override
  String get name => 'Fuel level';

  @override
  IconData get icon => Icons.local_gas_station;
}
