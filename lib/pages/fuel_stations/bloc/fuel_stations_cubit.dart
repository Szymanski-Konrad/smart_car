import 'package:bloc/bloc.dart';
import 'package:fl_toast/fl_toast.dart';
import 'package:flutter/material.dart';
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
    final _location = state.location;
    emit(state.copyWith(location: location));
    if (_location == null) {
      onSearch();
    }
  }

  Future<void> onSearch() async {
    emit(state.copyWith(isLoading: true));
    final _location = state.location;
    if (_location == null) return;
    final gasStations = await OverpassApi.fetchGasStationsAroundCenter(
      _location,
      onTimeout: onTimeout,
    );

    emit(state.copyWith(
      gasStations: gasStations,
      isLoading: false,
    ));
  }

  Future<void> onTimeout() async {
    emit(state.copyWith(isLoading: false));
    await showAndroidToast(
      backgroundColor: Colors.green,
      alignment: Alignment.center,
      child: const Text('Nie można pobrać stacji, spróbuj ponownie'),
      duration: const Duration(seconds: 2),
      context: ToastProvider.context,
    );
  }
}
