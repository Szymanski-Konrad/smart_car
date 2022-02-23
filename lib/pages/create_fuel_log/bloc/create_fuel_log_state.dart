import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smart_car/models/coordinates.dart';

part 'create_fuel_log_state.freezed.dart';

@freezed
class CreateFuelLogState with _$CreateFuelLogState {
  const factory CreateFuelLogState({
    required double odometer,
    required double fuelPrice,
    required double fuelAmount,
    required double totalPrice,
    required DateTime dateTime,
    @Default(true) bool isFullTank,
    Coordinates? coordinates,
  }) = _CreateFuelLogState;
}

extension CreateFuelLogStateExtension on CreateFuelLogState {
  static CreateFuelLogState get initial => CreateFuelLogState(
        odometer: 0.0,
        fuelPrice: 5.5,
        fuelAmount: 0.0,
        totalPrice: 0.0,
        dateTime: DateTime.now(),
      );
}
