import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smart_car/app/resources/constants.dart';
import 'package:smart_car/app/resources/strings.dart';
import 'package:smart_car/pages/live_data/bloc/live_data_state.dart';
import 'package:smart_car/pages/live_data/model/fuel_system_status_command.dart';
import 'package:smart_car/utils/date_extension.dart';
import 'package:smart_car/utils/info_tile_data.dart';
import 'package:smart_car/utils/useful_functions.dart';

part 'trip_record.freezed.dart';

@freezed
class TripRecord with _$TripRecord {
  factory TripRecord({
    // Fuel info
    @Default(-1.0) double startFuelLvl,
    @Default(-1.0) double currentFuelLvl,
    @Default(-1.0) double instFuelConsumption,
    @Default(0.0) double usedFuel,
    @Default(0.0) double idleUsedFuel,
    @Default(0.0) double savedFuel,
    @Default(55.0) double tankSize,
    @Default(0) double fuelPrice,

    // Gps
    @Default(-1.0) double gpsSpeed,
    @Default(0.0) double gpsDistance,

    // Time
    required DateTime startTripDate,
    @Default(0) int tripSeconds,
    @Default(0) int idleTripSeconds,
    @Default(0) int currentDriveInterval,
    @Default(0.0) double currentDriveIntervalFuel,
    @Default({}) Map<String, DateTime> updateTime,

    // Distance & speed
    @Default(0.0) double distance,
    @Default(-1.0) double range,
    @Default(-1) int currentSpeed,
    @Default(TripStatus.idle) TripStatus tripStatus,

    // Rapid driving
    @Default(0) int rapidAccelerations,
    @Default(0) int rapidBreakings,
    @Default(0) int lastAccelerationTime,
    @Default(0) int lastBreakingTime,
    @Default(0) int leftTurns,
    @Default(0) int rightTurns,
    @Default(0) int highGforce,
  }) = _TripRecord;
}

extension TripRecordExtension on TripRecord {
  int get totalTripSeconds => tripSeconds + idleTripSeconds;
  double get totalFuelUsed => usedFuel + idleUsedFuel;
  double get avgFuelConsumption {
    if (totalFuelUsed == 0) return -1.0;
    if (distance == 0) return 100 * totalFuelUsed;
    return 100 * totalFuelUsed / distance;
  }

  double get drivingHours => totalTripSeconds / 3600;
  double get avgFuelPerH => totalFuelUsed / drivingHours;

  double get fuelCosts => totalFuelUsed * fuelPrice;
  double get averageSpeed => distance / (totalTripSeconds / 3600);
  double get range {
    if (tankSize == 0) return -1;
    return (tankSize * currentFuelLvl) / avgFuelConsumption;
  }

  TripRecord updateFuelLvl(double value) {
    final initial = startFuelLvl < 0 ? value : startFuelLvl;
    return copyWith(startFuelLvl: initial, currentFuelLvl: value);
  }

  TripRecord updateDistance(double value, int speed) {
    return copyWith(
      distance: distance + value,
      currentSpeed: speed,
    );
  }

  bool _isSameStatus(TripStatus? status) {
    if (status == null) return true;
    if (status == tripStatus) return true;
    if (status.isDriving && tripStatus.isDriving) return true;
    return false;
  }

