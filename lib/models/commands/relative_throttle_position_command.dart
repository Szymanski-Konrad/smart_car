import 'package:smart_car/pages/live_data/model/abstract_commands/percent_obd_command.dart';

class RelativeThrottlePositionCommand extends PercentObdCommand {
  RelativeThrottlePositionCommand() : super('01 45', prio: 1);

  @override
  String get description => 'Relative Throttle Position';

  @override
  String get name => 'Rel. throttle';

  @override
  String get unit => '%';
}
