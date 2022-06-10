import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';

part 'trip_score_model.freezed.dart';

@freezed
class TripScoreModel with _$TripScoreModel {
  factory TripScoreModel({
    @Default(0) double distance,
    @Default(0) double gpsDistance,
    @Default(0) double avgSpeed,
    @Default(0) double startFuelLvl,
    @Default(0) double endFuelLvl,
    @Default(0) double fuelPrice,
    @Default(0) double tankSize,
    @Default(0) int tripSeconds,
    @Default(0) int idleTripSeconds,
    required DateTime startTripTime,
    required DateTime endTripTime,
    LatLng? startLocation,
    LatLng? endLocation,
    @Default([]) List<double> accelerations,
    @Default(0) double cumulativeAltitude,
    @Default(0) int starts,
    @Default(0) int accDecc,

    // Eco parameters
    @Default(0) double avgFuelConsumption,
    @Default(0) double fuelUsed,
    @Default(0) double savedFuel,
    @Default(0) double idleFuel,
    @Default(0) double driveFuel,
    @Default(0) int overRPMDriveTime,
    @Default(0) int underRPMDriveTime,
    @Default(0) int rapidAccelerations,
    @Default(0) int rapidBreakings,
    @Default(0) int leftTurns,
    @Default(0) int rightTurns,
    @Default(0) int hightGforce,
  }) = _TripScoreModel;
}

extension TripScoreModelExtension on TripScoreModel {
  TripScoreModel diff(TripScoreModel other) {
    final _fuelUsed = fuelUsed - other.fuelUsed;
    final _distance = distance - other.distance;
    final _avgFuelConsumption =
        _fuelUsed * 100 / (_distance > 0 ? _distance : 1);
    final _time = DateTime.now().difference(other.endTripTime);
    final _avgSpeed = _distance / (_time.inSeconds / 3600);
    return TripScoreModel(
      startTripTime: other.endTripTime,
      endTripTime: DateTime.now(),
      accDecc: accDecc - other.accDecc,
      accelerations: accelerations,
      avgFuelConsumption: _avgFuelConsumption,
      avgSpeed: _avgSpeed,
      cumulativeAltitude: cumulativeAltitude - other.cumulativeAltitude,
      distance: _distance,
      driveFuel: driveFuel - other.driveFuel,
      endFuelLvl: endFuelLvl,
      startFuelLvl: other.endFuelLvl,
      endLocation: endLocation,
      startLocation: other.endLocation,
      fuelPrice: fuelPrice,
      fuelUsed: _fuelUsed,
      gpsDistance: gpsDistance - other.gpsDistance,
      hightGforce: hightGforce - other.hightGforce,
      idleFuel: idleFuel - other.idleFuel,
      idleTripSeconds: idleTripSeconds - other.idleTripSeconds,
      leftTurns: leftTurns - other.leftTurns,
      overRPMDriveTime: overRPMDriveTime - other.overRPMDriveTime,
      rapidAccelerations: rapidAccelerations - other.rapidAccelerations,
      rapidBreakings: rapidBreakings - other.rapidBreakings,
      rightTurns: rightTurns - other.rightTurns,
      savedFuel: savedFuel - other.savedFuel,
      starts: starts - other.starts,
      tankSize: tankSize,
      tripSeconds: tripSeconds - other.tripSeconds,
      underRPMDriveTime: underRPMDriveTime - other.underRPMDriveTime,
    );
  }
}