  TripRecord updateTripStatus(num speed, TripStatus? status) {
    final _speed = speed.isNaN ? 0 : speed;
    final isSameStatus = _isSameStatus(status);
    return copyWith(
      tripStatus: status ?? tripStatus,
      tripSeconds: tripSeconds + (_speed > Constants.idleSpeedLimit ? 1 : 0),
      idleTripSeconds:
          idleTripSeconds + (_speed > Constants.idleSpeedLimit ? 0 : 1),
      currentDriveInterval: isSameStatus ? currentDriveInterval + 1 : 1,
    );
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
        );
      }
    } else {
      return copyWith(
        idleUsedFuel: idleUsedFuel + value,
      );
    }
  }

  TripRecord updateHighGForce() {
    return copyWith(highGforce: highGforce + 1);
  }

  TripRecord updateTurning(bool isLeft) {
    if (isLeft) return copyWith(leftTurns: leftTurns + 1);
    return copyWith(rightTurns: rightTurns + 1);
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

  List<TimeTileData> get timeSection => [
        totalTripTimeDetails,
        driveTimeDetails,
        idleTripTimeDetails,
      ];

  List<OtherTileData> get otherInfoSection => [
        highGForceDetails,
        leftTurnsDetails,
        rightTurnsDetails,
        tankDifferenceDetails,
        avgFuelPerHDetails,
        avgFuelDetails,
        instFuelDetails,
        avgSpeedDetails,
        currSpeedDetails,
        gpsSpeedDetails,
        gpsDistanceDetails,
        distanceDetails,
        rangeDetails,
        fuelCostsDetails,
        rapidAccelerationsDetails,
        rapidBrakingDetails,
        carboPerKmDetails,
        producedCarboDetails,
        savedCarboDetails,
      ];

  OtherTileData get fuelCostsDetails => OtherTileData(
        value: fuelCosts,
        title: Strings.fuelCosts,
        unit: 'PLN',
        digits: 1,
      );

  FuelTileData get savedFuelDetails => FuelTileData(
        value: savedFuel,
        title: Strings.savedFuel,
        unit: 'l',
        digits: 3,
        tripStatus: TripStatus.savingFuel,
      );

  FuelTileData get usedFuelDetails => FuelTileData(
        value: usedFuel,
        title: Strings.usedFuel,
        unit: 'l',
        digits: 2,
        tripStatus: TripStatus.driving,
      );

  FuelTileData get idleUsedFuelDetails => FuelTileData(
        value: idleUsedFuel,
        title: Strings.idleUsedFuel,
        unit: 'l',
        digits: 3,
        tripStatus: TripStatus.idle,
      );

  OtherTileData get tankDifferenceDetails => OtherTileData(
        value: (startFuelLvl - currentFuelLvl) * tankSize / 100,
        digits: 3,
        title: 'Bak',
        unit: 'l',
      );

  OtherTileData get distanceDetails => OtherTileData(
        value: distance,
        title: Strings.distance,
        unit: 'km',
        digits: 1,
      );

  OtherTileData get instFuelDetails => OtherTileData(
        value: tripStatus == TripStatus.savingFuel ? 0.0 : instFuelConsumption,
        title: Strings.instantFuelConsumption,
        unit: currentSpeed > 0 ? 'l/100km' : 'l/h',
        digits: 1,
      );

  OtherTileData get avgFuelDetails => OtherTileData(
        value: avgFuelConsumption,
        title: Strings.averageFuelConsumption,
        unit: distance > 0 ? 'l/100km' : 'l/h',
        digits: 1,
      );

  OtherTileData get avgFuelPerHDetails => OtherTileData(
        value: avgFuelPerH,
        title: Strings.averageFuelConsumption,
        unit: 'l/h',
        digits: 1,
      );

  OtherTileData get rangeDetails => OtherTileData(
        value: range,
        title: Strings.range,
        unit: 'km',
        digits: 0,
      );

  OtherTileData get gpsSpeedDetails => OtherTileData(
        value: gpsSpeed,
        title: Strings.gpsSpeed,
        unit: 'km/h',
        digits: 1,
      );

  OtherTileData get gpsDistanceDetails => OtherTileData(
        value: gpsDistance,
        title: Strings.gpsDistance,
        unit: 'km',
        digits: 1,
      );

  TimeTileData get totalTripTimeDetails => TimeTileData(
        value: Duration(seconds: totalTripSeconds),
        digits: 0,
        title: Strings.totalDuration,
        unit: '',
        isCurrent: false,
      );

  TimeTileData get driveTimeDetails => TimeTileData(
        value: Duration(seconds: tripSeconds),
        digits: 0,
        title: Strings.driveDuration,
        unit: '',
        isCurrent: tripStatus != TripStatus.idle,
      );

  TimeTileData get idleTripTimeDetails => TimeTileData(
        value: Duration(seconds: idleTripSeconds),
        digits: 0,
        title: Strings.idleDuration,
        unit: '',
        isCurrent: tripStatus == TripStatus.idle,
      );

  OtherTileData get avgSpeedDetails => OtherTileData(
        value: averageSpeed,
        title: Strings.averageSpeed,
        unit: 'km/h',
        digits: 1,
      );

  OtherTileData get currSpeedDetails => OtherTileData(
        value: currentSpeed,
        title: 'Prędkość',
        unit: 'km/h',
        digits: 1,
      );

  OtherTileData get rapidAccelerationsDetails => OtherTileData(
        value: rapidAccelerations,
        digits: 0,
        title: Strings.rapidAcceleration,
        unit: '',
      );

  OtherTileData get rapidBrakingDetails => OtherTileData(
        value: rapidBreakings,
        digits: 0,
        title: Strings.rapidBraking,
        unit: '',
      );

  OtherTileData get leftTurnsDetails => OtherTileData(
        value: leftTurns,
        digits: 0,
        title: Strings.leftTurns,
        unit: '',
      );

  OtherTileData get rightTurnsDetails => OtherTileData(
        value: rightTurns,
        digits: 0,
        title: Strings.rightTurns,
        unit: '',
      );

  OtherTileData get highGForceDetails => OtherTileData(
        value: highGforce,
        digits: 0,
        title: Strings.gForce,
        unit: '',
      );

  OtherTileData get producedCarboDetails => OtherTileData(
        value: Functions.fuelToCarboKg(totalFuelUsed),
        digits: 2,
        title: Strings.burntCO2,
        unit: 'kg',
      );

  OtherTileData get savedCarboDetails => OtherTileData(
        value: Functions.fuelToCarboKg(savedFuel),
        digits: 2,
        title: Strings.savedCO2,
        unit: 'kg',
      );

  OtherTileData get carboPerKmDetails => OtherTileData(
        value: Functions.fuelToCarboGrams(avgFuelConsumption) / 100,
        digits: 0,
        title: Strings.averageCO2,
        unit: 'g/km',
      );
}
