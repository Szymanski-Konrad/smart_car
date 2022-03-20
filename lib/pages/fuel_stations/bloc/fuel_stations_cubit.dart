import 'package:bloc/bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:smart_car/app/resources/stations.dart';
import 'package:smart_car/models/gas_stations/gas_station.dart';
import 'package:smart_car/models/overpass/overpass_query.dart';
import 'package:smart_car/pages/fuel_stations/bloc/fuel_stations_state.dart';
import 'package:smart_car/services/firestore_handler.dart';
import 'package:smart_car/services/overpass_api.dart';

class FuelStationsCubit extends Cubit<FuelStationsState> {
  FuelStationsCubit() : super(FuelStationsState());

  void switchFuelType(FuelStationType fuelType) {
    emit(state.copyWith(fuelType: fuelType));
  }

  void onLocationChanged(QueryLocation location) {
    final _location = state.location;
    emit(state.copyWith(location: location));
    if (_location == null) {
      onSearch();
    }
  }

  Future<void> onSearch() async {
    final _location = state.location;
    if (_location == null) return;
    final results = await OverpassApi.fetchGasStationsAroundCenter(
      _location,
      {'amenity': 'fuel'},
      5000,
    );
    final gasStations = await _mapResultsToGasStations(results);
    emit(state.copyWith(gasStations: gasStations));
  }

  Future<List<GasStation>> _mapResultsToGasStations(
    List<ResponseLocation> locations,
  ) async {
    final gasStations = <GasStation>[];
    final ids = locations.map((e) => e.id.toString()).toList();
    final remoteStations = await FirestoreHandler.getAllStations(ids);
    if (remoteStations.length == locations.length) {
      return remoteStations;
    }
    for (final location in locations) {
      final index =
          remoteStations.indexWhere((element) => element.id == location.id);
      if (index >= 0) {
        gasStations.add(remoteStations[index]);
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
