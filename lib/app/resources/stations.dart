import 'package:latlong2/latlong.dart';
import 'package:smart_car/models/gas_stations/gas_station.dart';

abstract class TestStations {
  static final stations = [
    GasStation(
      id: 1079919999,
      coordinates: LatLng(52.4410662, 20.6332433),
      fuelPrices: {
        FuelStationType.pb95: 4.25,
        FuelStationType.pb98: 4.99,
        FuelStationType.diesel: 5.30,
        FuelStationType.lpg: 2.35,
      },
    ),
    GasStation(
      id: 1798258554,
      coordinates: LatLng(52.4231573, 20.7264694),
      fuelPrices: {
        FuelStationType.pb95: 4.33,
        FuelStationType.pb98: 4.56,
        FuelStationType.diesel: 5.40,
        FuelStationType.lpg: 2.75,
      },
    ),
    GasStation(
      id: 3786272340,
      coordinates: LatLng(52.4479541, 20.6934301),
      fuelPrices: {
        FuelStationType.pb95: 4.33,
        FuelStationType.pb98: 4.56,
        FuelStationType.diesel: 5.40,
        FuelStationType.lpg: 2.75,
      },
    ),
    GasStation(
      id: 5992589645,
      coordinates: LatLng(52.424558, 20.7041623),
      fuelPrices: {
        FuelStationType.pb95: 7.33,
        FuelStationType.pb98: 5.56,
        FuelStationType.diesel: 6.40,
        FuelStationType.lpg: 3.75,
      },
    ),
  ];
}
