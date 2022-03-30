import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smart_car/models/trip_summary/trip_summary.dart';

part 'trip_summary_state.freezed.dart';

@freezed
class TripSummaryState with _$TripSummaryState {
  const factory TripSummaryState({
    @Default([]) List<TripSummary> trips,
  }) = _TripSummary;
}

extension TripSummaryStateExtension on TripSummaryState {}
