import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smart_car/models/coordinates.dart';
import 'package:smart_car/utils/double_extension.dart';

part 'fuel_log.freezed.dart';

@freezed
class FuelLog with _$FuelLog {
  factory FuelLog({
    required double odometer,
    required double fuelAmount,
    required double fuelPrice,
    required double totalPrice,
    required DateTime logDate,
    required double distanceTraveled,
    double? remainingFuel,
    double? fuelEfficiency,
    @Default(false) bool isRemainingFuelKnown,
    @Default(true) bool isFull,
    Coordinates? location,
  }) = _FuelLog;
}

extension FuelLogExtension on FuelLog {
  String odometerFormatted() =>
      '${odometer.showSpaced} km \n    ${distanceFormatted()}';
  String distanceFormatted() => '+ ${distanceTraveled.showSpaced} km';
  String fuelPriceFormatted() => '$fuelPrice zł';
  String totalCostFormatted() => '$totalPrice zł';

  double get fc => fuelAmount * 100 / distanceTraveled;
  String get fuelConsumption => '${fc.toStringAsFixed(2)} l/100km';
}
