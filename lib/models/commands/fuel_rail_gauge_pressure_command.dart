import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';

class FuelRailGaugePressureCommand extends VisibleObdCommand {
  FuelRailGaugePressureCommand() : super('0123', min: 0, max: 655350, prio: 1);

  @override
  void performCalculations(List<int> data) {
    if (data.length >= 2) {
      result = 10 * (256 * data[0] + data[1]);
      super.performCalculations(data);
    }
  }

  @override
  String get description => 'Fuel rail gauge pressure';

  @override
  String get name => 'Rail Gauge';

  @override
  String get unit => 'kPa';
}
