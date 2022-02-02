import 'package:smart_car/pages/live_data/model/abstract_commands/temp_obd_command.dart';

class AmbientAirTemperatureCommand extends TempObdCommand {
  AmbientAirTemperatureCommand() : super('01 45', prio: 10);

  @override
  String get description => 'Ambient air temperature';

  @override
  String get name => 'Ambient temp';
}
