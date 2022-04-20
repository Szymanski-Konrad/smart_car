// ignore_for_file: constant_identifier_names

import 'package:smart_car/models/commands/absolute_barometric_pressure_command.dart';
import 'package:smart_car/models/commands/absolute_load_value_command.dart';
import 'package:smart_car/models/commands/absolute_throttle_position_command.dart';
import 'package:smart_car/models/commands/accelerator_pedal_position_command.dart';
import 'package:smart_car/models/commands/ambient_air_temperature_command.dart';
import 'package:smart_car/models/commands/auxiliary_input_status_command.dart';
import 'package:smart_car/models/commands/catalyst_temperature_bank_command.dart';
import 'package:smart_car/models/commands/commanded_egr_command.dart';
import 'package:smart_car/models/commands/commanded_secondary_air_status_command.dart';
import 'package:smart_car/models/commands/commanded_throttle_actuator_command.dart';
import 'package:smart_car/models/commands/cylinder_fuel_rate_command.dart';
import 'package:smart_car/models/commands/distance_traveled_codes_cleared.dart';
import 'package:smart_car/models/commands/egr_error_command.dart';
import 'package:smart_car/models/commands/engine_fuel_rate_command.dart';
import 'package:smart_car/models/commands/engine_reference_torque_command.dart';
import 'package:smart_car/models/commands/evap_system_vapor_pressure_command.dart';
import 'package:smart_car/models/commands/fuel_injection_time.dart';
import 'package:smart_car/models/commands/fuel_pressure_command.dart';
import 'package:smart_car/models/commands/fuel_rail_gauge_pressure_command.dart';
import 'package:smart_car/models/commands/fuel_rail_pressure_command.dart';
import 'package:smart_car/models/commands/fuel_type_command.dart';
import 'package:smart_car/models/commands/hybrid_battery_remaining_life_command.dart';
import 'package:smart_car/models/commands/odometer_command.dart';
import 'package:smart_car/models/commands/relative_throttle_position_command.dart';
import 'package:smart_car/models/commands/run_time_since_start_command.dart';
import 'package:smart_car/models/commands/time_run_with_mil_on_command.dart';
import 'package:smart_car/models/commands/time_since_troubles_codes_cleared_command.dart';
import 'package:smart_car/models/commands/warmups_since_codes_cleared_command.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/obd_command.dart';
import 'package:smart_car/pages/live_data/model/battery_voltage_command.dart';
import 'package:smart_car/pages/live_data/model/commanded_evaporative_purge_command.dart';
import 'package:smart_car/pages/live_data/model/commands/oxygen_commands/oxygen_senor_trim_volts.dart';
import 'package:smart_car/pages/live_data/model/commands/oxygen_commands/oxygen_sensor_lambda_voltage_command.dart';
import 'package:smart_car/pages/live_data/model/commands/oxygen_commands/oxygen_sensor_lamdba_current_command.dart';
import 'package:smart_car/pages/live_data/model/commaned_air_fuel_ratio_command.dart';
import 'package:smart_car/pages/live_data/model/control_module_voltage_command.dart';
import 'package:smart_car/pages/live_data/model/distance_with_mil_command.dart';
import 'package:smart_car/pages/live_data/model/engine_coolant_command.dart';
import 'package:smart_car/pages/live_data/model/engine_load_command.dart';
import 'package:smart_car/pages/live_data/model/fuel_level_command.dart';
import 'package:smart_car/pages/live_data/model/fuel_system_status_command.dart';
import 'package:smart_car/pages/live_data/model/intake_air_temp_command.dart';
import 'package:smart_car/pages/live_data/model/maf_command.dart';
import 'package:smart_car/pages/live_data/model/map_command.dart';
import 'package:smart_car/pages/live_data/model/obd_standard_command.dart';
import 'package:smart_car/pages/live_data/model/oil_temp_command.dart';
import 'package:smart_car/pages/live_data/model/rpm_command.dart';
import 'package:smart_car/pages/live_data/model/speed_command.dart';
import 'package:smart_car/pages/live_data/model/term_fuel_trim_command.dart';
import 'package:smart_car/pages/live_data/model/throttle_position_command.dart';
import 'package:smart_car/pages/live_data/model/timing_advance_command.dart';

