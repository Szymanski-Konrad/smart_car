import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smart_car/feautures/trip_score/trip_dataset_model.dart';

part 'learning_state.freezed.dart';

@freezed
class LearningState with _$LearningState {
  factory LearningState({
    @Default(false) bool isLoading,
    @Default(false) bool isLearning,
    @Default([]) List<TripDatasetModel> dataset,
    TripDatasetModel? modelToModify,
    @Default(-1) double ecoScore,
    @Default(-1) double aggresiveScore,
  }) = _LearningState;
}

extension LearningStateExtenision on LearningState {
  List<TripDatasetModel> get modelsToModify =>
      dataset.where((element) => element.ecoScore == -1).toList();

  int get modifyCount => modelsToModify.length;
}
