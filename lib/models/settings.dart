import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings.freezed.dart';
part 'settings.g.dart';

enum FuelType {
  gasoline, // density = 820 AFR = 14.7
  diesel, // density = 750, AFR = 14.5
  lpg,
}

@freezed
class Settings with _$Settings {
  factory Settings({
    @Default(0) int engineCapacity,
    @Default(0) int horsepower,
    @Default(0) int tankSize,
    @Default(0.0) double fuelPrice,
    @Default(FuelType.gasoline) FuelType fuelType,
  }) = _Settings;

  factory Settings.fromJson(Map<String, dynamic> json) =>
      _$SettingsFromJson(json);
}
