import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smart_car/models/gas_stations/gas_station.dart';

part 'fuel_stations_state.freezed.dart';

@freezed
class FuelStationsState with _$FuelStationsState {
  factory FuelStationsState({
    @Default([]) List<GasStation> gasStation,
  }) = _FuelStationsState;
}
