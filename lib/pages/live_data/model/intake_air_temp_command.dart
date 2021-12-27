import 'package:smart_car/pages/live_data/model/abstract_commands/temp_obd_command.dart';

class IntakeAirTempCommand extends TempObdCommand {
  IntakeAirTempCommand() : super('01 0F', prio: 150);

  @override
  String get description => 'Show temperature of intake air';

  @override
  String get name => 'Air temp';
}
