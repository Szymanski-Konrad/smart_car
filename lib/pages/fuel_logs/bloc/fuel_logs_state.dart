import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smart_car/models/fuel_logs/fuel_log.dart';

part 'fuel_logs_state.freezed.dart';

@freezed
class FuelLogsState with _$FuelLogsState {
  factory FuelLogsState({
    @Default([]) List<FuelLog> logs,
  }) = _FuelLogsState;
}
