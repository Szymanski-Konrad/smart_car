import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';

class CylinderFuelRateCommand extends VisibleObdCommand {
  CylinderFuelRateCommand() : super('01A2', prio: 0, min: 0, max: 2047);

  @override
  void performCalculations(List<int> data) {
    if (data.length >= 2) {
      result = (256 * data[0] + data[1]) / 32;
      super.performCalculations(data);
    }
  }

  @override
  String get description => 'Cylinder Fuel Rate';

  @override
  String get name => 'Cylinder rate';

  @override
  String get unit => 'mg/stroke';
}
