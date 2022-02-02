import 'package:smart_car/pages/live_data/model/abstract_commands/percent_obd_command.dart';

class CommandedThrottleActuatorCommand extends PercentObdCommand {
  CommandedThrottleActuatorCommand() : super('01 4C', prio: 1);

  @override
  String get description => 'Commanded throttle actuator';

  @override
  String get name => 'Actuator';
}
