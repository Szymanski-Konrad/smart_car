import 'package:smart_car/pages/live_data/model/abstract_commands/percent_obd_command.dart';

class AcceleratorPedalPositionDCommand extends PercentObdCommand {
  AcceleratorPedalPositionDCommand() : super('01 49', prio: 1);

  @override
  String get description => 'Accelerator pedal positon D';

  @override
  String get name => 'Accelerator D';
}

class AcceleratorPedalPositionECommand extends PercentObdCommand {
  AcceleratorPedalPositionECommand() : super('01 4A', prio: 1);

  @override
  String get description => 'Accelerator pedal positon E';

  @override
  String get name => 'Accelerator E';
}

class AcceleratorPedalPositionFCommand extends PercentObdCommand {
  AcceleratorPedalPositionFCommand() : super('01 4B', prio: 1);

  @override
  String get description => 'Accelerator pedal positon F';

  @override
  String get name => 'Accelerator F';
}
