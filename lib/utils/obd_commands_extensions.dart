import 'package:smart_car/pages/live_data/model/abstract_commands/obd_command.dart';
import 'package:smart_car/pages/live_data/model/commaned_air_fuel_ratio_command.dart';
import 'package:smart_car/pages/live_data/model/fuel_level_command.dart';
import 'package:smart_car/pages/live_data/model/fuel_system_status_command.dart';
import 'package:smart_car/pages/live_data/model/speed_command.dart';
import 'package:smart_car/pages/live_data/model/term_fuel_trim_command.dart';
import 'package:smart_car/utils/list_extension.dart';

extension ObdCommandsExtensions on List<ObdCommand> {
  FuelSystemStatus get fuelSystemStatus =>
      safeFirst<FuelSystemStatusCommand>()?.status ?? FuelSystemStatus.motorOff;

  double get speed => safeFirst<SpeedCommand>()?.result.toDouble() ?? 0;
  double? get fuelLevel => safeFirst<FuelLevelCommand>()?.result.toDouble();

  double? get airFuelRatio =>
      safeFirst<CommandedAirFuelRatioCommand>()?.result.toDouble();

  double get stft1 =>
      safeFirst<ShortTermFuelTrimBank1>()?.result.toDouble() ?? 0.0;

  double get stft2 =>
      safeFirst<ShortTermFuelTrimBank2>()?.result.toDouble() ?? 0.0;

  double get ltft1 =>
      safeFirst<LongTermFuelTrimBank1>()?.result.toDouble() ?? 0.0;

  double get ltft2 =>
      safeFirst<LongTermFuelTrimBank2>()?.result.toDouble() ?? 0.0;
}
