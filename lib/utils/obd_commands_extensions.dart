import 'package:smart_car/models/commands/actual_engine_torque_command.dart';
import 'package:smart_car/models/commands/engine_coolant_temp_extended_command.dart';
import 'package:smart_car/models/commands/engine_fuel_rate_command.dart';
import 'package:smart_car/models/commands/engine_reference_torque_command.dart';
import 'package:smart_car/models/commands/intake_air_temp_extended_command.dart';
import 'package:smart_car/models/commands/transmission_actual_gear_command.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/obd_command.dart';
import 'package:smart_car/pages/live_data/model/commaned_air_fuel_ratio_command.dart';
import 'package:smart_car/pages/live_data/model/engine_coolant_command.dart';
import 'package:smart_car/pages/live_data/model/fuel_level_command.dart';
import 'package:smart_car/pages/live_data/model/fuel_system_status_command.dart';
import 'package:smart_car/pages/live_data/model/intake_air_temp_command.dart';
import 'package:smart_car/pages/live_data/model/map_command.dart';
import 'package:smart_car/pages/live_data/model/rpm_command.dart';
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

  double get rpm => safeFirst<RpmCommand>()?.result.toDouble() ?? 0.0;

  double? get mapPressure => safeFirst<MapCommand>()?.result.toDouble();

  MapCommand? get mapCommand => safeFirst<MapCommand>();

  /// Intake air temperature – prefers PID 0x0F, falls back to extended PID 0x68
  double get intakeAirTemp {
    final v = safeFirst<IntakeAirTempCommand>()?.result.toDouble();
    if (v != null && v.isFinite) return v;
    final ext = safeFirst<IntakeAirTempExtendedCommand>()?.result.toDouble();
    return (ext != null && ext.isFinite) ? ext : 25.0;
  }

  /// Engine coolant temperature – prefers PID 0x05, falls back to extended PID 0x67
  double? get engineCoolantTemp {
    final v = safeFirst<EngineCoolantCommand>()?.result.toDouble();
    if (v != null && v.isFinite) return v;
    final ext = safeFirst<EngineCoolantTempExtendedCommand>()?.result
        .toDouble();
    return (ext != null && ext.isFinite) ? ext : null;
  }

  /// Engine fuel rate in L/h from PID 0x5E (null when not supported)
  double? get engineFuelRateLh {
    final v = safeFirst<EngineFuelRateCommand>()?.result.toDouble();
    return (v != null && v.isFinite) ? v : null;
  }

  /// Instantaneous torque in Nm from PID 0x62 + 0x63 (null when either is missing)
  double? get instantTorqueNm {
    final percentCmd = safeFirst<ActualEngineTorqueCommand>();
    final refCmd = safeFirst<EngineReferenceTorqueCommand>();
    if (percentCmd == null || refCmd == null) return null;
    if (!percentCmd.result.isFinite || !refCmd.result.isFinite) return null;
    return (percentCmd.result / 100.0) * refCmd.result;
  }

  /// Transmission actual gear from PID 0xA4 (null when not supported)
  TransmissionActualGearCommand? get gearCommand =>
      safeFirst<TransmissionActualGearCommand>();
}
