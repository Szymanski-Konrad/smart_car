import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smart_car/models/gas_stations/fuel_info.dart';
import 'package:smart_car/models/gas_stations/gas_station.dart';

part 'station_details_state.freezed.dart';

@freezed
class StationDetailsState with _$StationDetailsState {
  const factory StationDetailsState({
    required GasStation station,
    FuelStationType? selectedFuelType,
    @Default({}) Map<FuelStationType, FuelInfo> prices,
    @Default({}) Map<FuelStationType, FuelInfo> updatePrices,
  }) = _StationDetailsState;
}

extension StationDetailsStateExtension on StationDetailsState {
  bool isPriceEdited(FuelStationType type) => updatePrices.containsKey(type);
  DateTime? changeDate(FuelStationType type) =>
      station.fuelPrices[type]?.changeDate;
  FuelInfo? fuelInfo(FuelStationType type) =>
      updatePrices[type] ?? prices[type];
  bool containsPrice(FuelStationType type) =>
      prices.containsKey(type) || updatePrices.containsKey(type);
}
