import 'package:freezed_annotation/freezed_annotation.dart';

part 'fuel_info.freezed.dart';
part 'fuel_info.g.dart';

@freezed
class FuelInfo with _$FuelInfo {
  factory FuelInfo({
    required double price,
    required DateTime changeDate,
  }) = _FuelInfo;

  factory FuelInfo.empty() {
    return FuelInfo(price: 0.0, changeDate: DateTime.now());
  }

  factory FuelInfo.price(double price) {
    return FuelInfo(price: price, changeDate: DateTime.now());
  }

  factory FuelInfo.fromJson(Map<String, dynamic> json) =>
      _$FuelInfoFromJson(json);
}
