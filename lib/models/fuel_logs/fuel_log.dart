import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';
import 'package:smart_car/models/gas_stations/gas_station.dart';
import 'package:smart_car/utils/double_extension.dart';

part 'fuel_log.freezed.dart';
part 'fuel_log.g.dart';

@freezed
class FuelLog with _$FuelLog {
  factory FuelLog({
    required String id,
    required double odometer,
    required double distance,
    required double fuelAmount,
    required double fuelPrice,
    required DateTime logDate,
    required FuelStationType fuelType,
    @Default(false) bool isRemainingFuelKnown,
    @Default(true) bool isFull,
    double? remainingFuel,
    LatLng? location,
    String? stationName,
  }) = _FuelLog;

  factory FuelLog.fromJson(Map<String, dynamic> json) =>
      _$FuelLogFromJson(json);
}

extension FuelLogExtension on FuelLog {
  String odometerFormatted() => '${odometer.showSpaced} km';
  String distanceFormatted() => '+ ${distance.showSpaced} km';
  String fuelPriceFormatted() => '$fuelPrice zł';
  String totalCostFormatted() => '${totalCost.toStringAsFixed(2)} zł';
  String fuelAmountFormatted() => '$fuelAmount l';
  String fuelWithCost() => '${fuelAmountFormatted()} (${totalCostFormatted()})';
  String fuelConsumptionFormatted() =>
      '${fuelConsumption.toStringAsFixed(2)} l/100km';

  double get totalCost => fuelPrice * fuelAmount;
  double get fuelConsumption => fuelAmount * 100 / distance;
}

extension FuelLogsExtension on List<FuelLog> {
  // total
  double get totalDistance =>
      fold(0, (previousValue, element) => previousValue + element.distance);
  double get totalFuel => fold(0, (prev, element) => prev + element.fuelAmount);
  double get totalCost => fold(0, (prev, element) => prev + element.totalCost);
  double get avgConsumption => totalFuel * 100 / totalDistance;

  String totalDistanceFormatted() => '${totalDistance.toStringAsFixed(0)} km';
  String totalFuelFormatted() => '${totalFuel.toStringAsFixed(2)} l';
  String totalCostFormatted() => '${totalCost.toStringAsFixed(2)} zł';
  String consumptionFormatted() =>
      '${avgConsumption.toStringAsFixed(2)} l/100km';

  // average
  double get averageDistance => totalDistance / length;
  double get averageFuel => totalFuel / length;
  double get averageCost => totalCost / length;

  String averageDistanceFormatted() =>
      '${averageDistance.toStringAsFixed(0)} km';
  String averageFuelFormatted() => '${averageFuel.toStringAsFixed(2)} l';
  String averageCostFormatted() => '${averageCost.toStringAsFixed(2)} zł';
}
