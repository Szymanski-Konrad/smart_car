import 'package:smart_car/pages/live_data/model/abstract_commands/percent_obd_command.dart';

class CommandedEGRCommand extends PercentObdCommand {
  CommandedEGRCommand() : super('01 2C', prio: 1);

  @override
  String get description => 'Commanded EGR';

  @override
  String get name => 'EGR';
}
