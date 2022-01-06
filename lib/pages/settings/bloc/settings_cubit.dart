import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:smart_car/app/repositories/storage.dart';
import 'package:smart_car/models/settings.dart';
import 'package:smart_car/pages/settings/bloc/settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(SettingsStateExtension.initial);

  Timer? saveTimer;

  Future<void> loadSettings() async {
    final json = await Storage.getSettingsJson();
    if (json == null) return;
    final settings = Settings.fromJson(jsonDecode(json));
    emit(state.copyWith(settings: settings));
  }

  Future<void> saveSettings() async {
    print('saving settings');
    final json = jsonEncode(state.settings);
    await Storage.updateSettings(json);
    changeSaved(true);
  }

  void changeSaved(bool value) {
    emit(state.copyWith(isSaved: value));
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

  void updateTankSize(String input) {
    print('update');
    final value = int.tryParse(input);
    if (value != null) {
      emit(state.copyWith(settings: state.settings.copyWith(tankSize: value)));
      startTimer();
    }
  }

  void startTimer() {
    saveTimer?.cancel();
    saveTimer = Timer(const Duration(seconds: 2), saveSettings);
  }
}