abstract class Pids {
  // Unsupported pids
  static const String oxygenSensorsPresents2B = '13';
  static const String oxygenSensorsPresents4B = '1D';
  static const String monitorStatusDriveCycle = '41';
  static const String maxValuesP1 = '4F';
  static const String maxMAFValue = '50';
  static const String ethanolFuelRemaining = '52';
  static const String absoluteEvapSystemVaporPressure = '53';
  static const String evapSystemVaporPressureV2 = '54';
  static const String secondaryOxygenSensor1 = '55';
  static const String secondaryOxygenSensor2 = '56';
  static const String secondaryOxygenSensor3 = '57';
  static const String secondaryOxygenSensor4 = '58';
  static const String fuelRailAbsolutePressure = '59';
  static const String relativeAcceleratorPedalPosition = '5A';
  static const String emissionRequirements = '5F';
  static const String driversDemandEnginePercentTorque = '61';
  static const String actualEnginePercentTorque = '62';
  static const String enginePercentTorqueData = '64';
  static const String auxiliarySupported = '65';
  static const String mafSensor = '66';
  static const String engineCoolantTemp = '67';
  static const String intakeAirTempSensor = '68';

  static const String transmissionActualGear = 'A4';

  // Supported pids
  static const String fuelSystemStatus = '03';
  static const String engineLoad = '04';
  static const String engineCoolant = '05';
  static const String shortTermFTB1 = '06';
  static const String longTermFTB1 = '07';
  static const String shortTermFTB2 = '08';
  static const String longTermFTB2 = '09';
  static const String fuelPressure = '0A';
  static const String intakeManifoldAbsolutePressure = '0B';
  static const String rpm = '0C';
  static const String speed = '0D';
  static const String timingAdvance = '0E';
  static const String intakeAirTemp = '0F';
  static const String maf = '10';
  static const String throttlePosition = '11';
  static const String commandedSecondaryAirStatus = '12';
  static const String oxygenSensor1A = '14';
  static const String oxygenSensor2A = '15';
  static const String oxygenSensor3A = '16';
  static const String oxygenSensor4A = '17';
  static const String oxygenSensor5A = '18';
  static const String oxygenSensor6A = '19';
  static const String oxygenSensor7A = '1A';
  static const String oxygenSensor8A = '1B';
  static const String obdStandards = '1C';
  static const String auxiliaryInputStatus = '1E';
  static const String runTimeSinceStart = '1F';
  static const String distanceTraveledMIL = '21';
  static const String fuelRailPressure = '22';
  static const String fuelRailGaugePressure = '23';
  static const String oxygenSensor1B = '24';
  static const String oxygenSensor2B = '25';
  static const String oxygenSensor3B = '26';
  static const String oxygenSensor4B = '27';
  static const String oxygenSensor5B = '28';
  static const String oxygenSensor6B = '29';
  static const String oxygenSensor7B = '2A';
  static const String oxygenSensor8B = '2B';
  static const String commandedEGR = '2C';
  static const String egrError = '2D';
  static const String commandedEvaporativePurge = '2E';
  static const String fuelLevel = '2F';
  static const String warmUpsSinceCodeCleared = '30';
  static const String distanceTraveledSinceCodesCleared = '31';
  static const String evapSystemVaporPressure = '32';
  static const String absoluteBarometricPressure = '33';
  static const String oxygenSensor1C = '34';
  static const String oxygenSensor2C = '35';
  static const String oxygenSensor3C = '36';
  static const String oxygenSensor4C = '37';
  static const String oxygenSensor5C = '38';
  static const String oxygenSensor6C = '39';
  static const String oxygenSensor7C = '3A';
  static const String oxygenSensor8C = '3B';
  static const String catalystTemperatureB1S1 = '3C';
  static const String catalystTemperatureB2S1 = '3D';
  static const String catalystTemperatureB1S2 = '3E';
  static const String catalystTemperatureB2S2 = '3F';
  static const String controlModuleVoltage = '42';
  static const String absoluteLoadValue = '43';
  static const String commandedAirFuelRatio = '44';
  static const String relativeThrottlePosition = '45';
  static const String ambientAirTemperature = '46';
  static const String absoluteThrottlePositionB = '47';
  static const String absoluteThrottlePositionC = '48';
  static const String acceleratorPedalPositionD = '49';
  static const String acceleratorPedalPositionE = '4A';
  static const String acceleratorPedalPositionF = '4B';
  static const String commanededThrottleAcutator = '4C';
  static const String timeRunWithMIL = '4D';
  static const String timeSinceTroubleCodesCleared = '4E';
  static const String fuelType = '51';
  static const String hybridBatteryPackRemainingLife = '5B';
  static const String oilTemp = '5C';
  static const String fuelInjectionTiming = '5D';
  static const String engineFuelRate = '5E';
  static const String engineReferenceTorque = '63';
  static const String cylinderFuelRate = 'A2';
  static const String odometer = 'A6';

