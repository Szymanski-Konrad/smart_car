import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:smart_car/app/repositories/storage.dart';
import 'package:smart_car/models/settings.dart';
import 'package:smart_car/pages/settings/bloc/settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(SettingsStateExtension.initial);

  Future<void> loadSettings() async {
    final json = await Storage.getSettingsJson();
    if (json == null) return;
    final settings = Settings.fromJson(jsonDecode(json));
    emit(state.copyWith(settings: settings));
  }

  Future<void> saveSettings() async {
    final json = jsonEncode(state.settings);
    await Storage.updateSettings(json);
  }
}
