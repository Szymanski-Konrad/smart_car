import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings.freezed.dart';
part 'settings.g.dart';

enum FuelType {
  gasoline,
  diesel,
  lpg,
}

@freezed
class Settings with _$Settings {
  factory Settings({
    @Default(0) int engineCapacity,
    @Default(0) int horsepower,
    @Default(0) int tankSize,
    @Default(0.0) double fuelPrice,
  }) = _Settings;

  factory Settings.fromJson(Map<String, dynamic> json) =>
      _$SettingsFromJson(json);
}
