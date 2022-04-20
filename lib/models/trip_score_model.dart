import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';

part 'trip_score_model.freezed.dart';

@freezed
class TripScoreModel with _$TripScoreModel {
  factory TripScoreModel({
    @Default(0) double distance,
    @Default(0) double gpsDistance,
    @Default(0) double avgSpeed,
    @Default(0) double fuelUsed,
    @Default(0) double startFuelLvl,
    @Default(0) double endFuelLvl,
    @Default(0) double fuelPrice,
    @Default(0) double avgFuelConsumption,
    @Default(0) double savedFuel,
    @Default(0) double idleFuel,
    @Default(0) double driveFuel,
    @Default(0) double tankSize,
    @Default(0) int tripSeconds,
    @Default(0) int idleTripSeconds,
    @Default(0) int rapidAccelerations,
    @Default(0) int rapidBreakings,
    @Default(0) int leftTurns,
    @Default(0) int rightTurns,
    @Default(0) int hightGforce,
    required DateTime startTripTime,
    required DateTime endTripTime,
    LatLng? startLocation,
    LatLng? endLocation,
  }) = _TripScoreModel;
}
