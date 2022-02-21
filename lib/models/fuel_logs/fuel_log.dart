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
    required double odometerDiff,
    double? remainingFuel,
    double? fuelEfficiency,
    @Default(false) bool isRemainingFuelKnown,
    @Default(true) bool isFull,
    Coordinates? location,
  }) = _FuelLog;
}

extension FuelLogExtension on FuelLog {
  String get showOdometerDiff => '+ ${odometerDiff.showSpaced} km';
  String get showFuelPrice => '$fuelPrice zł';
  String get showTotalPrice => '$totalPrice zł';
  String get showOdometer => '${odometer.showSpaced} km';
}