  /// Special commands
  static const String pidsList1 = '00';
  static const String pidsList2 = '20';
  static const String pidsList3 = '40';
  static const String pidsList4 = '60';
  static const String pidsList5 = '80';
  static const String pidsList6 = 'A0';
  static const String pidsList7 = 'C0';
  static const String ATRV = 'ATRV';
}

const List<String> initializeCommands = [
  'AT Z', // Reset OBD
  'AT L0', // Line feed off
  'AT S0', // Spaces off
  'AT ST 96', // Set timeout to 150 ms
  'AT SP 0', // Set protocol to auto
  'AT E0', // Echo off
];

const List<String> checkPidsCommands = [
  '0100',
  '0120',
  '0140',
  '0160',
  '0180',
  '01A0',
  '01C0',
];

const List<String> untouchableCommads = [
  Pids.maf,
  Pids.fuelSystemStatus,
  Pids.engineCoolant,
  Pids.rpm,
  Pids.speed,
  Pids.intakeAirTemp,
  Pids.fuelLevel,
  Pids.controlModuleVoltage,
  Pids.commandedAirFuelRatio,
  Pids.ATRV,
];

enum PID {
  atrv,
  engineCoolant,
  engineLoad,
  fuelLevel,
  intakeAirTemp,
  maf,
  oilTemp,
  rpm,
  speed,
  throttlePosition,
  fuelSystemStatus,
  commandedAirFuelRatio,
  oxygenSensor1A,
  oxygenSensor2A,
  oxygenSensor3A,
  oxygenSensor4A,
  oxygenSensor5A,
  oxygenSensor6A,
  oxygenSensor7A,
  oxygenSensor8A,
  STFTB1,
  LTFTB1,
  STFTB2,
  LTFTB2,
  controlModuleVoltage,
  timingAdvance,
  commandedEvaporativePurge,
  obdStandards,
  distanceTraveledMIL,
  intakeManifoldAbsolutePressure,
  engineFuelRate,
  fuelPressure,
  runTimeSinceStart,
  fuelInjectionTiming,
  fuelRailPressure,
  fuelRailGaugePressure,
  relativeThrottlePosition,
  ambientAirTemperature,
  engineReferenceTorque,
  odometer,
  commandedSecondaryAirStatus,
  auxiliaryInputStatus,
  oxygenSensor1B,
  oxygenSensor2B,
  oxygenSensor3B,
  oxygenSensor4B,
  oxygenSensor5B,
  oxygenSensor6B,
  oxygenSensor7B,
  oxygenSensor8B,
  commandedEGR,
  egrError,
  warmUpsSinceCodeCleared,
  distanceTraveledSinceCodesCleared,
  evapSystemVaporPressure,
  absoluteBarometricPressure,
  oxygenSensor1C,
  oxygenSensor2C,
  oxygenSensor3C,
  oxygenSensor4C,
  oxygenSensor5C,
  oxygenSensor6C,
  oxygenSensor7C,
  oxygenSensor8C,
  catalystTemperatureB1S1,
  catalystTemperatureB2S1,
  catalystTemperatureB1S2,
  catalystTemperatureB2S2,
  absoluteLoadValue,
  absoluteThrottlePositionB,
  absoluteThrottlePositionC,
  acceleratorPedalPositionD,
  acceleratorPedalPositionE,
  acceleratorPedalPositionF,
  commanededThrottleAcutator,
  timeRunWithMIL,
  timeSinceTroubleCodesCleared,
  hybridBatteryPackRemainingLife,
  fuelType,
  cylinderFuelRate,
  unknown,
}

