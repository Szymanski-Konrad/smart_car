import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smart_car/app/resources/constants.dart';
import 'package:smart_car/app/resources/strings.dart';

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
    @Default(Constants.defaultLocalFile) String selectedJson,
    String? deviceAddress,
    String? deviceName,
  }) = _Settings;

  factory Settings.fromJson(Map<String, dynamic> json) =>
      _$SettingsFromJson(json);
}

extension SettingsExtension on Settings {
  String get deviceDescription => deviceAddress == null
      ? Strings.noSelectedDevice
      : '${deviceName ?? Strings.noName} - $deviceAddress';
}
