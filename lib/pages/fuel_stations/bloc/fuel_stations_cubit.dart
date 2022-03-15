import 'package:bloc/bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:smart_car/app/resources/stations.dart';
import 'package:smart_car/models/gas_stations/gas_station.dart';
import 'package:smart_car/models/overpass/overpass_query.dart';
import 'package:smart_car/pages/fuel_stations/bloc/fuel_stations_state.dart';
import 'package:smart_car/services/overpass_api.dart';

class FuelStationsCubit extends Cubit<FuelStationsState> {
  FuelStationsCubit() : super(FuelStationsState());

  void switchFuelType(FuelStationType fuelType) {
    emit(state.copyWith(fuelType: fuelType));
  }

  void onLocationChanged(QueryLocation location) {
    emit(state.copyWith(location: location));
  }

  Future<void> onSearch() async {
    final _location = state.location;
    if (_location == null) return;
    final results = await OverpassApi.fetchGasStationsAroundCenter(
      _location,
      {'amenity': 'fuel'},
      5000,
    );
    final gasStations = _mapResultsToGasStations(results);
    emit(state.copyWith(gasStations: gasStations));
  }

  List<GasStation> _mapResultsToGasStations(List<ResponseLocation> locations) {
    final gasStations = <GasStation>[];
    for (final location in locations) {
      final index = TestStations.stations
          .indexWhere((element) => element.id == location.id);
      if (index >= 0) {
        gasStations.add(TestStations.stations[index]);
      } else {
        gasStations.add(
          GasStation(
            id: location.id,
            coordinates: LatLng(location.latitude, location.longitude),
          ),
        );
      }
    }

    return gasStations;
  }
}