extension PIDExtension on PID {
  static PID code(String value) {
    switch (value) {
      case Pids.cylinderFuelRate:
        return PID.cylinderFuelRate;
      case Pids.commandedSecondaryAirStatus:
        return PID.commandedSecondaryAirStatus;
      case Pids.auxiliaryInputStatus:
        return PID.auxiliaryInputStatus;
      case Pids.oxygenSensor1B:
        return PID.oxygenSensor1B;
      case Pids.oxygenSensor2B:
        return PID.oxygenSensor2B;
      case Pids.oxygenSensor3B:
        return PID.oxygenSensor3B;
      case Pids.oxygenSensor4B:
        return PID.oxygenSensor4B;
      case Pids.oxygenSensor5B:
        return PID.oxygenSensor5B;
      case Pids.oxygenSensor6B:
        return PID.oxygenSensor6B;
      case Pids.oxygenSensor7B:
        return PID.oxygenSensor7B;
      case Pids.oxygenSensor8B:
        return PID.oxygenSensor8B;
      case Pids.commandedEGR:
        return PID.commandedEGR;
      case Pids.egrError:
        return PID.egrError;
      case Pids.warmUpsSinceCodeCleared:
        return PID.warmUpsSinceCodeCleared;
      case Pids.distanceTraveledSinceCodesCleared:
        return PID.distanceTraveledSinceCodesCleared;
      case Pids.evapSystemVaporPressure:
        return PID.evapSystemVaporPressure;
      case Pids.absoluteBarometricPressure:
        return PID.absoluteBarometricPressure;
      case Pids.oxygenSensor1C:
        return PID.oxygenSensor1C;
      case Pids.oxygenSensor2C:
        return PID.oxygenSensor2C;
      case Pids.oxygenSensor3C:
        return PID.oxygenSensor3C;
      case Pids.oxygenSensor4C:
        return PID.oxygenSensor4C;
      case Pids.oxygenSensor5C:
        return PID.oxygenSensor5C;
      case Pids.oxygenSensor6C:
        return PID.oxygenSensor6C;
      case Pids.oxygenSensor7C:
        return PID.oxygenSensor7C;
      case Pids.oxygenSensor8C:
        return PID.oxygenSensor8C;
      case Pids.catalystTemperatureB1S1:
        return PID.catalystTemperatureB1S1;
      case Pids.catalystTemperatureB2S1:
        return PID.catalystTemperatureB2S1;
      case Pids.catalystTemperatureB1S2:
        return PID.catalystTemperatureB1S2;
      case Pids.catalystTemperatureB2S2:
        return PID.catalystTemperatureB2S2;
      case Pids.absoluteLoadValue:
        return PID.absoluteLoadValue;
      case Pids.absoluteThrottlePositionB:
        return PID.absoluteThrottlePositionB;
      case Pids.absoluteThrottlePositionC:
        return PID.absoluteThrottlePositionC;
      case Pids.acceleratorPedalPositionD:
        return PID.acceleratorPedalPositionD;
      case Pids.acceleratorPedalPositionE:
        return PID.acceleratorPedalPositionE;
      case Pids.acceleratorPedalPositionF:
        return PID.acceleratorPedalPositionF;
      case Pids.commanededThrottleAcutator:
        return PID.commanededThrottleAcutator;
      case Pids.timeRunWithMIL:
        return PID.timeRunWithMIL;
      case Pids.timeSinceTroubleCodesCleared:
        return PID.timeSinceTroubleCodesCleared;
      case Pids.hybridBatteryPackRemainingLife:
        return PID.hybridBatteryPackRemainingLife;
      case Pids.fuelType:
        return PID.fuelType;
      case Pids.odometer:
        return PID.odometer;
      case Pids.engineReferenceTorque:
        return PID.engineReferenceTorque;
      case Pids.ambientAirTemperature:
        return PID.ambientAirTemperature;
      case Pids.relativeThrottlePosition:
        return PID.relativeThrottlePosition;
      case Pids.fuelRailGaugePressure:
        return PID.fuelRailGaugePressure;
      case Pids.oxygenSensor1A:
        return PID.oxygenSensor1A;
      case Pids.oxygenSensor2A:
        return PID.oxygenSensor2A;
      case Pids.oxygenSensor3A:
        return PID.oxygenSensor3A;
      case Pids.oxygenSensor4A:
        return PID.oxygenSensor4A;
      case Pids.oxygenSensor5A:
        return PID.oxygenSensor5A;
      case Pids.oxygenSensor6A:
        return PID.oxygenSensor6A;
      case Pids.oxygenSensor7A:
        return PID.oxygenSensor7A;
      case Pids.oxygenSensor8A:
        return PID.oxygenSensor8A;
      case Pids.commandedAirFuelRatio:
        return PID.commandedAirFuelRatio;
      case Pids.shortTermFTB1:
        return PID.STFTB1;
      case Pids.longTermFTB1:
        return PID.LTFTB1;
      case Pids.shortTermFTB2:
        return PID.STFTB2;
      case Pids.longTermFTB2:
        return PID.LTFTB2;
      case Pids.engineCoolant:
        return PID.engineCoolant;
      case Pids.engineLoad:
        return PID.engineLoad;
      case Pids.fuelLevel:
        return PID.fuelLevel;
      case Pids.intakeAirTemp:
        return PID.intakeAirTemp;
      case Pids.maf:
        return PID.maf;
      case Pids.oilTemp:
        return PID.oilTemp;
      case Pids.rpm:
        return PID.rpm;
      case Pids.speed:
        return PID.speed;
      case Pids.throttlePosition:
        return PID.throttlePosition;
      case Pids.fuelSystemStatus:
        return PID.fuelSystemStatus;
      case Pids.timingAdvance:
        return PID.timingAdvance;
      case Pids.obdStandards:
        return PID.obdStandards;
      case Pids.controlModuleVoltage:
        return PID.controlModuleVoltage;
      case Pids.commandedEvaporativePurge:
        return PID.commandedEvaporativePurge;
      case Pids.distanceTraveledMIL:
        return PID.distanceTraveledMIL;
      case Pids.intakeManifoldAbsolutePressure:
        return PID.intakeManifoldAbsolutePressure;
      case Pids.engineFuelRate:
        return PID.engineFuelRate;
      case Pids.fuelPressure:
        return PID.fuelPressure;
      case Pids.runTimeSinceStart:
        return PID.runTimeSinceStart;
      case Pids.fuelInjectionTiming:
        return PID.fuelInjectionTiming;
      case Pids.fuelRailPressure:
        return PID.fuelRailPressure;
      case Pids.ATRV:
        return PID.atrv;
      default:
        return PID.unknown;
    }
  }

