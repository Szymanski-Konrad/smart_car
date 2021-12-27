import 'package:smart_car/pages/live_data/model/abstract_commands/temp_obd_command.dart';

class EngineCoolantCommand extends TempObdCommand {
  EngineCoolantCommand() : super('01 05', prio: 100);

  @override
  String get description => 'Coolant temperature of engine';

  @override
  String get name => 'Engine coolant';
}
