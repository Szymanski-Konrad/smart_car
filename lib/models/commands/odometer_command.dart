import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';

class OdometerCommand extends VisibleObdCommand {
  OdometerCommand() : super('01 A6', min: 0, max: 2000000, prio: 10);

  static const A = 16777216;
  static const B = 65536;
  static const C = 256;

  @override
  void performCalculations(List<int> data) {
    if (data.length >= 4) {
      result = (data[0] * A + data[1] * B + data[2] * C + data[3]) / 10;
      super.performCalculations(data);
    }
  }

  @override
  String get description => 'Odometer';

  @override
  String get name => 'Odometer';

  @override
  String get unit => 'km';
}
