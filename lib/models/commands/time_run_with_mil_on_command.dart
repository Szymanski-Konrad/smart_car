import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';

class TimeRunWithMILOn extends VisibleObdCommand {
  TimeRunWithMILOn() : super('014D', prio: 10, min: 0, max: 65535);

  @override
  void performCalculations(List<int> data) {
    if (data.length >= 2) {
      result = 256 * data[0] + data[1];
      super.performCalculations(data);
    }
  }

  @override
  String get description => 'Time run with MIL on';

  @override
  String get name => 'MIL on';

  @override
  String get unit => 'min';
}
