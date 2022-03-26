import 'package:bloc/bloc.dart';
import 'package:smart_car/models/gas_stations/fuel_info.dart';
import 'package:smart_car/models/gas_stations/gas_station.dart';
import 'package:smart_car/pages/station_details/bloc/station_details_state.dart';
import 'package:smart_car/services/firestore_handler.dart';

class StationDetailsCubit extends Cubit<StationDetailsState> {
  StationDetailsCubit(GasStation station)
      : super(StationDetailsState(station: station)) {
    init();
  }

  void init() {
    final station = state.station;
    emit(state.copyWith(prices: station.fuelPrices));
  }

  void enablePriceChange(FuelStationType fuelType) {
    final updatePrices =
        Map<FuelStationType, FuelInfo>.from(state.updatePrices);
    if (!updatePrices.containsKey(fuelType)) {
      updatePrices
          .addAll({fuelType: state.prices[fuelType] ?? FuelInfo.empty()});
      emit(state.copyWith(updatePrices: updatePrices));
    }
  }

  void disablePriceChange(FuelStationType fuelType, bool shouldSave) {
    final updatePrices =
        Map<FuelStationType, FuelInfo>.from(state.updatePrices);
    if (shouldSave) {
      final newPrice = updatePrices[fuelType];
      if (newPrice == null) return;
      final prices = Map<FuelStationType, FuelInfo>.from(state.prices);
      prices.addAll({fuelType: newPrice.copyWith(changeDate: DateTime.now())});
      emit(state.copyWith(prices: prices));
    }
    updatePrices.remove(fuelType);
    emit(state.copyWith(updatePrices: updatePrices));
  }

  void addNewFuelType(FuelStationType fuelType) {
    enablePriceChange(fuelType);
  }

  void increasePrice(FuelStationType fuelType) {
    final fuelInfo = state.updatePrices[fuelType];
    if (fuelInfo == null) return;
    editPrice(fuelType, fuelInfo.price + 0.01);
  }

  void decreasePrice(FuelStationType fuelType) {
    final fuelInfo = state.updatePrices[fuelType];
    if (fuelInfo == null || fuelInfo.price < 0.01) return;
    editPrice(fuelType, fuelInfo.price - 0.01);
  }

  void editPrice(FuelStationType fuelType, double? price) {
    if (price == null || price < 0) return;
    final updatePrices =
        Map<FuelStationType, FuelInfo>.from(state.updatePrices);
    updatePrices[fuelType] = FuelInfo.price(price);
    emit(state.copyWith(updatePrices: updatePrices));
  }

  Future<void> saveChanges() async {
    if (state.updatePrices.isNotEmpty) return;
    final prices = Map<FuelStationType, FuelInfo>.from(state.prices);
    final station = state.station.copyWith(fuelPrices: prices);
    await FirestoreHandler.saveStation(station);
  }
}
