import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smart_car/app/resources/constants.dart';
import 'package:smart_car/pages/live_data/bloc/live_data_state.dart';
import 'package:smart_car/pages/live_data/model/fuel_system_status_command.dart';
import 'package:smart_car/utils/date_extension.dart';
import 'package:smart_car/utils/info_tile_data.dart';

part 'trip_record.freezed.dart';

@freezed
class TripRecord with _$TripRecord {
  factory TripRecord({
    @Default(-1.0) double startFuelLvl,
    @Default(-1.0) double currentFuelLvl,
    @Default(0.0) double distance,
    @Default(-1.0) double instFuelConsumption,
    @Default(-1.0) double averageFuelConsumption,
    @Default(0.0) double kmPerL,
    @Default(0.0) double usedFuel,
    @Default(0.0) double idleUsedFuel,
    @Default(0.0) double savedFuel,
    @Default(-1.0) double gpsSpeed,
    @Default(0.0) double gpsDistance,
    @Default(-1) int currentSpeed,
    @Default(0.0) double averageSpeed,
    @Default(-1.0) double range,
    @Default(55.0) double tankSize,
    @Default(0) int tripSeconds,
    @Default(0) int idleTripSeconds,
    @Default(0) double fuelCosts,
    @Default(TripStatus.idle) TripStatus tripStatus,
    @Default({}) Map<String, DateTime> updateTime,
    @Default(0) int currentDriveInterval,
    @Default(0.0) double currentDriveIntervalFuel,

    // Rapid driving
    @Default(0) int rapidAccelerations,
    @Default(0) int rapidBreakings,
    @Default(0) int lastAccelerationTime,
    @Default(0) int lastBreakingTime,
    @Default(0.0) double engineLoad,
  }) = _TripRecord;
}

extension TripRecordExtension on TripRecord {
  TripRecord updateFuelLvl(double value) {
    final initial = startFuelLvl < 0 ? value : startFuelLvl;
    return copyWith(startFuelLvl: initial, currentFuelLvl: value);
  }

  int get totalTripSeconds => tripSeconds + idleTripSeconds;

  TripRecord updateDistance(double value, int speed) {
    final currDistance = distance + value;
    return copyWith(
      distance: currDistance,
      currentSpeed: speed,
    );
  }

  TripRecord updateTripStatus(TripStatus status) {
    final driveInterval =
        status != tripStatus && status != TripStatus.savingFuel
            ? 0
            : currentDriveInterval;
    return copyWith(
      tripStatus: status,
      currentDriveInterval: driveInterval,
    );
  }

  TripRecord updateEngineLoad(double value) {
    return copyWith(engineLoad: value);
  }

  TripRecord updateRange() {
    if (averageFuelConsumption > 0 && currentFuelLvl > 0 && tankSize > 0) {
      final range = (tankSize * currentFuelLvl) / averageFuelConsumption;
      return copyWith(range: range);
    }
    return this;
  }

  TripRecord updateUsedFuel(
    double value,
    num speed,
    FuelSystemStatus fuelStatus,
    double fuelPrice,
  ) {
    if (speed > 0) {
      if (fuelStatus == FuelSystemStatus.fuelCut) {
        return copyWith(savedFuel: savedFuel + value);
      } else {
        return copyWith(
          usedFuel: usedFuel + value,
          fuelCosts: (usedFuel + idleUsedFuel) * fuelPrice,
        );
      }
    } else {
      return copyWith(
        idleUsedFuel: idleUsedFuel + value,
        fuelCosts: (usedFuel + idleUsedFuel) * fuelPrice,
      );
    }
  }

  TripRecord updateSeconds(num speed) {
    return copyWith(
      tripSeconds: tripSeconds + (speed > 0 ? 1 : 0),
      idleTripSeconds: idleTripSeconds + (speed > 0 ? 0 : 1),
      currentDriveInterval: currentDriveInterval + 1,
      averageSpeed: distance / ((totalTripSeconds + 1) / 3600),
    );
  }

  TripRecord updateRapidAcceleration({required double acceleration}) {
    final secondsSinceEpoch = DateTime.now().secondsSinceEpoch;
    final seconds = secondsSinceEpoch - lastAccelerationTime;

    if (seconds < Constants.minRapidSpeedTimeThreshold) return this;
    if (acceleration > Constants.rapidAcceleration) {
      return copyWith(
        rapidAccelerations: rapidAccelerations + 1,
        lastAccelerationTime: secondsSinceEpoch,
      );
    }
    if (acceleration < Constants.rapidBreaking) {
      return copyWith(
        rapidBreakings: rapidBreakings + 1,
        lastBreakingTime: secondsSinceEpoch,
      );
    }

    return this;
  }

  List<FuelTileData> get fuelUsedSection => [
        usedFuelDetails,
        idleUsedFuelDetails,
        savedFuelDetails,
      ];

  List<OtherTileData> get fuelSection => [
        avgFuelDetails,
        instFuelDetails,
        fuelCostsDetails,
      ];

