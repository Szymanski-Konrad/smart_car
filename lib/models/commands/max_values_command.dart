import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';

/// PID 0x4F - Maximum value for lambda, O2 voltage, O2 current, MAP
/// 4 bytes:
///   A = max lambda equivalence ratio (A * 0.0039216, range 0..3.999)
///   B = max O2 sensor voltage (B * 0.005 V, range 0..1.275 V)
///   C = max O2 sensor current (C * 0.005 mA, range 0..1.275 mA -- actually 0..127.5 mA? note: signed)
///   D = max intake manifold absolute pressure (D * 10 kPa, range 0..2550 kPa)
class MaxValuesCommand extends VisibleObdCommand {
  MaxValuesCommand() : super('014F', min: 0, max: 4, prio: 1);

  double maxLambda = 0;
  double maxO2Voltage = 0;
  double maxO2Current = 0;
  double maxMap = 0;

  @override
  void performCalculations(List<int> data) {
    if (data.length >= 4) {
      maxLambda = data[0] * 0.0039216;
      maxO2Voltage = data[1] * 0.005;
      maxO2Current = data[2] * 0.005;
      maxMap = data[3] * 10.0;
      result = maxLambda;
      super.performCalculations(data);
    }
  }

  @override
  String get formattedResult =>
      'λ:${maxLambda.toStringAsFixed(3)} V:${maxO2Voltage.toStringAsFixed(2)} MAP:${maxMap.toStringAsFixed(0)}kPa';

  @override
  String get description => 'Max values: lambda, O2 voltage, O2 current, MAP';

  @override
  String get name => 'Max Values';

  @override
  String get unit => '';
}
