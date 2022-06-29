import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:csv/csv.dart';
import 'package:fl_toast/fl_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:smart_car/app/blocs/global_bloc.dart';
import 'package:smart_car/app/repositories/storage.dart';
import 'package:smart_car/app/resources/constants.dart';
import 'package:smart_car/models/fuel_logs/fuel_log.dart';
import 'package:smart_car/models/gas_stations/gas_station.dart';
import 'package:smart_car/models/settings.dart';
import 'package:smart_car/models/statistics.dart';
import 'package:smart_car/pages/settings/bloc/settings_state.dart';
import 'package:smart_car/services/firestore_handler.dart';
import 'package:uuid/uuid.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(SettingsStateExtension.initial);

  Timer? saveTimer;

  Future<void> loadSettings() async {
    final json = await Storage.getSettingsJson();
    if (json == null) return;
    Settings settings = Settings.fromJson(jsonDecode(json));
    if (!Constants.localFiles.contains(settings.selectedJson)) {
      settings = settings.copyWith(selectedJson: Constants.localFiles.first);
    }
    final statsJson = await Storage.getStatisticsJson();
    final stats = Statistics.fromJson(jsonDecode(statsJson ?? ''));
    emit(state.copyWith(
      settings: settings,
      stats: stats,
    ));
  }

  Future<void> saveSettings() async {
    final json = jsonEncode(state.settings);
    await Storage.updateSettings(json);
    changeSaved(true);
  }

  Future<void> saveStats() async {
    final json = jsonEncode(state.stats);
    await Storage.updateStatistics(json);
  }

  void changeSaved(bool value) {
    emit(state.copyWith(isSaved: value));
  }

  void updateDevice(BluetoothDevice device) {
    emit(state.copyWith(
      settings: state.settings.copyWith(
        deviceAddress: device.address,
        deviceName: device.name,
      ),
    ));
    startTimer();
  }

  void updateJson(String? value) {
    if (value != null) {
      emit(
        state.copyWith(settings: state.settings.copyWith(selectedJson: value)),
      );
      startTimer();
    }
  }

  void updateEngineCapacity(String input) {
    final value = int.tryParse(input);
    if (value != null) {
      emit(state.copyWith(
          settings: state.settings.copyWith(engineCapacity: value)));
      startTimer();
    }
  }

  void updateFuelPrice(String input) {
    final value = double.tryParse(input);
    if (value != null) {
      emit(state.copyWith(settings: state.settings.copyWith(fuelPrice: value)));
      startTimer();
    }
  }

  void updateHorsepower(String input) {
    final value = int.tryParse(input);
    if (value != null) {
      emit(
          state.copyWith(settings: state.settings.copyWith(horsepower: value)));
      startTimer();
    }
  }

  Future<void> convertCSV() async {
    final data = await rootBundle.loadString('assets/csv/vehicle-1-sync.csv');
    final csv =
        const CsvToListConverter(eol: '\n').convert(data).reversed.toList();
    final fuelLogs = <FuelLog>[];
    for (final row in csv) {
      final fuelLog = FuelLog(
        id: const Uuid().v1(),
        distance: fuelLogs.isEmpty
            ? 0
            : double.parse(row[1]) - fuelLogs.last.odometer,
        fuelAmount: double.parse(row[2]),
        fuelPrice: double.parse(row[13]),
        fuelType: FuelStationType.pb95,
        logDate: DateTime.parse(row[0]),
        odometer: double.parse(row[1]),
        isFull: int.parse(row[3]) == 1 ? true : false,
        vin: GlobalBlocs.settings.state.vin,
      );
      fuelLogs.add(fuelLog);
      await FirestoreHandler.saveFuelLog(fuelLog);
    }
    print(data);
  }

  void updateTankSize(String input) {
    final value = double.tryParse(input);
    if (value != null) {
      emit(state.copyWith(settings: state.settings.copyWith(tankSize: value)));
      startTimer();
    }
  }

  void updateVin(String? input) {
    emit(state.copyWith(settings: state.settings.copyWith(vin: input)));
    startTimer();
  }

  void updateLeftFuel(double value) {
    emit(state.copyWith(settings: state.settings.copyWith(leftFuel: value)));
    startTimer();
  }

  void updateStats({
    required double fuelLeft,
    required double distance,
    required double fuelUsed,
  }) async {
    final tankSize = GlobalBlocs.settings.state.settings.tankSize;
    final leftFuel = tankSize * (fuelLeft / 100);
    final range = 100 * leftFuel / state.stats.refuelingConsumption;
    final totalDistance = state.stats.distance + distance;
    final totalFuelUsed = state.stats.fuelUsed + fuelUsed;
    showAndroidToast(
      child: Text('Pozostałe paliwo: $fuelLeft %,  Nowy zasięg: $range km'),
      context: ToastProvider.context,
      duration: const Duration(seconds: 10),
    );
    emit(state.copyWith(
      stats: state.stats.copyWith(
        range: range,
        distance: totalDistance,
        fuelUsed: totalFuelUsed,
      ),
    ));
    await saveStats();
  }

  void updateRefuelingConsumption(double consumption) async {
    emit(state.copyWith(
      stats: state.stats.copyWith(refuelingConsumption: consumption),
    ));

    await saveStats();
  }

  void updateFuelType(FuelType? fuelType) {
    if (fuelType != null) {
      emit(state.copyWith(
          settings: state.settings.copyWith(fuelType: fuelType)));
      startTimer();
    }
  }

  void startTimer() {
    saveTimer?.cancel();
    saveTimer = Timer(const Duration(seconds: 2), saveSettings);
  }
}