  ObdCommand? get command {
    switch (this) {
      case PID.atrv:
        return BatteryVoltageCommand();
      case PID.odometer:
        return OdometerCommand();
      case PID.engineReferenceTorque:
        return EngineReferenceTorqueCommand();
      case PID.ambientAirTemperature:
        return AmbientAirTemperatureCommand();
      case PID.relativeThrottlePosition:
        return RelativeThrottlePositionCommand();
      case PID.fuelRailGaugePressure:
        return FuelRailGaugePressureCommand();
      case PID.fuelRailPressure:
        return FuelRailPressureCommand();
      case PID.engineFuelRate:
        return EngineFuelRateCommand();
      case PID.engineCoolant:
        return EngineCoolantCommand();
      case PID.engineLoad:
        return EngineLoadCommand();
      case PID.fuelLevel:
        return FuelLevelCommand();
      case PID.intakeAirTemp:
        return IntakeAirTempCommand();
      case PID.maf:
        return MafCommand();
      case PID.oilTemp:
        return OilTempCommand();
      case PID.rpm:
        return RpmCommand();
      case PID.speed:
        return SpeedCommand();
      case PID.throttlePosition:
        return ThrottlePositionCommand();
      case PID.fuelSystemStatus:
        return FuelSystemStatusCommand();
      case PID.commandedAirFuelRatio:
        return CommandedAirFuelRatioCommand();
      case PID.oxygenSensor1A:
        return OxygenSensorTrimVoltsCommand1();
      case PID.oxygenSensor2A:
        return OxygenSensorTrimVoltsCommand2();
      case PID.oxygenSensor3A:
        return OxygenSensorTrimVoltsCommand3();
      case PID.oxygenSensor4A:
        return OxygenSensorTrimVoltsCommand4();
      case PID.oxygenSensor5A:
        return OxygenSensorTrimVoltsCommand5();
      case PID.oxygenSensor6A:
        return OxygenSensorTrimVoltsCommand6();
      case PID.oxygenSensor7A:
        return OxygenSensorTrimVoltsCommand7();
      case PID.oxygenSensor8A:
        return OxygenSensorTrimVoltsCommand8();
      case PID.STFTB1:
        return ShortTermFuelTrimBank1();
      case PID.LTFTB1:
        return LongTermFuelTrimBank1();
      case PID.STFTB2:
        return ShortTermFuelTrimBank2();
      case PID.LTFTB2:
        return LongTermFuelTrimBank2();
      case PID.controlModuleVoltage:
        return ControlModuleVoltageCommand();
      case PID.timingAdvance:
        return TimingAdvanceCommand();
      case PID.commandedEvaporativePurge:
        return CommandedEvaporativePurgeCommand();
      case PID.obdStandards:
        return ObdStandardCommand();
      case PID.distanceTraveledMIL:
        return DistanceWithMILCommand();
      case PID.unknown:
        return null;
      case PID.intakeManifoldAbsolutePressure:
        return MapCommand();
      case PID.fuelPressure:
        return FuelPressureCommand();
      case PID.runTimeSinceStart:
        return RunTimeSinceStartCommand();
      case PID.fuelInjectionTiming:
        return FuelInjectionTime();
      case PID.commandedSecondaryAirStatus:
        return CommandedSecondaryAirStatusCommand();
      case PID.auxiliaryInputStatus:
        return AuxiliaryInputStatus();
      case PID.oxygenSensor1B:
        return OxygenSensorLambdaVoltsCommand1();
      case PID.oxygenSensor2B:
        return OxygenSensorLambdaVoltsCommand2();
      case PID.oxygenSensor3B:
        return OxygenSensorLambdaVoltsCommand3();
      case PID.oxygenSensor4B:
        return OxygenSensorLambdaVoltsCommand4();
      case PID.oxygenSensor5B:
        return OxygenSensorLambdaVoltsCommand5();
      case PID.oxygenSensor6B:
        return OxygenSensorLambdaVoltsCommand6();
      case PID.oxygenSensor7B:
        return OxygenSensorLambdaVoltsCommand7();
      case PID.oxygenSensor8B:
        return OxygenSensorLambdaVoltsCommand8();
      case PID.commandedEGR:
        return CommandedEGRCommand();
      case PID.egrError:
        return EGRErrorCommand();
      case PID.warmUpsSinceCodeCleared:
        return WarmupsSinceCodesClearedCommand();
      case PID.distanceTraveledSinceCodesCleared:
        return DistanceTraveledSinceCodesCleared();
      case PID.evapSystemVaporPressure:
        return EvapSystemVaporPressureCommand();
      case PID.absoluteBarometricPressure:
        return AbsoluteBarometricPressureCommand();
      case PID.oxygenSensor1C:
        return OxygenSensorLambdaCurrentCommand1();
      case PID.oxygenSensor2C:
        return OxygenSensorLambdaCurrentCommand2();
      case PID.oxygenSensor3C:
        return OxygenSensorLambdaCurrentCommand3();
      case PID.oxygenSensor4C:
        return OxygenSensorLambdaCurrentCommand4();
      case PID.oxygenSensor5C:
        return OxygenSensorLambdaCurrentCommand5();
      case PID.oxygenSensor6C:
        return OxygenSensorLambdaCurrentCommand6();
      case PID.oxygenSensor7C:
        return OxygenSensorLambdaCurrentCommand7();
      case PID.oxygenSensor8C:
        return OxygenSensorLambdaCurrentCommand8();
      case PID.catalystTemperatureB1S1:
        return CatalystTemperatureB1S1Command();
      case PID.catalystTemperatureB2S1:
        return CatalystTemperatureB2S1Command();
      case PID.catalystTemperatureB1S2:
        return CatalystTemperatureB1S2Command();
      case PID.catalystTemperatureB2S2:
        return CatalystTemperatureB2S2Command();
      case PID.absoluteLoadValue:
        return AbsoluteLoadValueCommand();
      case PID.absoluteThrottlePositionB:
        return AbsoluteThrottlePositionBCommand();
      case PID.absoluteThrottlePositionC:
        return AbsoluteThrottlePositionCCommand();
      case PID.acceleratorPedalPositionD:
        return AcceleratorPedalPositionDCommand();
      case PID.acceleratorPedalPositionE:
        return AcceleratorPedalPositionECommand();
      case PID.acceleratorPedalPositionF:
        return AcceleratorPedalPositionFCommand();
      case PID.commanededThrottleAcutator:
        return CommandedThrottleActuatorCommand();
      case PID.timeRunWithMIL:
        return TimeRunWithMILOn();
      case PID.timeSinceTroubleCodesCleared:
        return TimeSinceTroublesCodesClearedCommands();
      case PID.hybridBatteryPackRemainingLife:
        return HybridBatteryPackRemainingLife();
      case PID.fuelType:
        return FuelTypeCommand();
      case PID.cylinderFuelRate:
        return CylinderFuelRateCommand();
    }
  }
}

