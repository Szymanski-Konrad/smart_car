import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smart_car/app/resources/constants.dart';
import 'package:smart_car/app/resources/strings.dart';
import 'package:smart_car/pages/live_data/bloc/live_data_state.dart';
import 'package:smart_car/pages/live_data/model/fuel_system_status_command.dart';
import 'package:smart_car/utils/date_extension.dart';
import 'package:smart_car/utils/fuel_helper.dart';
import 'package:smart_car/utils/info_tile_data.dart';

part 'trip_record.freezed.dart';

enum TripDataType {
  rapidAcceleration,
  rapidBraking,
  leftTurns,
  rightTurns,
  highGForce,
}

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
    @Default(0.0) double tankSize,
    @Default(0) double fuelPrice,

    // Gps
    @Default(-1.0) double gpsSpeed,
    @Default(0.0) double gpsDistance,
    @Default(0.0) double altitudeCumulative,

    // Time
    required DateTime startTripDate,
    @Default(0) int tripSeconds,
    @Default(0) int idleTripSeconds,
    @Default(0) int currentDriveInterval,
    @Default(0) int overRPMDriveTime,
    @Default(0) int underRPMDriveTime,
    @Default({}) Map<TripDataType, int> updateTime,

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
    @Default(0) int starts,
    // Rapid accelerations and decelariations in short time
    @Default(0) int accDecc,
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

  TripRecord updateTripStatus(num speed, num rpm, TripStatus? status) {
    final isStart =
        tripStatus == TripStatus.idle && status == TripStatus.driving;
    final _speed = speed.isNaN ? 0 : speed;
    final _rpm = rpm.isNaN ? 0 : rpm;
    final isDrive = _speed > Constants.idleSpeedLimit;
    final overRPM = _rpm > Constants.upperRPMLimit;
    final underRPM = _rpm < Constants.lowerRPMLimit;
    final isSameStatus = _isSameStatus(status);
    return copyWith(
      tripStatus: status ?? tripStatus,
      starts: isStart ? starts + 1 : starts,
      tripSeconds: tripSeconds + (isDrive ? 1 : 0),
      idleTripSeconds: idleTripSeconds + (isDrive ? 0 : 1),
      currentDriveInterval: isSameStatus ? currentDriveInterval + 1 : 1,
      overRPMDriveTime: overRPMDriveTime + (isDrive && overRPM ? 1 : 0),
      underRPMDriveTime: underRPMDriveTime + (isDrive && underRPM ? 1 : 0),
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
    final lastTime = Map<TripDataType, int>.from(updateTime);
    lastTime[TripDataType.highGForce] = DateTime.now().secondsSinceEpoch;
    return copyWith(highGforce: highGforce + 1, updateTime: lastTime);
  }

  TripRecord updateTurning(bool isLeft) {
    final lastTime = Map<TripDataType, int>.from(updateTime);
    if (isLeft) {
      lastTime[TripDataType.leftTurns] = DateTime.now().secondsSinceEpoch;
      return copyWith(
        leftTurns: leftTurns + 1,
        updateTime: lastTime,
      );
    }
    lastTime[TripDataType.rightTurns] = DateTime.now().secondsSinceEpoch;
    return copyWith(
      rightTurns: rightTurns + 1,
      updateTime: lastTime,
    );
  }

  TripRecord updateRapidAcceleration({required double acceleration}) {
    final secondsSinceEpoch = DateTime.now().secondsSinceEpoch;
    final seconds = secondsSinceEpoch - lastAccelerationTime;
    if (seconds < Constants.minRapidSpeedTimeThreshold) return this;
    final lastTime = Map<TripDataType, int>.from(updateTime);
    if (acceleration > Constants.rapidAcceleration) {
      lastTime[TripDataType.rapidAcceleration] =
          DateTime.now().secondsSinceEpoch;
      return copyWith(
        rapidAccelerations: rapidAccelerations + 1,
        lastAccelerationTime: secondsSinceEpoch,
        updateTime: lastTime,
      );
    }
    if (acceleration < Constants.rapidBreaking) {
      final lastAccTime = lastTime[TripDataType.rapidAcceleration];
      final _accDecc = lastAccTime != null &&
              DateTime.now().secondsSinceEpoch - lastAccTime >
                  Constants.minAccDeccTimeThreshold
          ? accDecc + 1
          : accDecc;
      lastTime[TripDataType.rapidBraking] = DateTime.now().secondsSinceEpoch;
      return copyWith(
        rapidBreakings: rapidBreakings + 1,
        lastBreakingTime: secondsSinceEpoch,
        updateTime: lastTime,
        accDecc: _accDecc,
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
        overRPMTimeDetails,
        underRPMTimeDetails,
      ];

  List<OtherTileData> get otherInfoSection => [
        avgFuelPerHDetails,
        avgFuelDetails,
        instFuelDetails,
        rangeDetails,
        avgSpeedDetails,
        currSpeedDetails,
        gpsSpeedDetails,
        gpsDistanceDetails,
        altitudeCumulativeDetails,
        distanceDetails,
        tankDifferenceDetails,
        fuelCostsDetails,
        carboPerKmDetails,
        producedCarboDetails,
        savedCarboDetails,
      ];

  List<OtherTileData> get countersSection => [
        highGForceDetails,
        turnsDetails,
        rapidSpeedDetails,
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

  TimeTileData get overRPMTimeDetails => TimeTileData(
        value: Duration(seconds: overRPMDriveTime),
        digits: 0,
        title: Strings.overRPMDuration,
        unit: '',
        isCurrent: false,
      );

  TimeTileData get underRPMTimeDetails => TimeTileData(
        value: Duration(seconds: underRPMDriveTime),
        digits: 0,
        title: Strings.underRPMDuration,
        unit: '',
        isCurrent: false,
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

  OtherTileData get rapidSpeedDetails => OtherTileData(
        value: '$rapidAccelerations/$rapidBreakings',
        digits: 0,
        title: Strings.rapidSpeed,
        unit: '',
        tripDataType: [
          TripDataType.rapidAcceleration,
          TripDataType.rapidBraking
        ],
      );

  OtherTileData get turnsDetails => OtherTileData(
        value: '$leftTurns/$rightTurns',
        digits: 0,
        title: Strings.turns,
        unit: '',
        tripDataType: [TripDataType.leftTurns, TripDataType.rightTurns],
      );

  OtherTileData get highGForceDetails => OtherTileData(
        value: highGforce,
        digits: 0,
        title: Strings.gForce,
        unit: '',
        tripDataType: [TripDataType.highGForce],
      );

  OtherTileData get producedCarboDetails => OtherTileData(
        value: FuelHelper.co2EmissionInKg(totalFuelUsed),
        digits: 2,
        title: Strings.burntCO2,
        unit: 'kg',
      );

  OtherTileData get savedCarboDetails => OtherTileData(
        value: FuelHelper.co2EmissionInKg(savedFuel),
        digits: 2,
        title: Strings.savedCO2,
        unit: 'kg',
      );

  OtherTileData get carboPerKmDetails => OtherTileData(
        value: FuelHelper.co2EmissionInGrams(avgFuelConsumption) / 100,
        digits: 0,
        title: Strings.averageCO2,
        unit: 'g/km',
      );

  OtherTileData get altitudeCumulativeDetails => OtherTileData(
        value: altitudeCumulative,
        digits: 1,
        title: 'Całk. wysokość',
        unit: 'm',
      );
}
