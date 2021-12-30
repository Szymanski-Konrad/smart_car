import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smart_car/app/resources/constants.dart';
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

  TripRecord updateDistance(double value, int speed) {
    final currDistance = distance + value;
    return copyWith(
      distance: currDistance,
      averageSpeed: currDistance / (tripSeconds / 3600),
      currentSpeed: speed,
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
      double value, num speed, FuelSystemStatus fuelStatus) {
    if (speed > 0) {
      if (fuelStatus == FuelSystemStatus.fuelCut) {
        return copyWith(savedFuel: savedFuel + value);
      } else {
        return copyWith(usedFuel: usedFuel + value);
      }
    } else {
      return copyWith(idleUsedFuel: idleUsedFuel + value);
    }
  }

  TripRecord updateSeconds(num speed) {
    if (speed > 0) {
      return copyWith(tripSeconds: tripSeconds + 1);
    } else {
      return copyWith(idleTripSeconds: idleTripSeconds + 1);
    }
  }

  TripRecord updateRapidAcceleration({required bool isPositive}) {
    final secondsSinceEpoch = DateTime.now().secondsSinceEpoch;
    if (isPositive) {
      final duration =
          Duration(seconds: secondsSinceEpoch - lastAccelerationTime);
      if (secondsSinceEpoch - lastAccelerationTime >
          Constants.minTimeBetweenRapidSpeedChange) {
        return copyWith(
          rapidAccelerations: rapidAccelerations + 1,
          lastAccelerationTime: secondsSinceEpoch,
        );
      }
    } else {
      final duration = Duration(seconds: secondsSinceEpoch - lastBreakingTime);
      if (secondsSinceEpoch - lastBreakingTime >
          Constants.minTimeBetweenRapidSpeedChange) {
        return copyWith(
          rapidBreakings: rapidBreakings + 1,
          lastBreakingTime: secondsSinceEpoch,
        );
      }
    }

    return this;
  }

  List<InfoTileData> get fuelSection => [
        avgFuelDetails,
        percentFuelConsDetails,
        instFuelDetails,
        usedFuelDetails,
        idleUsedFuelDetails,
        savedFuelDetails,
      ];

  List<InfoTileData> get timeSection => [
        tripTimeDetails,
        idleTripTimeDetails,
        rapidAccelerationsDetails,
        rapidBrakingDetails,
      ];

  List<InfoTileData> get tripSection => [
        avgSpeedDetails,
        distanceDetails,
        rangeDetails,
        gpsSpeedDetails,
        gpsDistanceDetails,
      ];

  InfoTileData get percentFuelConsDetails => InfoTileData(
        value: averageFuelConsumption / 7.444,
        title: '% of expected',
        unit: '%',
        digits: 2,
      );

  InfoTileData get savedFuelDetails => InfoTileData(
        value: savedFuel,
        title: 'Saved fuel',
        unit: 'l',
        digits: 2,
      );

  InfoTileData get distanceDetails => InfoTileData(
        value: distance,
        title: 'Distance',
        unit: 'km',
        digits: 1,
      );
  InfoTileData get instFuelDetails => InfoTileData(
        value: instFuelConsumption,
        title: 'Fuel cons.',
        unit: 'l/100km',
        digits: 1,
      );
  InfoTileData get avgFuelDetails => InfoTileData(
        value: averageFuelConsumption,
        title: 'Avg fuel cons.',
        unit: 'l/100km',
        digits: 1,
      );
  InfoTileData get rangeDetails => InfoTileData(
        value: range,
        title: 'Range',
        unit: 'km',
        digits: 0,
      );
  InfoTileData get usedFuelDetails => InfoTileData(
        value: usedFuel,
        title: 'Used fuel',
        unit: 'l',
        digits: 2,
      );
  InfoTileData get idleUsedFuelDetails => InfoTileData(
        value: idleUsedFuel,
        title: 'Idle used fuel',
        unit: 'l',
        digits: 2,
      );
  InfoTileData get gpsSpeedDetails => InfoTileData(
        value: gpsSpeed,
        title: 'GPS Speed',
        unit: 'km/h',
        digits: 1,
      );
  InfoTileData get gpsDistanceDetails => InfoTileData(
        value: gpsDistance,
        title: 'GPS Distance',
        unit: 'km',
        digits: 1,
      );
  InfoTileData get tripTimeDetails => InfoTileData(
        value: Duration(seconds: tripSeconds),
        digits: 0,
        title: 'Duration',
        unit: '',
      );
  InfoTileData get idleTripTimeDetails => InfoTileData(
        value: Duration(seconds: idleTripSeconds),
        digits: 0,
        title: 'Idle duration',
        unit: '',
      );
  InfoTileData get avgSpeedDetails => InfoTileData(
        value: averageSpeed,
        title: 'Avg. speed',
        unit: 'km/h',
        digits: 1,
      );
  InfoTileData get rapidAccelerationsDetails => InfoTileData(
        value: rapidAccelerations,
        digits: 0,
        title: 'Rapid acc.',
        unit: '',
      );
  InfoTileData get rapidBrakingDetails => InfoTileData(
        value: rapidBreakings,
        digits: 0,
        title: 'Rapid braking',
        unit: '',
      );
}
