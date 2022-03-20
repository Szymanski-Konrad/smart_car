import 'dart:math';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:location/location.dart';
import 'package:smart_car/app/resources/constants.dart';
import 'package:smart_car/app/resources/pids.dart';
import 'package:smart_car/app/resources/strings.dart';
import 'package:smart_car/pages/live_data/model/commands/pids_checker.dart';
import 'package:smart_car/pages/live_data/model/fuel_system_status_command.dart';
import 'package:smart_car/pages/live_data/model/trip_record.dart';
import 'package:smart_car/utils/info_tile_data.dart';

part 'live_data_state.freezed.dart';

enum TripStatus { idle, driving, savingFuel }

extension TripStatusExtension on TripStatus {
  bool get isDriving =>
      [TripStatus.driving, TripStatus.savingFuel].contains(this);
}

class ReceivedData {
  ReceivedData({
    required this.data,
    required this.command,
    required this.splitted,
  });

  final List<int> data;
  final String command;
  final List<String> splitted;
}

@freezed
class LiveDataState with _$LiveDataState {
  factory LiveDataState({
    // Live data
    required TripRecord tripRecord,
    LocationData? lastLocation,
    // @Default(TripStatus.idle) TripStatus tripStatus,
    @Default(false) bool isLocalMode,
    @Default(0) double fuelPrice,

    // GPS
    @Default(0) double direction,
    @Default(0) double locationSlope,
    @Default(0) double locationHeight,

    // Just for testing
    @Default(0.0) double localTripProgress,
    @Default(Constants.defaultLocalFile) String localData,

    // Bluetooth
    @Default(false) bool isRunning,
    @Default(true) bool isConnecting,
    @Default(false) bool isDisconnecting,
    @Default(false) bool isConnnectingError,
    @Default(false) bool isTripEnded,
    @Default(false) bool isTripClosing,

    // Pids
    @Default([]) List<String> supportedPids,
    required PidsChecker pidsChecker,
    @Default('') String vin,
    @Default(FuelSystemStatus.motorOff) FuelSystemStatus fuelSystemStatus,
    @Default(0) int averageResponseTime,
    @Default(0) int totalResponseTime,

    // Sensors
    @Default(0) double xAccelerometer,
    @Default(0) double yAccelerometer,
    @Default(0) double zAccelerometer,
    @Default(false) bool isTemperatureAvaliable,
    @Default(false) bool isBarometrAvaliable,
    @Default(0.0) double temperature,

    // Errors
    @Default([]) List<String> errors,
  }) = _LiveDataState;

  static LiveDataState init({
    List<String> pids = const [],
    String? localFile,
    required double fuelPrice,
  }) {
    return LiveDataState(
      tripRecord: TripRecord(fuelPrice: fuelPrice),
      pidsChecker: PidsChecker(),
      supportedPids: pids,
      isConnecting: false,
      isDisconnecting: false,
      localData: localFile ?? Constants.defaultLocalFile,
      fuelPrice: fuelPrice,
    );
  }
}

extension LiveDataStateExtension on LiveDataState {
  LiveDataState clear() {
    return LiveDataState(
      tripRecord: TripRecord(fuelPrice: fuelPrice),
      pidsChecker: PidsChecker(),
      supportedPids: supportedPids,
      isTemperatureAvaliable: isTemperatureAvaliable,
      localData: localData,
      fuelPrice: fuelPrice,
    );
  }

  LiveDataState localMode() {
    return LiveDataState(
      tripRecord: TripRecord(fuelPrice: fuelPrice),
      pidsChecker: PidsChecker(),
      supportedPids: supportedPids,
      isTemperatureAvaliable: isTemperatureAvaliable,
      isLocalMode: true,
      localData: localData,
      fuelPrice: fuelPrice,
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

  OtherTileData get directionData => OtherTileData(
        digits: 1,
        unit: '',
        title: 'Kierunek',
        value: direction,
      );

  OtherTileData get locationHeightData => OtherTileData(
        digits: 2,
        unit: 'm',
        title: 'Wysokość',
        value: locationHeight,
      );

  OtherTileData get locationSlopeData => OtherTileData(
        digits: 2,
        unit: '%',
        title: 'Nachylenie',
        value: locationSlope,
      );

  OtherTileData get gForceData => OtherTileData(
        digits: 2,
        unit: 'g',
        title: Strings.gForce,
        value: gForce,
      );

  OtherTileData get indoorTempData => OtherTileData(
        digits: 1,
        unit: '°C',
        title: Strings.indoorTemp,
        value: temperature,
      );

  OtherTileData get fuelStatusData => OtherTileData(
        digits: 0,
        unit: '',
        title: Strings.fuelSystemStatus,
        value: fuelSystemStatus.description,
        iconData: fuelSystemStatus.icon,
      );

  String get getTemperature => temperature.toStringAsFixed(1);

  double get _accelerationSum =>
      (pow(xAccelerometer, 2) + pow(yAccelerometer, 2) + pow(zAccelerometer, 2))
          .toDouble();

  double get gForce => sqrt(_accelerationSum) / 9.8;
}
