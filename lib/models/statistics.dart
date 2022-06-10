import 'package:freezed_annotation/freezed_annotation.dart';

part 'statistics.freezed.dart';
part 'statistics.g.dart';

@freezed
class Statistics with _$Statistics {
  factory Statistics({
    @Default(0) double fuelUsed,
    @Default(0) double distance,
    @Default(0) double refuelingConsumption,
    @Default(0) double range,
  }) = _Statistics;

  factory Statistics.fromJson(Map<String, dynamic> json) =>
      _$StatisticsFromJson(json);
}

extension StatisticsExtension on Statistics {
  double get avgConsumption => fuelUsed * 100 / distance;
  double get consumptionScale => refuelingConsumption / avgConsumption;
}
