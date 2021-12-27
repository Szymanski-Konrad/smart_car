import 'package:smart_car/pages/live_data/model/abstract_commands/temp_obd_command.dart';

class OilTempCommand extends TempObdCommand {
  OilTempCommand() : super('01 5C', prio: 50);

  @override
  String get description => 'Engine oil temperature';

  @override
  String get name => 'Oil Temp';
}
