import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smart_car/models/trip_score_model.dart';
import 'package:uuid/uuid.dart';

part 'trip_dataset_model.freezed.dart';
part 'trip_dataset_model.g.dart';

@freezed
class DatasetsDocument with _$DatasetsDocument {
  factory DatasetsDocument({
    required String id,
    String? vin,
    required DateTime createDate,
    @Default([]) List<TripDatasetModel> datasets,
  }) = _DatasetsDocument;

  factory DatasetsDocument.fromJson(Map<String, dynamic> json) =>
      _$DatasetsDocumentFromJson(json);
}

@freezed
class TripDatasetModel with _$TripDatasetModel {
  factory TripDatasetModel({
    required String id,
    @Default(0) double fuelConsumption,
    @Default(0) double distance,
    @Default(0) double distanceGPStoDistance,
    @Default(0) double idleTimeShare, // eko drive
    @Default(0) double driveTimeShare, // eko drive
    @Default(0) double startsPerKm, // eko drive
    @Default(0) double idleFuelShare, // eko drive
    @Default(0) double savedFuelShare, // eko drive
    @Default(0) double leftTurnsPerKm,
    @Default(0) double rightTurnsPerKm,
    @Default(0) double overRPMTimeShare, // płynność
    @Default(0) double underRPMTimeShare, // płynność
    @Default(0) double accelerationsPerKm, // płynność
    @Default(0) double highGforcePerKm, // płynność
    @Default(0) double accDeccPerKm, // płynność
    @Default(-1) double ecoScore, // eko
    @Default(-1) double smoothScore, // płynność
  }) = _TripDatasetModel;

  factory TripDatasetModel.fromJson(Map<String, dynamic> json) =>
      _$TripDatasetModelFromJson(json);
}

extension TripDatasetModelExtension on TripDatasetModel {
  bool get isReadyToLearn => ecoScore >= 0 && smoothScore >= 0;

  List<dynamic> get toEcoRow => [
        idleTimeShare,
        driveTimeShare,
        startsPerKm,
        idleFuelShare,
        savedFuelShare,
        ecoScore,
      ];

  static List<String> get ecoRowHeaders => [
        'idle_time_share',
        'drive_time_share',
        'starts_per_km',
        'idle_fuel_share',
        'saved_fuel_share',
        'eco_score',
      ];

  List<dynamic> get toSmoothRow => [
        overRPMTimeShare,
        underRPMTimeShare,
        accelerationsPerKm,
        highGforcePerKm,
        accDeccPerKm,
        smoothScore,
      ];

  static List<String> get smoothRowHeaders => [
        'over_rpm_time_share',
        'under_rpm_time_share',
        'accelerations_per_km',
        'high_gforce_per_km',
        'acc_decc_per_km',
        'smooth_score',
      ];

  static TripDatasetModel fromTripScoreModel(TripScoreModel scoreModel) {
    final driveSeconds = scoreModel.tripSeconds - scoreModel.idleTripSeconds;
    final _totalTurns = scoreModel.leftTurns + scoreModel.rightTurns;
    final totalTurns = _totalTurns == 0 ? 1 : _totalTurns;
    return TripDatasetModel(
      id: const Uuid().v1(),
      distance: scoreModel.distance,
      fuelConsumption: scoreModel.avgFuelConsumption,
      accDeccPerKm: scoreModel.accDecc / scoreModel.distance,
      accelerationsPerKm: scoreModel.rapidAccelerations / scoreModel.distance,
      distanceGPStoDistance: scoreModel.gpsDistance / scoreModel.distance,
      highGforcePerKm: scoreModel.hightGforce / scoreModel.distance,
      driveTimeShare: driveSeconds / scoreModel.tripSeconds,
      idleFuelShare: scoreModel.idleFuel / scoreModel.fuelUsed,
      idleTimeShare: scoreModel.idleTripSeconds / scoreModel.tripSeconds,
      leftTurnsPerKm: scoreModel.leftTurns / totalTurns,
      rightTurnsPerKm: scoreModel.rightTurns / totalTurns,
      overRPMTimeShare: scoreModel.overRPMDriveTime / scoreModel.tripSeconds,
      underRPMTimeShare: scoreModel.underRPMDriveTime / scoreModel.tripSeconds,
      savedFuelShare: scoreModel.savedFuel / scoreModel.fuelUsed,
      startsPerKm: scoreModel.starts / scoreModel.distance,
    );
  }

  String get formattedPrint {
    const encoder = JsonEncoder.withIndent('    ');
    return encoder.convert(toJson());
  }
}
