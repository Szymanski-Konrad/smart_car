import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smart_car/models/settings.dart';
import 'package:smart_car/models/statistics.dart';

part 'settings_state.freezed.dart';

@freezed
class SettingsState with _$SettingsState {
  factory SettingsState({
    required Settings settings,
    required Statistics stats,
    @Default(false) bool isSaved,
  }) = _SettingsState;
}

extension SettingsStateExtension on SettingsState {
  static SettingsState get initial => SettingsState(
        settings: Settings(),
        stats: Statistics(),
      );

  String? get vin => settings.vin;
}
