import 'package:freezed_annotation/freezed_annotation.dart';

part 'can_test_state.freezed.dart';

@freezed
class CanTestState with _$CanTestState {
  factory CanTestState({
    @Default([]) List<String> results,
  }) = _CanTestState;
}
