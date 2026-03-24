import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';

/// PID 0x58 - Long term secondary O2 sensor trim, Bank 2 & Bank 4
/// 2 bytes: A = Bank 2 trim, B = Bank 4 trim
/// Formula: (X / 1.28) - 100 → range –100% to +99.22%
class SecondaryO2TrimLongB2B4Command extends VisibleObdCommand {
  SecondaryO2TrimLongB2B4Command()
      : super('0158', min: -100, max: 100, prio: 1);

  double bank2 = 0;
  double bank4 = 0;

  @override
  void performCalculations(List<int> data) {
    if (data.length >= 2) {
      bank2 = (data[0] / 1.28) - 100.0;
      bank4 = (data[1] / 1.28) - 100.0;
      result = bank2;
      super.performCalculations(data);
    }
  }

  @override
  String get formattedResult =>
      'B2:${bank2.toStringAsFixed(1)}% B4:${bank4.toStringAsFixed(1)}%';

  @override
  String get description => 'Long term secondary O2 trim B2/B4';

  @override
  String get name => 'LTSO2 B2/B4';

  @override
  String get unit => '%';
}
