import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';

/// PID 0x55 - Short term secondary O2 sensor trim, Bank 1 & Bank 3
/// 2 bytes: A = Bank 1 trim, B = Bank 3 trim
/// Formula: (X / 1.28) - 100 → range –100% to +99.22%
class SecondaryO2TrimShortB1B3Command extends VisibleObdCommand {
  SecondaryO2TrimShortB1B3Command()
      : super('0155', min: -100, max: 100, prio: 1);

  double bank1 = 0;
  double bank3 = 0;

  @override
  void performCalculations(List<int> data) {
    if (data.length >= 2) {
      bank1 = (data[0] / 1.28) - 100.0;
      bank3 = (data[1] / 1.28) - 100.0;
      result = bank1;
      super.performCalculations(data);
    }
  }

  @override
  String get formattedResult =>
      'B1:${bank1.toStringAsFixed(1)}% B3:${bank3.toStringAsFixed(1)}%';

  @override
  String get description => 'Short term secondary O2 trim B1/B3';

  @override
  String get name => 'STSO2 B1/B3';

  @override
  String get unit => '%';
}
