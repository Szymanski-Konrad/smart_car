import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';
import 'package:smart_car/models/fuel_logs/fuel_log.dart';
import 'package:smart_car/models/gas_stations/gas_station.dart';
import 'package:smart_car/utils/date_extension.dart';
import 'package:uuid/uuid.dart';

part 'create_fuel_log_state.freezed.dart';

enum OdometerInputType { total, diff }

@freezed
class CreateFuelLogState with _$CreateFuelLogState {
  const factory CreateFuelLogState({
    required String fuelLogId,
    @Default(OdometerInputType.diff) OdometerInputType odometerInputType,
    required double currentOdometer,
    @Default(0.0) double odometer,
    @Default(0.0) double distance,
    required double fuelPrice,
    @Default(0.0) double fuelAmount,
    required DateTime date,
    required TimeOfDay time,
    @Default(true) bool isFullTank,
    @Default(false) bool isRemainingFuelKnown,
    @Default(FuelStationType.pb95) FuelStationType fuelType,
    @Default(false) bool isEditMode,
    @Default(false) bool isSaving,

    // For localization
    @Default(false) bool isStationsLoading,
    LatLng? coordinates,
    @Default([]) List<GasStation> nearGasStations,
    GasStation? selectedGasStation,
  }) = _CreateFuelLogState;
}

extension CreateFuelLogStateExtension on CreateFuelLogState {
  static CreateFuelLogState toEdit(FuelLog fuelLog) => CreateFuelLogState(
        fuelLogId: fuelLog.id,
        currentOdometer: fuelLog.odometer,
        distance: fuelLog.distance,
        fuelPrice: fuelLog.fuelPrice,
        date: fuelLog.logDate,
        time: TimeOfDay.fromDateTime(fuelLog.logDate),
        coordinates: fuelLog.location,
        fuelAmount: fuelLog.fuelAmount,
        isFullTank: fuelLog.isFull,
        odometer: fuelLog.distance,
        odometerInputType: OdometerInputType.diff,
        fuelType: fuelLog.fuelType,
        isEditMode: true,
        isRemainingFuelKnown: fuelLog.isRemainingFuelKnown,
      );

  static CreateFuelLogState initial({
    required double fuelPrice,
    required double odometer,
  }) =>
      CreateFuelLogState(
        fuelLogId: const Uuid().v1(),
        currentOdometer: odometer,
        fuelPrice: fuelPrice,
        date: DateTime.now(),
        time: TimeOfDay.now(),
      );

  double get newDistance => odometerInputType == OdometerInputType.total
      ? odometer - currentOdometer
      : distance;
  double get newOdometer => odometerInputType == OdometerInputType.total
      ? odometer
      : currentOdometer + distance;

  double get fuelConsumption => fuelAmount * 100 / newDistance;
  double get totalCost => fuelAmount * fuelPrice;
  String get fuelCons => '${fuelConsumption.toStringAsFixed(2)}  l/100km';

  String get dateDesc => date.toDateFormat;
  String get timeDesc =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  bool get isDistanceMode => odometerInputType == OdometerInputType.diff;

  bool get isCorrect => newOdometer > currentOdometer && fuelAmount > 0;
}
