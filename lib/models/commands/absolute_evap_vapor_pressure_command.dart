import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';

/// PID 0x53 - Absolute Evap system vapor pressure
/// 2 bytes: ((256 * A) + B) / 200 kPa (absolute, range 0–327.675 kPa)
class AbsoluteEvapVaporPressureCommand extends VisibleObdCommand {
  AbsoluteEvapVaporPressureCommand() : super('0153', min: 0, max: 328, prio: 1);

  @override
  void performCalculations(List<int> data) {
    if (data.length >= 2) {
      result = (256 * data[0] + data[1]) / 200.0;
      super.performCalculations(data);
    }
  }

  @override
  String get formattedResult => result.isFinite
      ? '${result.toStringAsFixed(2)} $unit'
      : super.formattedResult;

  @override
  String get description => 'Absolute EVAP system vapor pressure';

  @override
  String get name => 'Abs EVAP';

  @override
  String get unit => 'kPa';
}
