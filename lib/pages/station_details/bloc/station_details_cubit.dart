import 'package:bloc/bloc.dart';
import 'package:smart_car/models/gas_stations/gas_station.dart';
import 'package:smart_car/pages/station_details/bloc/station_details_state.dart';

class StationDetailsCubit extends Cubit<StationDetailsState> {
  StationDetailsCubit(GasStation station)
      : super(StationDetailsState(station: station));

  void editFuelType(FuelStationType? fuelType) {
    emit(state.copyWith(selectedFuelType: fuelType));
  }

  void editPrice(double? price) {
    emit(state.copyWith(newPrice: price));
  }

  Future<void> saveChanges() async {
    emit(state.copyWith(
      selectedFuelType: null,
      newPrice: null,
    ));
  }
}
