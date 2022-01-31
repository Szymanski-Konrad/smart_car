import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smart_car/app/resources/pids.dart';
import 'package:smart_car/pages/live_data/model/commands/pids_checker.dart';
import 'package:smart_car/pages/live_data/model/fuel_system_status_command.dart';
import 'package:smart_car/pages/live_data/model/trip_record.dart';

part 'live_data_state.freezed.dart';

enum TripStatus { idle, driving, savingFuel }

@freezed
class LiveDataState with _$LiveDataState {
  factory LiveDataState({
    // Live data
    @Default(false) bool isRunning,
    required DateTime tripStart,
    @Default(0) int tripSeconds,
    required TripRecord tripRecord,
    Position? lastPosition,
    @Default(false) bool isLocalMode,
    @Default(0) double acceleration,
    @Default(false) bool throttlePressed,
    @Default(0) int currentTimeSpent,
    @Default(0) double currentFuelBurnt,
    @Default(TripStatus.idle) TripStatus tripStatus,

    // Just for testing
    @Default(0.0) double localTripProgress,

    // Bluetooth
    @Default(true) bool isConnecting,
    @Default(false) bool isDisconnecting,
    @Default(false) bool isConnnectingError,

    // Pids
    @Default([]) List<String> supportedPids,
    required PidsChecker pidsChecker,
    @Default('') String vin,
    @Default(FuelSystemStatus.motorOff) FuelSystemStatus fuelSystemStatus,

    // Sensors
    @Default('') String userAccelerometer,
    @Default(0.0) double temperature,
    @Default(false) bool isTemperatureAvaliable,

    // Errors
    @Default([]) List<String> errors,
  }) = _LiveDataState;

  static LiveDataState init({List<String> pids = const []}) {
    return LiveDataState(
      tripStart: DateTime.now(),
      tripRecord: TripRecord(),
      pidsChecker: PidsChecker(),
      supportedPids: pids,
      isConnecting: false,
      isDisconnecting: false,
    );
  }
}

extension LiveDataStateExtension on LiveDataState {
  LiveDataState clear() {
    return LiveDataState(
      tripStart: DateTime.now(),
      tripRecord: TripRecord(),
      pidsChecker: PidsChecker(),
      supportedPids: supportedPids,
      isTemperatureAvaliable: isTemperatureAvaliable,
    );
  }

  LiveDataState localMode() {
    return LiveDataState(
      tripStart: DateTime.now(),
      tripRecord: TripRecord(),
      pidsChecker: PidsChecker(),
      supportedPids: supportedPids,
      isTemperatureAvaliable: isTemperatureAvaliable,
      isLocalMode: true,
    );
  }

  LiveDataState updateSupportedPidsPart(String value) {
    String code = value.substring(value.length - 2);
    switch (code) {
      case Pids.pidsList1:
        return copyWith(pidsChecker: pidsChecker.firstPidsSupported);
      case Pids.pidsList2:
        return copyWith(pidsChecker: pidsChecker.secondPidsSupported);
      case Pids.pidsList3:
        return copyWith(pidsChecker: pidsChecker.thirdPidsSupported);
      case Pids.pidsList4:
        return copyWith(pidsChecker: pidsChecker.fourthPidsSupported);
      case Pids.pidsList5:
        return copyWith(pidsChecker: pidsChecker.fifthPidsSupported);
      case Pids.pidsList6:
        return copyWith(pidsChecker: pidsChecker.sixthPidsSupported);
      default:
        throw ArgumentError('Value is not supported: $value');
    }
  }

  LiveDataState updateReadedPidsPart(String value) {
    String code = value.substring(value.length - 2);
    switch (code) {
      case Pids.pidsList1:
        return copyWith(pidsChecker: pidsChecker.firstPidsReaded);
      case Pids.pidsList2:
        return copyWith(pidsChecker: pidsChecker.secondPidsReaded);
      case Pids.pidsList3:
        return copyWith(pidsChecker: pidsChecker.thirdPidsReaded);
      case Pids.pidsList4:
        return copyWith(pidsChecker: pidsChecker.fourthPidsReaded);
      case Pids.pidsList5:
        return copyWith(pidsChecker: pidsChecker.fifthPidsReaded);
      case Pids.pidsList6:
        return copyWith(pidsChecker: pidsChecker.sixthPidsReaded);
      default:
        throw ArgumentError('Value is not supported: $value');
    }
  }

  String get nextReadPidsPart {
    if (shouldRead1_20) return '01' + Pids.pidsList1;
    if (shouldRead21_40) return '01' + Pids.pidsList2;
    if (shouldRead41_60) return '01' + Pids.pidsList3;
    if (shouldRead61_80) return '01' + Pids.pidsList4;
    if (shouldRead81_A0) return '01' + Pids.pidsList5;
    if (shouldReadA1_C0) return '01' + Pids.pidsList6;
    return '';
  }

  bool get shouldRead1_20 =>
      pidsChecker.pidsSupported1_20 && !pidsChecker.pidsReaded1_20;
  bool get shouldRead21_40 =>
      pidsChecker.pidsSupported21_40 && !pidsChecker.pidsReaded21_40;
  bool get shouldRead41_60 =>
      pidsChecker.pidsSupported41_60 && !pidsChecker.pidsReaded41_60;
  bool get shouldRead61_80 =>
      pidsChecker.pidsSupported61_80 && !pidsChecker.pidsReaded61_80;
  bool get shouldRead81_A0 =>
      pidsChecker.pidsSupported81_A0 && !pidsChecker.pidsReaded81_A0;
  bool get shouldReadA1_C0 =>
      pidsChecker.pidsSupportedA1_C0 && !pidsChecker.pidsReadedA1_C0;

  String get getTemperature => temperature.toStringAsFixed(1);
}
