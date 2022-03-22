import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smart_car/models/gas_stations/gas_station.dart';

part 'station_details_state.freezed.dart';

@freezed
class StationDetailsState with _$StationDetailsState {
  const factory StationDetailsState({
    required GasStation station,
    FuelStationType? selectedFuelType,
    double? newPrice,
  }) = _StationDetailsState;
}
