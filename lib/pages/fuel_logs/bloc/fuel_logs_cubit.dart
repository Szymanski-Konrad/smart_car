import 'package:bloc/bloc.dart';
import 'package:smart_car/app/resources/data.dart';
import 'package:smart_car/pages/fuel_logs/bloc/fuel_logs_state.dart';

class FuelLogsCubit extends Cubit<FuelLogsState> {
  FuelLogsCubit() : super(FuelLogsState(logs: demoFuelLogs));

  void createNewLog() {}
}