  List<OtherTileData> get carboSection => [
        carboPerKmDetails,
        producedCarboDetails,
        savedCarboDetails,
      ];

  List<TimeTileData> get timeSection => [
        totalTripTimeDetails,
        driveTimeDetails,
        idleTripTimeDetails,
      ];

  List<OtherTileData> get tripSection => [
        avgSpeedDetails,
        distanceDetails,
        rangeDetails,
        gpsDistanceDetails,
        gpsSpeedDetails,
        rapidAccelerationsDetails,
        rapidBrakingDetails,
      ];

  OtherTileData get fuelCostsDetails => OtherTileData(
        value: fuelCosts,
        title: 'Fuel costs',
        unit: 'PLN',
        digits: 2,
      );

  FuelTileData get savedFuelDetails {
    return FuelTileData(
      value: savedFuel,
      title: 'Saved fuel',
      unit: 'l',
      digits: 3,
      tripStatus: TripStatus.savingFuel,
    );
  }

  FuelTileData get usedFuelDetails => FuelTileData(
        value: usedFuel,
        title: 'Used fuel',
        unit: 'l',
        digits: 2,
        tripStatus: TripStatus.driving,
      );

  FuelTileData get idleUsedFuelDetails => FuelTileData(
        value: idleUsedFuel,
        title: 'Idle used fuel',
        unit: 'l',
        digits: 3,
        tripStatus: TripStatus.idle,
      );

  OtherTileData get distanceDetails => OtherTileData(
        value: distance,
        title: 'Distance',
        unit: 'km',
        digits: 1,
      );

  OtherTileData get instFuelDetails => OtherTileData(
        value: instFuelConsumption,
        title: 'Inst Fuel cons.',
        unit: 'l/100km',
        digits: 1,
      );

  OtherTileData get avgFuelDetails => OtherTileData(
        value: averageFuelConsumption,
        title: 'Avg fuel cons.',
        unit: 'l/100km',
        digits: 1,
      );

  OtherTileData get avgKmPerL => OtherTileData(
        value: 100 / averageFuelConsumption,
        title: 'Avg fuel cons.',
        unit: 'km/l',
        digits: 1,
      );

  OtherTileData get instKmPerL => OtherTileData(
        value: kmPerL,
        title: 'Inst fuel cons.',
        unit: 'km/l',
        digits: 1,
      );

  OtherTileData get rangeDetails => OtherTileData(
        value: range,
        title: 'Range',
        unit: 'km',
        digits: 0,
      );

  OtherTileData get gpsSpeedDetails => OtherTileData(
        value: gpsSpeed,
        title: 'GPS Speed',
        unit: 'km/h',
        digits: 1,
      );

  OtherTileData get gpsDistanceDetails => OtherTileData(
        value: gpsDistance,
        title: 'GPS Distance',
        unit: 'km',
        digits: 1,
      );

  TimeTileData get totalTripTimeDetails => TimeTileData(
        value: Duration(seconds: totalTripSeconds),
        digits: 0,
        title: 'Total duration',
        unit: '',
        isCurrent: false,
      );

  TimeTileData get driveTimeDetails => TimeTileData(
        value: Duration(seconds: tripSeconds),
        digits: 0,
        title: 'Drive duration',
        unit: '',
        isCurrent: tripStatus != TripStatus.idle,
      );

  TimeTileData get idleTripTimeDetails => TimeTileData(
        value: Duration(seconds: idleTripSeconds),
        digits: 0,
        title: 'Idle duration',
        unit: '',
        isCurrent: tripStatus == TripStatus.idle,
      );

  OtherTileData get avgSpeedDetails => OtherTileData(
        value: averageSpeed,
        title: 'Avg. speed',
        unit: 'km/h',
        digits: 1,
      );

  OtherTileData get rapidAccelerationsDetails => OtherTileData(
        value: rapidAccelerations,
        digits: 0,
        title: 'Acc.',
        unit: '',
      );

  OtherTileData get rapidBrakingDetails => OtherTileData(
        value: rapidBreakings,
        digits: 0,
        title: 'Braking',
        unit: '',
      );

  OtherTileData get producedCarboDetails => OtherTileData(
        value: (usedFuel + idleUsedFuel) *
            0.75 *
            0.87 *
            Constants.co2GenerationRatio,
        digits: 2,
        title: 'Burnt CO2',
        unit: 'kg',
      );

  OtherTileData get savedCarboDetails => OtherTileData(
        value: savedFuel * 0.75 * 0.87 * Constants.co2GenerationRatio,
        digits: 2,
        title: 'Saved CO2',
        unit: 'kg',
      );

  OtherTileData get carboPerKmDetails => OtherTileData(
        value: (averageFuelConsumption / 100) *
            0.75 *
            0.87 *
            Constants.co2GenerationRatio *
            1000,
        digits: 0,
        title: 'avg CO2',
        unit: 'g/km',
      );
}
