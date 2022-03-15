import 'package:bloc/bloc.dart';
import 'package:smart_car/models/gas_stations/gas_station.dart';
import 'package:smart_car/pages/fuel_stations/bloc/fuel_stations_state.dart';

class FuelStationsCubit extends Cubit<FuelStationsState> {
  FuelStationsCubit() : super(FuelStationsState());

  void switchFuelType(FuelStationType fuelType) {
    emit(state.copyWith(fuelType: fuelType));
  }
}
