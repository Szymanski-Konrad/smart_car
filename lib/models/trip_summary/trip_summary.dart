// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';
import 'package:smart_car/utils/date_extension.dart';
import 'package:smart_car/utils/location_helper.dart';
import 'package:smart_car/utils/useful_functions.dart';

part 'trip_summary.freezed.dart';
part 'trip_summary.g.dart';

@freezed
class TripSummary with _$TripSummary {
  factory TripSummary({
    required String id,
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
    @Default(0) int tripSeconds,
    @Default(0) int idleTripSeconds,
    @Default(0) int rapidAccelerations,
    @Default(0) int rapidBreakings,
    @Default(0) int leftTurns,
    @Default(0) int rightTurns,
    @Default(0) int hightGforce,
    required DateTime startTripTime,
    required DateTime endTripTime,
    double? tankSize,
    @JsonKey(toJson: LocationHelper.tryCoordsToJson) LatLng? startLocation,
    @JsonKey(toJson: LocationHelper.tryCoordsToJson) LatLng? endLocation,
  }) = _TripSummary;

  factory TripSummary.fromJson(Map<String, dynamic> json) =>
      _$TripSummaryFromJson(json);
}

extension TripSummaryExtension on TripSummary {
  int get driveTime => tripSeconds - idleTripSeconds;
  double get producedCarbo => Functions.fuelToCarboKg(idleFuel + driveFuel);
  double get savedCarbo => Functions.fuelToCarboKg(savedFuel);

  String get producedCarboFormat =>
      '${producedCarbo.toStringAsFixed(2)} kg (produced)';
  String get savedCarboFormat => '${savedCarbo.toStringAsFixed(2)} kg (saved)';
  String get toStartDateTimeFormat =>
      '${startTripTime.toDateFormat} ${startTripTime.toTimeFormat}';
  String get toEndDateTimeFormat =>
      '${endTripTime.toDateFormat} ${endTripTime.toTimeFormat}';
  String get dateTimeFormat => '$toStartDateTimeFormat\n$toEndDateTimeFormat';
  String get avgFuelConsumptionFormat =>
      '${avgFuelConsumption.toStringAsFixed(2)} l/100km';
  String get avgSpeedFormat => '${avgSpeed.toStringAsFixed(1)} km/h';
  String get distanceFormat => '${distance.toStringAsFixed(1)} km';
  String get fuelPriceFormat => '${fuelPrice.toStringAsFixed(2)} zł';
  String get fuelUsedFormat => '${fuelUsed.toStringAsFixed(1)} l';
  String get fuelLevelFormat =>
      '${startFuelLvl.toStringAsFixed(2)}% -> ${endFuelLvl.toStringAsFixed(2)}%';
  String get driveTimeFormat =>
      Duration(seconds: driveTime).toString().substring(0, 7);
  String get idleTimeFormat =>
      Duration(seconds: idleTripSeconds).toString().substring(0, 7);
  String get totalTimeFormat =>
      Duration(seconds: tripSeconds).toString().substring(0, 7);
}

extension TripsSummaryExtension on List<TripSummary> {
  // total
  double get totalDistance =>
      fold(0, (previous, element) => previous + element.distance);
  double get totalFuel =>
      fold(0, (previous, element) => previous + element.fuelUsed);
  double get totalFuelSaved =>
      fold(0, (previous, element) => previous + element.savedFuel);
  int get totalSeconds =>
      fold(0, (previous, element) => previous + element.tripSeconds);
  double get totalCarboProduced =>
      fold(0, (previous, element) => previous + element.producedCarbo);
  double get totalCarboSaved =>
      fold(0, (previous, element) => previous + element.savedCarbo);

  String totalDistanceFormatted() => '${totalDistance.toStringAsFixed(0)} km';
  String totalFuelFormatted() => '${totalFuel.toStringAsFixed(2)} l';
  String totalCarboProducedFormatted() =>
      '${totalCarboProduced.toStringAsFixed(2)} kg (produced)';
  String totalCarboSavedFormatted() =>
      '${totalCarboSaved.toStringAsFixed(2)} kg (saved)';

  // average
  double get avgDistance => totalDistance / length;
  double get avgSpeed => totalDistance / (totalSeconds / 3600);
  double get avgConsumption => totalFuel * 100 / totalDistance;

  String averageDistanceFormatted() => '${avgDistance.toStringAsFixed(0)} km';
  String averageSpeedFormatted() => '${avgSpeed.toStringAsFixed(2)} km/h';
  String consumptionFormatted() =>
      '${avgConsumption.toStringAsFixed(2)} l/100km';
}
