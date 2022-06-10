import 'package:bloc/bloc.dart';
import 'package:smart_car/app/blocs/global_bloc.dart';
import 'package:smart_car/app/navigation/navigation.dart';
import 'package:smart_car/app/navigation/routes.dart';
import 'package:smart_car/models/fuel_logs/fuel_log.dart';
import 'package:smart_car/pages/create_fuel_log/ui/create_fuel_log_page.dart';
import 'package:smart_car/pages/fuel_logs/bloc/fuel_logs_state.dart';
import 'package:smart_car/services/firestore_handler.dart';

class FuelLogsCubit extends Cubit<FuelLogsState> {
  FuelLogsCubit() : super(FuelLogsState()) {
    fetchLogs();
  }

  Future<void> fetchLogs() async {
    final results = await FirestoreHandler.fetchFuelLogs();
    GlobalBlocs.settings.updateRefuelingConsumption(results.avgConsumption);
    emit(state.copyWith(logs: results));
  }

  void createNewLog() {
    final argument = CreateFuelLogPageArgument(
      currentOdometer: state.logs.isEmpty ? 0.0 : state.logs.last.odometer,
      lastFuelPrice: state.logs.isEmpty ? 0.0 : state.logs.last.fuelPrice,
    );
    Navigation.instance.push(SharedRoutes.createFuelLog, arguments: argument);
  }

  Future<void> addLog(FuelLog log) async {
    await FirestoreHandler.saveFuelLog(log);
    final logs = List<FuelLog>.from(state.logs);
    final index = logs.indexWhere((element) => element.id == log.id);
    if (index != -1) {
      logs.removeAt(index);
      logs.insert(index, log);
    } else {
      logs.add(log);
    }
    emit(state.copyWith(logs: logs));
  }

  Future<void> editLog(FuelLog log) async {
    await FirestoreHandler.saveFuelLog(log);
    final logs = List<FuelLog>.from(state.logs);
    final index = logs.indexWhere((element) => element.id == log.id);
    if (index != -1) {
      logs.removeAt(index);
      logs.insert(index, log);
      emit(state.copyWith(logs: logs));
    }
  }
}
