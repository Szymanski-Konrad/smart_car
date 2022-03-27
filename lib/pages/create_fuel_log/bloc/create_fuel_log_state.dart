import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';
import 'package:smart_car/models/fuel_logs/fuel_log.dart';
import 'package:smart_car/models/gas_stations/gas_station.dart';
import 'package:smart_car/utils/date_extension.dart';

part 'create_fuel_log_state.freezed.dart';

enum OdometerInputType { total, diff }

@freezed
class CreateFuelLogState with _$CreateFuelLogState {
  const factory CreateFuelLogState({
    @Default(OdometerInputType.diff) OdometerInputType odometerInputType,
    required double currentOdometer,
    @Default(0.0) double odometer,
    required double fuelPrice,
    @Default(0.0) double fuelAmount,
    @Default(0.0) double totalPrice,
    required DateTime date,
    required TimeOfDay time,
    @Default(true) bool isFullTank,
    @Default(false) bool isRemainingFuelKnown,
    @Default(FuelStationType.pb95) FuelStationType fuelType,

    // For localization
    @Default(false) bool isStationsLoading,
    LatLng? coordinates,
    @Default([]) List<GasStation> nearGasStations,
    GasStation? selectedGasStation,
  }) = _CreateFuelLogState;
}

extension CreateFuelLogStateExtension on CreateFuelLogState {
  static CreateFuelLogState toEdit(FuelLog fuelLog) => CreateFuelLogState(
        currentOdometer: fuelLog.odometer,
        fuelPrice: fuelLog.fuelPrice,
        date: fuelLog.logDate,
        time: TimeOfDay.fromDateTime(fuelLog.logDate),
        coordinates: fuelLog.location,
        fuelAmount: fuelLog.fuelAmount,
        isFullTank: fuelLog.isFull,
        odometer: fuelLog.distance,
        odometerInputType: OdometerInputType.diff,
        totalPrice: fuelLog.fuelPrice * fuelLog.fuelAmount,
        fuelType: fuelLog.fuelType,
      );

  static CreateFuelLogState initial({
    required double fuelPrice,
    required double odometer,
  }) =>
      CreateFuelLogState(
        currentOdometer: odometer,
        fuelPrice: fuelPrice,
        date: DateTime.now(),
        time: TimeOfDay.now(),
      );

  double get odometerDiff => odometerInputType == OdometerInputType.total
      ? odometer - currentOdometer
      : odometer;

  double get fuelConsumption => fuelAmount * 100 / odometerDiff;
  String get fuelCons => '${fuelConsumption.toStringAsFixed(2)}  l/100km';

  String get dateDesc => date.toDateFormat;
  String get timeDesc =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  bool get isCorrect =>
      currentOdometer + odometerDiff > currentOdometer && fuelAmount > 0;
}
