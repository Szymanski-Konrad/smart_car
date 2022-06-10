import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smart_car/app/blocs/global_bloc.dart';
import 'package:smart_car/models/trip_score_model.dart';
import 'package:uuid/uuid.dart';

part 'trip_dataset_model.freezed.dart';
part 'trip_dataset_model.g.dart';

@freezed
class TripDatasetModel with _$TripDatasetModel {
  factory TripDatasetModel({
    required String id,
    String? vin,
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
    @Default(0) double overRPMTimeShare, // agresywność
    @Default(0) double underRPMTimeShare, // agresywność
    @Default(0) double accelerationsPerKm, // agresywność
    @Default(0) double highGforcePerKm, // agresywność
    @Default(0) double accDeccPerKm, // agresywność
    @Default(-1) double ecoScore,
    @Default(-1) double aggresiveScore,
  }) = _TripDatasetModel;

  factory TripDatasetModel.fromJson(Map<String, dynamic> json) =>
      _$TripDatasetModelFromJson(json);
}

extension TripDatasetModelExtension on TripDatasetModel {
  static TripDatasetModel fromTripScoreModel(TripScoreModel scoreModel) {
    final driveSeconds = scoreModel.tripSeconds - scoreModel.idleTripSeconds;
    final _totalTurns = scoreModel.leftTurns + scoreModel.rightTurns;
    final totalTurns = _totalTurns == 0 ? 1 : _totalTurns;
    return TripDatasetModel(
      id: const Uuid().v1(),
      vin: GlobalBlocs.settings.state.settings.vin,
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
    final encoder = JsonEncoder.withIndent('    ');
    return encoder.convert(toJson());
  }
}
