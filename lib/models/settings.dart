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

extension FuelTypeExtension on FuelType {
  double get airFuelRatio {
    switch (this) {
      case FuelType.gasoline:
        return 14.7;
      case FuelType.diesel:
        return 14.5;
      case FuelType.lpg:
        return 16.1;
    }
  }

  double get density {
    switch (this) {
      case FuelType.gasoline:
        return 750;
      case FuelType.diesel:
        return 835;
      case FuelType.lpg:
        return 550;
    }
  }

  double get carbonPercentage {
    switch (this) {
      case FuelType.gasoline:
        return 0.87;
      case FuelType.diesel:
        return 0.862;
      case FuelType.lpg:
        return 0.825;
    }
  }
}

@freezed
class Settings with _$Settings {
  factory Settings({
    @Default(0) int engineCapacity,
    @Default(0) int horsepower,
    @Default(0.0) double tankSize,
    @Default(6.0) double fuelPrice,
    @Default(FuelType.gasoline) FuelType fuelType,
    @Default(Constants.defaultLocalFile) String selectedJson,
    String? deviceAddress,
    String? deviceName,
    String? vin,
    double? leftFuel, // Left fuel in percents
  }) = _Settings;

  factory Settings.fromJson(Map<String, dynamic> json) =>
      _$SettingsFromJson(json);
}

extension SettingsExtension on Settings {
  String get deviceDescription => deviceAddress == null
      ? Strings.noSelectedDevice
      : '${deviceName ?? Strings.noName} - $deviceAddress';

  String get vinDescription => Strings.vin(vin);

  double get tankPercent {
    final _leftFuel = leftFuel;
    if (_leftFuel == null || tankSize == 0) return 0;
    return _leftFuel / 100;
  }

  String get tankDetails {
    final _leftFuel = (leftFuel ?? 0) * tankSize / 100;
    return 'Bak paliwa: ${_leftFuel.toStringAsFixed(1)} / $tankSize l';
  }
}
