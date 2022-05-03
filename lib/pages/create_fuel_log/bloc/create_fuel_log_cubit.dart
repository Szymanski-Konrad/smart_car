import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_car/app/blocs/global_bloc.dart';
import 'package:smart_car/app/navigation/navigation.dart';
import 'package:smart_car/app/repositories/storage.dart';
import 'package:smart_car/app/resources/constants.dart';
import 'package:smart_car/models/fuel_logs/fuel_log.dart';
import 'package:smart_car/models/gas_stations/gas_station.dart';
import 'package:smart_car/models/overpass/overpass_query.dart';
import 'package:smart_car/pages/create_fuel_log/bloc/create_fuel_log_state.dart';
import 'package:smart_car/services/firestore_handler.dart';
import 'package:smart_car/services/overpass_api.dart';
import 'package:smart_car/utils/location_helper.dart';
import 'package:smart_car/utils/validators.dart';

class CreateFuelLogCubit extends Cubit<CreateFuelLogState> {
  CreateFuelLogCubit({
    required double odometer,
    required double fuelPrice,
    FuelLog? fuelLog,
  }) : super(fuelLog != null
            ? CreateFuelLogStateExtension.toEdit(fuelLog)
            : CreateFuelLogStateExtension.initial(
                fuelPrice: fuelPrice,
                odometer: odometer,
              )) {
    init(fuelLog);
  }

  final odometerTextController = TextEditingController();
  final distanceTextController = TextEditingController();

  String? checkOdometerValue(String? value) {
    return Validators.odometerHigherThanPreviousValidator(
        value, state.currentOdometer);
  }

  Future<void> init(FuelLog? fuelLog) async {
    if (fuelLog != null) {
      odometerTextController.text = fuelLog.odometer.toString();
      distanceTextController.text = fuelLog.distance.toString();
    }
    final location = await LocationHelper.getCurrentLocation();
    if (location == null) return;
    if (!isClosed) {
      emit(state.copyWith(isStationsLoading: true, coordinates: location));
      final stations = await OverpassApi.fetchGasStationsAroundCenter(
          QueryLocation.fromLatLng(location));
      if (!isClosed) {
        stations.sortByLocation(location);
        if (stations.isNotEmpty &&
            stations.first.distanceTo(location) <=
                Constants.autoAssignStationMaxDistanceKM) {
          emit(state.copyWith(selectedGasStation: stations.first));
        }
        emit(state.copyWith(
          isStationsLoading: false,
          nearGasStations: stations,
        ));
      }
    }
  }

  void updateOdometer(String? value) {
    if (value == null) return;
    final parsed = double.tryParse(value);
    if (parsed == null) return;
    emit(state.copyWith(odometer: parsed));
    distanceTextController.value =
        newTextValue(state.newDistance.toStringAsFixed(1));
  }

  TextEditingValue newTextValue(String value) {
    return TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  void updateDistance(String? value) {
    if (value == null) return;
    final parsed = double.tryParse(value);
    if (parsed == null) return;
    emit(state.copyWith(distance: parsed));
    odometerTextController.value =
        newTextValue(state.newOdometer.toStringAsFixed(1));
  }

  void updateFuelAmount(String? value) {
    if (value == null) return;
    final parsed = double.tryParse(value);
    if (parsed == null) return;
    emit(state.copyWith(fuelAmount: parsed));
  }

  void toggleOdometerInputType(bool value) {
    final type = value ? OdometerInputType.diff : OdometerInputType.total;
    emit(state.copyWith(odometerInputType: type));
  }

  void updateFuelPrice(String? value) {
    if (value == null) return;
    final parsed = double.tryParse(value);
    if (parsed == null) return;
    emit(state.copyWith(fuelPrice: parsed));
  }

  void timeUpdate(TimeOfDay? value) {
    if (value == null) return;
    emit(state.copyWith(time: value));
  }

  void dateUpdate(DateTime? value) {
    if (value == null) return;
    emit(state.copyWith(date: value));
  }

  void changeFuelType(FuelStationType type) {
    emit(state.copyWith(fuelType: type));
  }

  void selectStation(GasStation station) {
    emit(state.copyWith(selectedGasStation: station));
  }

  Future<void> saveLog() async {
    emit(state.copyWith(isSaving: true));
    final dateTime = DateTime(
      state.date.year,
      state.date.month,
      state.date.day,
      state.time.hour,
      state.time.minute,
    );

    GlobalBlocs.fuelLogs.addLog(FuelLog(
      id: state.fuelLogId,
      odometer: state.newOdometer,
      fuelAmount: state.fuelAmount,
      fuelPrice: state.fuelPrice,
      logDate: dateTime,
      distance: state.distance,
      isFull: state.isFullTank,
      isRemainingFuelKnown: state.isRemainingFuelKnown,
      fuelType: state.fuelType,
      location: state.coordinates,
      stationName: state.selectedGasStation?.stationName,
      vin: GlobalBlocs.settings.state.settings.vin,
    ));
    final station = state.selectedGasStation;
    if (station != null) {
      await FirestoreHandler.updateStationPrice(
        station: station.updatePrice(state.fuelType, state.fuelPrice),
      );
    }
    Storage.updateFuelPrice(state.fuelPrice);
    GlobalBlocs.settings.loadSettings();
    emit(state.copyWith(isSaving: false));
    Navigation.instance.pop();
  }

  @override
  Future<void> close() async {
    distanceTextController.dispose();
    odometerTextController.dispose();
    super.close();
  }
}
