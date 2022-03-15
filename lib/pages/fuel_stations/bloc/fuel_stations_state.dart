import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smart_car/models/gas_stations/gas_station.dart';
import 'package:smart_car/models/overpass/overpass_query.dart';

part 'fuel_stations_state.freezed.dart';

@freezed
class FuelStationsState with _$FuelStationsState {
  factory FuelStationsState({
    @Default([]) List<GasStation> gasStations,
    @Default(FuelStationType.pb95) FuelStationType fuelType,
    QueryLocation? location,
  }) = _FuelStationsState;
}
