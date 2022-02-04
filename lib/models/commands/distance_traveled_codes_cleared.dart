import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';

class DistanceTraveledSinceCodesCleared extends VisibleObdCommand {
  DistanceTraveledSinceCodesCleared()
      : super('0131', prio: 300, min: 0, max: 65535);

  @override
  void performCalculations(List<int> data) {
    if (data.length >= 2) {
      result = 256 * data[0] + data[1];
      super.performCalculations(data);
    }
  }

  @override
  String get description => 'Distance traveled since codes cleared';

  @override
  String get name => 'Dist. cleared';

  @override
  String get unit => 'km';
}
