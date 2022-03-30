// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';
import 'package:smart_car/utils/date_extension.dart';
import 'package:smart_car/utils/location_helper.dart';

part 'trip_summary.freezed.dart';
part 'trip_summary.g.dart';

@freezed
class TripSummary with _$TripSummary {
  factory TripSummary({
    required String id,
    required double distance,
    required double gpsDistance,
    required double avgSpeed,
    required double fuelUsed,
    required int tripSeconds,
    required int idleTripSeconds,
    required int rapidAccelerations,
    required int rapidBreakings,
    required double startFuelLvl,
    required double endFuelLvl,
    required double fuelPrice,
    required double avgFuelConsumption,
    required double savedFuel,
    required double idleFuel,
    required double driveFuel,
    required DateTime startTripTime,
    required DateTime endTripTime,
    @JsonKey(toJson: LocationHelper.tryCoordsToJson) LatLng? startLocation,
    @JsonKey(toJson: LocationHelper.tryCoordsToJson) LatLng? endLocation,
  }) = _TripSummary;

  factory TripSummary.fromJson(Map<String, dynamic> json) =>
      _$TripSummaryFromJson(json);
}

extension TripSummaryExtension on TripSummary {
  int get driveTime => tripSeconds - idleTripSeconds;
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

  String totalDistanceFormatted() => '${totalDistance.toStringAsFixed(0)} km';
  String totalFuelFormatted() => '${totalFuel.toStringAsFixed(2)} l';

  // average
  double get avgDistance => totalDistance / length;
  double get avgSpeed => totalDistance / (totalSeconds / 3600);
  double get avgConsumption => totalFuel * 100 / totalDistance;

  String averageDistanceFormatted() => '${avgDistance.toStringAsFixed(0)} km';
  String averageSpeedFormatted() => '${avgSpeed.toStringAsFixed(2)} km/h';
  String consumptionFormatted() =>
      '${avgConsumption.toStringAsFixed(2)} l/100km';
}
