import 'package:smart_car/pages/live_data/model/abstract_commands/percent_obd_command.dart';

class AbsoluteLoadValueCommand extends PercentObdCommand {
  AbsoluteLoadValueCommand() : super('0143', prio: 1, min: 0, max: 25700);

  @override
  void performCalculations(List<int> data) {
    if (data.length >= 2) {
      result = 100 * (256 * data[0] + data[1]) / 255;
      super.performCalculations(data);
    }
  }

  @override
  String get description => 'Absolute load value';

  @override
  String get name => 'Abs. load';
}
