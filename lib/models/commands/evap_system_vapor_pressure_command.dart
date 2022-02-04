import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';

class EvapSystemVaporPressureCommand extends VisibleObdCommand {
  EvapSystemVaporPressureCommand()
      : super('0132', prio: 1, min: -8192, max: 8192);

  @override
  void performCalculations(List<int> data) {
    if (data.length >= 2) {
      result = (256 * data[0] + data[1]) / 4;
      super.performCalculations(data);
    }
  }

  @override
  String get description => 'Evap system vapor pressure';

  @override
  String get name => 'Evap pressure';

  @override
  String get unit => 'Pa';
}
