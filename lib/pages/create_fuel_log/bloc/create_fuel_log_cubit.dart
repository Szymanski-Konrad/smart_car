import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_car/app/blocs/global_bloc.dart';
import 'package:smart_car/app/navigation/navigation.dart';
import 'package:smart_car/models/fuel_logs/fuel_log.dart';
import 'package:smart_car/models/gas_stations/gas_station.dart';
import 'package:smart_car/pages/create_fuel_log/bloc/create_fuel_log_state.dart';
import 'package:uuid/uuid.dart';

class CreateFuelLogCubit extends Cubit<CreateFuelLogState> {
  CreateFuelLogCubit({
    required double odometer,
    required double fuelPrice,
  }) : super(CreateFuelLogStateExtension.initial(
          fuelPrice: fuelPrice,
          odometer: odometer,
        ));

  void updateOdometer(String? value) {
    if (value == null) return;
    final parsed = double.tryParse(value);
    if (parsed == null) return;
    emit(state.copyWith(odometer: parsed));
  }

  void updateFuelAmount(String? value) {
    if (value == null) return;
    final parsed = double.tryParse(value);
    if (parsed == null) return;
    emit(state.copyWith(fuelAmount: parsed));
    updateFuelCost();
  }

  void updateFuelPrice(String? value) {
    if (value == null) return;
    final parsed = double.tryParse(value);
    if (parsed == null) return;
    emit(state.copyWith(fuelPrice: parsed));
    updateFuelCost();
  }

  void updateFuelCost() {
    final cost = state.fuelPrice * state.fuelAmount;
    emit(state.copyWith(totalPrice: cost));
  }

  void timeUpdate(TimeOfDay? value) {
    if (value == null) return;
    emit(state.copyWith(time: value));
  }

  void dateUpdate(DateTime? value) {
    if (value == null) return;
    emit(state.copyWith(date: value));
  }

  void changeFuelType(FuelStationType type) {
    emit(state.copyWith(fuelType: type));
  }

  void saveLog() {
    final dateTime = DateTime(
      state.date.year,
      state.date.month,
      state.date.day,
      state.time.hour,
      state.time.minute,
    );
    GlobalBlocs.fuelLogs.addNewLog(FuelLog(
      id: const Uuid().v1(),
      odometer: state.odometer + state.odometerDiff,
      fuelAmount: state.fuelAmount,
      fuelPrice: state.fuelPrice,
      logDate: dateTime,
      distance: state.odometerDiff,
      isFull: state.isFullTank,
      isRemainingFuelKnown: state.isRemainingFuelKnown,
      fuelType: state.fuelType,
    ));
    Navigation.instance.pop();
  }
}
