// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';
import 'package:smart_car/app/resources/strings.dart';
import 'package:smart_car/models/gas_stations/fuel_info.dart';
import 'package:smart_car/models/overpass/overpass_query.dart';
import 'package:smart_car/utils/location_helper.dart';

part 'gas_station.freezed.dart';
part 'gas_station.g.dart';

@freezed
class GasStation with _$GasStation {
  factory GasStation({
    required int id,
    @JsonKey(toJson: LocationHelper.coordsToJson) required LatLng coordinates,
    @Default({}) Map<FuelStationType, FuelInfo> fuelPrices,
    @Default(Strings.gasStation) String name,
    String? city,
    String? street,
    String? openingHours,
    String? postcode,
    String? brand,
    String? stationOperator,
    String? houseNumber,
    @Default(false) bool hasLpg,
    @Default(false) bool hasDiesel,
    @Default(false) bool hasPb95,
    @Default(false) bool hasPb98,
    @Default(false) bool hasShop,
    @Default(false) bool hasElectricity,
  }) = _GasStation;

  factory GasStation.fromLocation(ResponseLocation location) => GasStation(
        id: location.id,
        coordinates: LatLng(location.latitude, location.longitude),
        brand: location.brand,
        city: location.city,
        fuelPrices: {},
        hasDiesel: location.hasDiesel,
        hasElectricity: location.hasElectricity,
        hasLpg: location.hasLpg,
        hasPb95: location.hasPb95,
        hasPb98: location.hasPb98,
        hasShop: location.hasShop,
        houseNumber: location.houseNumber,
        name: location.name ?? Strings.gasStation,
        openingHours: location.openingHours,
        postcode: location.postcode,
        stationOperator: location.stationOperator,
        street: location.street,
      );

  factory GasStation.fromJson(Map<String, dynamic> json) =>
      _$GasStationFromJson(json);
}

extension GasStationExtension on GasStation {
  double? fuelPrice(FuelStationType type) {
    return fuelPrices[type]?.price;
  }

  String get address => '$city, $street $houseNumber, $postcode';

  String get stationName {
    final _brand = brand;
    return name == 'Stacja paliw' && _brand != null ? _brand : name;
  }

  /// Calcuate distance from [location] to station, return result in km
  double distanceTo(LatLng location) {
    return LocationHelper.calculateDistanceLatLng(coordinates, location);
  }

  GasStation updatePrice(FuelStationType type, double price) {
    final _prices = fuelPrices;
    _prices[type] = FuelInfo.price(price);
    return copyWith(fuelPrices: _prices);
  }
}

extension GasStationsExtension on List<GasStation> {
  void sortByLocation(LatLng location) {
    sort((a, b) => compareDistance(a, b, location));
  }

  int compareDistance(GasStation a, GasStation b, LatLng location) {
    final distance = a.distanceTo(location) - b.distanceTo(location);
    if (distance > 0) return 1;
    if (distance < 0) return -1;
    return 0;
  }
}

enum FuelStationType { pb95, pb98, diesel, lpg }

extension FuelStationTypeExtension on FuelStationType {
  String get description {
    switch (this) {
      case FuelStationType.pb95:
        return '95';
      case FuelStationType.pb98:
        return '98';
      case FuelStationType.diesel:
        return 'ON';
      case FuelStationType.lpg:
        return 'LPG';
    }
  }
}
