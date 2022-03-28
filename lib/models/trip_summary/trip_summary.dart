// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';
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
    @JsonKey(toJson: LocationHelper.coordsToJson) LatLng? startLocation,
    @JsonKey(toJson: LocationHelper.coordsToJson) LatLng? endLocation,
  }) = _TripSummary;

  factory TripSummary.fromJson(Map<String, dynamic> json) =>
      _$TripSummaryFromJson(json);
}
