import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';

class AbsoluteBarometricPressureCommand extends VisibleObdCommand {
  AbsoluteBarometricPressureCommand()
      : super('0133', prio: 1, min: 0, max: 255);

  @override
  void performCalculations(List<int> data) {
    if (data.isNotEmpty) {
      result = data[0];
      super.performCalculations(data);
    }
  }

  @override
  String get description => 'Absolute barometric pressure';

  @override
  String get name => 'Abs. pressure';

  @override
  String get unit => 'kPa';
}
