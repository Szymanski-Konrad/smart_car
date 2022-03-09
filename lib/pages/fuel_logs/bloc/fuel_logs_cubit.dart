import 'package:bloc/bloc.dart';
import 'package:smart_car/app/navigation/navigation.dart';
import 'package:smart_car/app/navigation/routes.dart';
import 'package:smart_car/app/resources/data.dart';
import 'package:smart_car/models/fuel_logs/fuel_log.dart';
import 'package:smart_car/pages/create_fuel_log/ui/create_fuel_log_page.dart';
import 'package:smart_car/pages/fuel_logs/bloc/fuel_logs_state.dart';

class FuelLogsCubit extends Cubit<FuelLogsState> {
  FuelLogsCubit() : super(FuelLogsState(logs: demoFuelLogs));

  void createNewLog() {
    final argument = CreateFuelLogPageArgument(
      currentOdometer: state.logs.last.odometer,
      lastFuelPrice: state.logs.last.fuelPrice,
    );
    Navigation.instance.push(SharedRoutes.createFuelLog, arguments: argument);
  }

  void addNewLog(FuelLog log) {
    final logs = List<FuelLog>.from(state.logs);
    logs.add(log);
    emit(state.copyWith(logs: logs));
  }
}
