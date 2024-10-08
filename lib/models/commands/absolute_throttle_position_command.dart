import 'package:smart_car/pages/live_data/model/abstract_commands/percent_obd_command.dart';

class AbsoluteThrottlePositionBCommand extends PercentObdCommand {
  AbsoluteThrottlePositionBCommand() : super('0147', prio: 1);

  @override
  String get description => 'Absolute throttle position B';

  @override
  String get name => 'Throttle B';
}

class AbsoluteThrottlePositionCCommand extends PercentObdCommand {
  AbsoluteThrottlePositionCCommand() : super('0148', prio: 1);

  @override
  String get description => 'Absolute throttle position C';

  @override
  String get name => 'Throttle C';
}
