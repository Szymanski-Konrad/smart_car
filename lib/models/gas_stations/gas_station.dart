import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smart_car/models/coordinates.dart';

part 'gas_station.freezed.dart';
part 'gas_station.g.dart';

@freezed
class GasStation with _$GasStation {
  factory GasStation({
    required String id,
    // required Coordinates coordinates,
    @Default({}) Map<String, double> fuelPrices,
  }) = _GasStation;

  factory GasStation.fromJson(Map<String, dynamic> json) =>
      _$GasStationFromJson(json);
}
