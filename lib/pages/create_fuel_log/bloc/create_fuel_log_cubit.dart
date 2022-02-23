import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_car/app/blocs/global_bloc.dart';
import 'package:smart_car/models/fuel_logs/fuel_log.dart';
import 'package:smart_car/pages/create_fuel_log/bloc/create_fuel_log_state.dart';

class CreateFuelLogCubit extends Cubit<CreateFuelLogState> {
  CreateFuelLogCubit() : super(CreateFuelLogStateExtension.initial);

  void tempEdit(String? value) {}

  void dateUpdate(DateTime? value) {
    if (value != null) {
      emit(state.copyWith(dateTime: value));
    }
  }

  void saveLog() {
    GlobalBlocs.fuelLogs.addNewLog(FuelLog(
      odometer: state.odometer,
      fuelAmount: state.fuelAmount,
      fuelPrice: state.fuelPrice,
      totalPrice: state.totalPrice,
      logDate: state.dateTime,
      odometerDiff: state.odometer,
    ));
  }
}
