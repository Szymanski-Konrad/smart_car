import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';

class WarmupsSinceCodesClearedCommand extends VisibleObdCommand {
  WarmupsSinceCodesClearedCommand()
      : super('0130', prio: 1000, min: 0, max: 255);

  @override
  void performCalculations(List<int> data) {
    if (data.isNotEmpty) {
      result = data[0];
      super.performCalculations(data);
    }
  }

  @override
  String get description => 'Warm-ups since codes cleared';

  @override
  String get name => 'Warmups';

  @override
  String get unit => '';
}
