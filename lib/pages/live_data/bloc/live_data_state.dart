import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:smart_car/app/blocs/global_bloc.dart';
import 'package:smart_car/app/resources/constants.dart';
import 'package:smart_car/app/resources/pids.dart';
import 'package:smart_car/app/resources/strings.dart';
import 'package:smart_car/feautures/trip_score/trip_dataset_model.dart';
import 'package:smart_car/models/trip_score_model.dart';
import 'package:smart_car/pages/live_data/model/commands/pids_checker.dart';
import 'package:smart_car/pages/live_data/model/fuel_system_status_command.dart';
import 'package:smart_car/pages/live_data/model/trip_record.dart';
import 'package:smart_car/utils/info_tile_data.dart';
import 'package:smart_car/utils/location_helper.dart';
import 'package:uuid/uuid.dart';

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
    LocationData? firstLocation,
    LocationData? lastLocation,
    @Default(false) bool isLocalMode,
    @Default(0) double fuelPrice,
    @Default(0) double score,
    double? previousScore,
    @Default([]) List<double> acceleration,
    String? vin,
    required DatasetsDocument datasets,

    // GPS
    @Default(0) double direction,
    @Default(0) double locationSlope,
    @Default(0) double locationHeight,
    @Default(0) double tripAltitudeCumulation,
    @Default([]) List<LatLng> gpsPoints,

    // Just for testing
    @Default(0.0) double localTripProgress,
    @Default(Constants.defaultLocalFile) String localData,
    @Default('') String lastReceivedData,

    // Bluetooth
    @Default(false) bool isRunning,
    @Default(true) bool isConnecting,
    @Default(false) bool isDisconnecting,
    @Default(false) bool isConnnectingError,
    @Default(false) bool isTripEnded,
    @Default(false) bool isTripClosing,
    @Default(false) bool alreadyAskedForFueling,

    // Pids
    @Default([]) List<String> supportedPids,
    required PidsChecker pidsChecker,
    @Default(FuelSystemStatus.motorOff) FuelSystemStatus fuelSystemStatus,
    @Default(0) int averageResponseTime,
    @Default(0) int totalResponseTime,

    // Sensors
    @Default(0) double xAccData,
    @Default(0) double yAccData,
    @Default(0) double zAccData,
    @Default(0) double xGyroData,
    @Default(0) double yGyroData,
    @Default(0) double zGyroData,
    @Default(0) double gForce,
    @Default(false) bool isTemperatureAvaliable,
    @Default(0.0) double temperature,
    @Default(false) bool isTurning,
    @Default(false) bool isHighGforce,
    @Default(0) double previousBarometer,
    @Default(0) double barometerSlope,
    @Default(0) double cumulativeBarometerHeightDiff,

    // Errors
    @Default([]) List<String> errors,
  }) = _LiveDataState;

  static LiveDataState init({
    List<String> pids = const [],
    String? localFile,
    required double fuelPrice,
    required double tankSize,
  }) {
    return LiveDataState(
      datasets: DatasetsDocument(
        id: const Uuid().v1(),
        createDate: DateTime.now(),
        vin: GlobalBlocs.settings.state.settings.vin,
      ),
      tripRecord: TripRecord(
        fuelPrice: fuelPrice,
        tankSize: tankSize,
        startTripDate: DateTime.now(),
      ),
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
  TripScoreModel toTripScoreModel() {
    return TripScoreModel(
      startTripTime: tripRecord.startTripDate,
      endTripTime: DateTime.now(),
      distance: tripRecord.distance,
      gpsDistance: tripRecord.gpsDistance,
      avgSpeed: tripRecord.averageSpeed,
      fuelUsed: tripRecord.usedFuel,
      tripSeconds: tripRecord.tripSeconds,
      idleTripSeconds: tripRecord.idleTripSeconds,
      rapidAccelerations: tripRecord.rapidAccelerations,
      rapidBreakings: tripRecord.rapidBreakings,
      startFuelLvl: tripRecord.startFuelLvl,
      endFuelLvl: tripRecord.currentFuelLvl,
      fuelPrice: fuelPrice,
      avgFuelConsumption: tripRecord.avgFuelConsumption,
      savedFuel: tripRecord.savedFuel,
      idleFuel: tripRecord.idleUsedFuel,
      driveFuel: tripRecord.usedFuel,
      startLocation: firstLocation?.toLatLng,
      endLocation: lastLocation?.toLatLng,
      hightGforce: tripRecord.highGforce,
      leftTurns: tripRecord.leftTurns,
      rightTurns: tripRecord.rightTurns,
      tankSize: tripRecord.tankSize,
      overRPMDriveTime: tripRecord.overRPMDriveTime,
      underRPMDriveTime: tripRecord.underRPMDriveTime,
      accelerations: acceleration,
      cumulativeAltitude: tripAltitudeCumulation,
      starts: tripRecord.starts,
    );
  }

  LiveDataState clear() {
    return LiveDataState(
      tripRecord:
          TripRecord(fuelPrice: fuelPrice, startTripDate: DateTime.now()),
      datasets: DatasetsDocument(
        id: const Uuid().v1(),
        createDate: DateTime.now(),
        vin: GlobalBlocs.settings.state.settings.vin,
      ),
      pidsChecker: PidsChecker(),
      supportedPids: supportedPids,
      isTemperatureAvaliable: isTemperatureAvaliable,
      localData: localData,
      fuelPrice: fuelPrice,
    );
  }

  LiveDataState localMode() {
    return LiveDataState(
      tripRecord:
          TripRecord(fuelPrice: fuelPrice, startTripDate: DateTime.now()),
      datasets: DatasetsDocument(
        id: const Uuid().v1(),
        createDate: DateTime.now(),
        vin: GlobalBlocs.settings.state.settings.vin,
      ),
      pidsChecker: PidsChecker(),
      supportedPids: supportedPids,
      isTemperatureAvaliable: isTemperatureAvaliable,
      isLocalMode: true,
      localData: localData,
      fuelPrice: fuelPrice,
    );
  }

  LiveDataState addDataset(TripDatasetModel model) {
    final list = List<TripDatasetModel>.from(datasets.datasets);
    list.add(model);
    final dataset = datasets.copyWith(datasets: list);
    return copyWith(datasets: dataset);
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

  OtherTileData get scoreData => OtherTileData(
        digits: 0,
        unit: '',
        title: 'Ocena jazdy',
        value: score,
      );

  OtherTileData get directionData => OtherTileData(
        digits: 1,
        unit: '',
        title: 'Kierunek ($directionString)',
        value: direction,
      );

  OtherTileData get locationHeightData => OtherTileData(
        digits: 2,
        unit: 'm',
        title: 'Wysokość',
        value: locationHeight,
      );

  OtherTileData get locationSlopeData => OtherTileData(
        digits: 1,
        unit: '%',
        title: 'Nachylenie',
        value: locationSlope.abs(),
      );

  OtherTileData get gForceData => OtherTileData(
        digits: 1,
        unit: 'g',
        title: Strings.gForce,
        value: gForce,
        color: gForceColor,
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
  double get driveDirection => -yGyroData * Constants.radToDegree;

  Color get gForceColor {
    if (gForce > 1.3) return Colors.red;
    if (gForce > 1.2) return Colors.orange;
    if (gForce > 1.1) return Colors.yellow;
    return Colors.green;
  }

  String get directionString {
    if (direction == 0 || direction == 360) return 'N';
    if (direction > 0 && direction < 90) return 'NE';
    if (direction == 90) return 'E';
    if (direction > 90 && direction < 180) return 'SE';
    if (direction == 180) return 'S';
    if (direction > 180 && direction < 270) return 'SW';
    if (direction == 270) return 'W';
    if (direction > 270 && direction < 360) return 'NW';
    return '-.-';
  }
}
