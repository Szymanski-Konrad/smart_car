import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';

/// PID 0x54 - Evap system vapor pressure (signed)
/// 2 bytes: signed two's complement 16-bit / 4000 kPa
/// Range: –32768 to +32767 → –8.192 to +8.191 kPa
class EvapVaporPressureV2Command extends VisibleObdCommand {
  EvapVaporPressureV2Command()
      : super('0154', min: -8.2, max: 8.2, prio: 1);

  @override
  void performCalculations(List<int> data) {
    if (data.length >= 2) {
      final raw = (data[0] << 8) | data[1];
      // interpret as signed 16-bit
      final signed = raw > 32767 ? raw - 65536 : raw;
      result = signed / 4000.0;
      super.performCalculations(data);
    }
  }

  @override
  String get formattedResult =>
      result.isFinite ? '${result.toStringAsFixed(4)} $unit' : super.formattedResult;

  @override
  String get description => 'EVAP system vapor pressure (signed)';

  @override
  String get name => 'EVAP v2';

  @override
  String get unit => 'kPa';
}
