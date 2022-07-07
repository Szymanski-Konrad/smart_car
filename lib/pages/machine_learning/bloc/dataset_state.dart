import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smart_car/feautures/trip_score/trip_dataset_model.dart';

part 'dataset_state.freezed.dart';

@freezed
class DatasetState with _$DatasetState {
  factory DatasetState({
    // Learning
    @Default(false) bool isLearning,
    @Default(0) int learningStep,
    @Default([]) List<String> messages,
    @Default(false) bool isLoading,

    // Dataset
    @Default([]) List<DatasetsDocument> dataset,
    @Default([]) List<TripDatasetModel> tempModels,
    TripDatasetModel? modelToModify,
    @Default(0) int documentIndex,
    @Default(-1) int ecoScore,
    @Default(-1) int smoothScore,
  }) = _DatasetState;
}

extension DatasetStateExtenision on DatasetState {
  DatasetsDocument get documentToModify => dataset[documentIndex];
  List<TripDatasetModel> get modelsToModify => dataset[documentIndex]
      .datasets
      .where((element) => !element.isReadyToLearn)
      .toList();

  int get modifyCount => modelsToModify.length;
  bool get isDatasetEnd => documentIndex >= dataset.length;

  int get notReadyToLearnCount {
    int count = 0;
    for (final document in dataset) {
      count +=
          document.datasets.where((element) => !element.isReadyToLearn).length;
    }
    return count;
  }

  int get readyToLearnCount {
    int count = 0;
    for (final document in dataset) {
      count +=
          document.datasets.where((element) => element.isReadyToLearn).length;
    }
    return count;
  }

  List<List<dynamic>> get ecoRows => dataset
      .map(
        (e) => e.datasets
            .where((e) => e.isReadyToLearn)
            .map((e) => e.toEcoRow)
            .toList(),
      )
      .expand((e) => e)
      .toList();

  List<List<dynamic>> get smoothRows => dataset
      .map(
        (e) => e.datasets
            .where((e) => e.isReadyToLearn)
            .map((e) => e.toSmoothRow)
            .toList(),
      )
      .expand((e) => e)
      .toList();
}
