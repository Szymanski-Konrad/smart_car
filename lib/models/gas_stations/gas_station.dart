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

enum FuelStationType { pb95, pb98, diesel, lpg }

extension FuelStationTypeExtension on FuelStationType {
  String get description {
    switch (this) {
      case FuelStationType.pb95:
        return 'PB 95';
      case FuelStationType.pb98:
        return 'PB 98';
      case FuelStationType.diesel:
        return 'ON';
      case FuelStationType.lpg:
        return 'LPG';
    }
  }
}
