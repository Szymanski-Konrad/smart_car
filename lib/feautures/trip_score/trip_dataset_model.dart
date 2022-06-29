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
    @Default(0) double leftTurnsPerKm, // płynność
    @Default(0) double rightTurnsPerKm, // płynność
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
        toValidValue(idleTimeShare),
        toValidValue(driveTimeShare),
        toValidValue(startsPerKm),
        toValidValue(idleFuelShare),
        toValidValue(savedFuelShare),
        toValidValue(ecoScore),
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
        toValidValue(overRPMTimeShare),
        toValidValue(underRPMTimeShare),
        toValidValue(accelerationsPerKm),
        toValidValue(highGforcePerKm),
        toValidValue(accDeccPerKm),
        toValidValue(smoothScore),
      ];

  static List<String> get smoothRowHeaders => [
        'over_rpm_time_share',
        'under_rpm_time_share',
        'accelerations_per_km',
        'high_gforce_per_km',
        'acc_decc_per_km',
        'smooth_score',
      ];

  double toValidValue(double value) {
    return (value.isInfinite || value.isNaN) ? 0.0 : value;
  }

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

  bool isSame(TripDatasetModel dataset) {
    return dataset.idleTimeShare == idleTimeShare &&
        driveTimeShare == dataset.driveTimeShare &&
        startsPerKm == dataset.startsPerKm &&
        idleFuelShare == dataset.idleFuelShare &&
        savedFuelShare == dataset.savedFuelShare &&
        leftTurnsPerKm == dataset.leftTurnsPerKm &&
        rightTurnsPerKm == dataset.rightTurnsPerKm &&
        overRPMTimeShare == dataset.overRPMTimeShare &&
        underRPMTimeShare == dataset.underRPMTimeShare &&
        accelerationsPerKm == dataset.accelerationsPerKm &&
        highGforcePerKm == dataset.highGforcePerKm &&
        accDeccPerKm == dataset.accDeccPerKm;
  }

  List<String> get rawDataFormatted {
    return [
      '                                    -- -- -- --        Eco part        -- -- -- -- --',
      'Spalanie: ${fuelConsumption.toStringAsFixed(2)} l/100km',
      'Dystans: ${distance.toStringAsFixed(1)} km',
      'Idle time share: ${(idleTimeShare * 100).toStringAsFixed(2)} %',
      'Drive time share: ${(driveTimeShare * 100).toStringAsFixed(2)} %',
      'Ilość startów na km: ${startsPerKm.toStringAsFixed(3)}',
      'Idle fuel share: ${(idleFuelShare * 100).toStringAsFixed(2)} %',
      'Saved fuel share: ${(savedFuelShare * 100).toStringAsFixed(2)} %',
      '                                     -- -- -- -- --        Smooth part       -- -- -- --',
      'Skręty w lewo na km: ${leftTurnsPerKm.toStringAsFixed(3)}',
      'Skręty w prawo na km:  ${rightTurnsPerKm.toStringAsFixed(3)}',
      'Over RPM time share: ${(overRPMTimeShare * 100).toStringAsFixed(2)} %',
      'Under RPM time share: ${(underRPMTimeShare * 100).toStringAsFixed(2)} %',
      'Przyspieszenia na km: ${accelerationsPerKm.toStringAsFixed(3)}',
      'Przeciążenia na km: ${highGforcePerKm.toStringAsFixed(3)}',
      'Przysp -> Hamowanie na km: ${accDeccPerKm.toStringAsFixed(3)}',
      'Eco score: ${ecoScore.toStringAsFixed(1)}',
      'Smooth score: ${smoothScore.toStringAsFixed(1)}',
    ];
  }
}