enum SpecialPID {
  pidsList1,
  pidsList2,
  pidsList3,
  pidsList4,
  pidsList5,
  pidsList6,
  pidsList7,
  unknown,
}

extension SpecialPIDExtension on SpecialPID {
  static SpecialPID code(String value) {
    switch (value) {
      case Pids.pidsList1:
        return SpecialPID.pidsList1;
      case Pids.pidsList2:
        return SpecialPID.pidsList2;
      case Pids.pidsList3:
        return SpecialPID.pidsList3;
      case Pids.pidsList4:
        return SpecialPID.pidsList4;
      case Pids.pidsList5:
        return SpecialPID.pidsList5;
      case Pids.pidsList6:
        return SpecialPID.pidsList6;
      case Pids.pidsList7:
        return SpecialPID.pidsList7;
      default:
        return SpecialPID.unknown;
    }
  }
}

const Map<String, String> pidsDescription = {
  '00': 'Pids supported 01-20',
  '01':
      'Monitor status since DTCs cleared. (Includes malfunction indicator lamp (MIL) status and number of DTCs.)',
  '02': 'Freeze DTC',
  '03': 'Fuel system status',
  '04': 'Calculated engine load',
  '05': 'Engine coolant temperature',
  '06': 'Short term fuel trim—Bank 1',
  '07': 'Long term fuel trim—Bank 1',
  '08': 'Short term fuel trim—Bank 2',
  '09': 'Long term fuel trim—Bank 2',
  '0A': 'Fuel pressure (gauge pressure)',
  '0B': 'Intake manifold absolute pressure',
  '0C': 'Engine speed',
  '0D': 'Vehicle speed',
  '0E': 'Timing advance',
  '0F': 'Intake air temperature',
  '10': 'Mass air flow sensor (MAF) air flow rate',
  '11': 'Throttle position',
  '12': 'Commanded secondary air status',
  '13': 'Oxygen sensors present (in 2 banks)',
  '14': 'Oxygen Sensor 1',
  '15': 'Oxygen Sensor 2',
  '16': 'Oxygen Sensor 3',
  '17': 'Oxygen Sensor 4',
  '18': 'Oxygen Sensor 5',
  '19': 'Oxygen Sensor 6',
  '1A': 'Oxygen Sensor 7',
  '1B': 'Oxygen Sensor 8',
  '1C': 'OBD standards this vehicle conforms to',
  '1D': 'Oxygen sensors present (in 4 banks)',
  '1E': 'Auxiliary input status',
  '1F': 'Run time since engine start',
  '20': 'PIDs supported [21 - 40]',
  '21': 'Distance traveled with malfunction indicator lamp (MIL) on',
  '22': 'Fuel Rail Pressure (relative to manifold vacuum)',
  '23': 'Fuel Rail Gauge Pressure (diesel, or gasoline direct injection)',
  '24': 'Oxygen Sensor 1',
  '25': 'Oxygen Sensor 2',
  '26': 'Oxygen Sensor 3',
  '27': 'Oxygen Sensor 4',
  '28': 'Oxygen Sensor 5',
  '29': 'Oxygen Sensor 6',
  '2A': 'Oxygen Sensor 7',
  '2B': 'Oxygen Sensor 8',
  '2C': 'Commanded EGR',
  '2D': 'EGR Error',
  '2E': 'Commanded evaporative purge',
  '2F': 'Fuel Tank Level Input',
  '30': 'Warm-ups since codes cleared',
  '31': 'Distance traveled since codes cleared',
  '32': 'Evap. System Vapor Pressure',
  '33': 'Absolute Barometric Pressure',
  '34': 'Oxygen Sensor 1',
  '35': 'Oxygen Sensor 2',
  '36': 'Oxygen Sensor 3',
  '37': 'Oxygen Sensor 4',
  '38': 'Oxygen Sensor 5',
  '39': 'Oxygen Sensor 6',
  '3A': 'Oxygen Sensor 7',
  '3B': 'Oxygen Sensor 8',
  '3C': 'Catalyst Temperature: Bank 1, Sensor 1',
  '3D': 'Catalyst Temperature: Bank 2, Sensor 1',
  '3E': 'Catalyst Temperature: Bank 1, Sensor 2',
  '3F': 'Catalyst Temperature: Bank 2, Sensor 2',
  '40': 'PIDs supported [41 - 60]',
  '41': 'Monitor status this drive cycle',
  '42': 'Control module voltage',
  '43': 'Absolute load value',
  '44': 'Commanded Air-Fuel Equivalence Ratio (lambda,λ)',
  '45': 'Relative throttle position',
  '46': 'Ambient air temperature',
  '47': 'Absolute throttle position B',
  '48': 'Absolute throttle position C',
  '49': 'Accelerator pedal position D',
  '4A': 'Accelerator pedal position E',
  '4B': 'Accelerator pedal position F',
  '4C': 'Commanded throttle actuator',
  '4D': 'Time run with MIL on',
  '4E': 'Time since trouble codes cleared',
  '4F':
      'Maximum value for Fuel–Air equivalence ratio, oxygen sensor voltage, oxygen sensor current, and intake manifold absolute pressure',
  '50': 'Maximum value for air flow rate from mass air flow sensor',
  '51': 'Fuel Type',
  '52': 'Ethanol fuel %',
  '53': 'Absolute Evap system Vapor Pressure',
  '54': 'Evap system vapor pressure',
  '55': 'Short term secondary oxygen sensor trim, A: bank 1, B: bank 3',
  '56': 'Long term secondary oxygen sensor trim, A: bank 1, B: bank 3',
  '57': 'Short term secondary oxygen sensor trim, A: bank 2, B: bank 4',
  '58': 'Long term secondary oxygen sensor trim, A: bank 2, B: bank 4',
  '59': 'Fuel rail absolute pressure',
  '5A': 'Relative accelerator pedal position',
  '5B': 'Hybrid battery pack remaining life',
  '5C': 'Engine oil temperature',
  '5D': 'Fuel injection timing',
  '5E': 'Engine fuel rate',
  '5F': 'Emission requirements to which vehicle is designed',
  '60': 'PIDs supported [61 - 80]',
  '61': "Driver's demand engine - percent torque",
  '62': 'Actual engine - percent torque',
  '63': 'Engine reference torque',
  '64': 'Engine percent torque data',
  '65': 'Auxiliary input / output supported',
  '66': 'Mass air flow sensor',
  '67': 'Engine coolant temperature',
  '68': 'Intake air temperature sensor',
  '69': 'Actual EGR, Commanded EGR, and EGR Error',
  '6A':
      'Commanded Diesel intake air flow control and relative intake air flow position',
  '6B': 'Exhaust gas recirculation temperature',
  '6C': 'Commanded throttle actuator control and relative throttle position',
  '6D': 'Fuel pressure control system',
  '6E': 'Injection pressure control system',
  '6F': 'Turbocharger compressor inlet pressure',
  '70': 'Boost pressure control',
  '71': 'Variable Geometry turbo (VGT) control',
  '72': 'Wastegate control',
  '73': 'Exhaust pressure',
  '74': 'Turbocharger RPM',
  '75': 'Turbocharger temperature',
  '76': 'Turbocharger temperature',
  '77': 'Charge air cooler temperature (CACT)',
  '78': 'Exhaust Gas temperature (EGT) Bank 1',
  '79': 'Exhaust Gas temperature (EGT) Bank 2',
  '7A': 'Diesel particulate filter (DPF)',
  '7B': 'Diesel particulate filter (DPF)',
  '7C': 'Diesel Particulate filter (DPF) temperature',
  '7D': 'NOx NTE (Not-To-Exceed) control area status',
  '7E': 'PM NTE (Not-To-Exceed) control area status',
  '7F': 'Engine run time [b]',
  '80': 'PIDs supported [81 - A0]',
  '81': 'Engine run time for Auxiliary Emissions Control Device(AECD)',
  '82': 'Engine run time for Auxiliary Emissions Control Device(AECD)',
  '83': 'NOx sensor',
  '84': 'Manifold surface temperature',
  '85': 'NOx reagent system',
  '86': 'Particulate matter (PM) sensor',
  '87': 'Intake manifold absolute pressure',
  '88': 'SCR Induce System',
  '89': 'Run Time for AECD #11-#15',
  '8A': 'Run Time for AECD #16-#20',
  '8B': 'Diesel Aftertreatment',
  '8C': 'O2 Sensor (Wide Range)',
  '8D': 'Throttle Position G',
  '8E': 'Engine Friction - Percent Torque',
  '8F': 'PM Sensor Bank 1 & 2',
  '90': 'WWH-OBD Vehicle OBD System Information',
  '91': 'WWH-OBD Vehicle OBD System Information',
  '92': 'Fuel System Control',
  '93': 'WWH-OBD Vehicle OBD Counters support',
  '94': 'NOx Warning And Inducement System',
  '98': 'Exhaust Gas Temperature Sensor',
  '99': 'Exhaust Gas Temperature Sensor',
  '9A': 'Hybrid/EV Vehicle System Data, Battery, Voltage',
  '9B': 'Diesel Exhaust Fluid Sensor Data',
  '9C': 'O2 Sensor Data',
  '9D': 'Engine Fuel Rate',
  '9E': 'Engine Exhaust Flow Rate',
  '9F': 'Fuel System Percentage Use',
  'A0': 'PIDs supported [A1 - C0]',
  'A1': 'NOx Sensor Corrected Data',
  'A2': 'Cylinder Fuel Rate',
  'A3': 'Evap System Vapor Pressure',
  'A4': 'Transmission Actual Gear',
  'A5': 'Commanded Diesel Exhaust Fluid Dosing',
  'A6': 'Odometer [c]',
  'A7': 'NOx Sensor Concentration Sensors 3 and 4',
  'A8': 'NOx Sensor Corrected Concentration Sensors 3 and 4',
  'A9': 'ABS Disable Switch State',
  'C0': 'PIDs supported [C1 - E0]',
};
