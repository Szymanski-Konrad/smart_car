import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';
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
    LatLng? location,
  }) = _FuelLog;
}

extension FuelLogExtension on FuelLog {
  String odometerFormatted() => '${odometer.showSpaced} km';
  String distanceFormatted() => '+ ${distanceTraveled.showSpaced} km';
  String fuelPriceFormatted() => '$fuelPrice zł';
  String totalCostFormatted() => '$totalPrice zł';
  String fuelAmountFormatted() => '$fuelAmount l';

  String fuelWithCost() => '${fuelAmountFormatted()} (${totalCostFormatted()})';

  double get fc => fuelAmount * 100 / distanceTraveled;
  String get fuelConsumption => '${fc.toStringAsFixed(2)} l/100km';
}

extension FuelLogsExtension on List<FuelLog> {
  double get totalDistance => fold(
      0, (previousValue, element) => previousValue + element.distanceTraveled);
  double get totalFuel => fold(0, (prev, element) => prev + element.fuelAmount);
  double get totalCost => fold(0, (prev, element) => prev + element.totalPrice);
  double get avgConsumption => totalFuel * 100 / totalDistance;

  String distanceFormatted() => '${totalDistance.toStringAsFixed(0)} km';
  String fuelFormatted() => '${totalFuel.toStringAsFixed(2)} l';
  String costFormatted() => '${totalCost.toStringAsFixed(2)} zł';
  String consumptionFormatted() =>
      '${avgConsumption.toStringAsFixed(2)} l/100km';
}
