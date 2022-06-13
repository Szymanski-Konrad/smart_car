import 'package:bloc/bloc.dart';
import 'package:ml_algo/ml_algo.dart';
// ignore: implementation_imports
import 'package:ml_algo/src/model_selection/assessable.dart';
import 'package:ml_dataframe/ml_dataframe.dart';
import 'package:smart_car/feautures/trip_score/trip_dataset_model.dart';
import 'package:smart_car/pages/machine_learning/bloc/dataset_state.dart';
import 'package:smart_car/services/firestore_handler.dart';

class DatasetCubit extends Cubit<DatasetState> {
  DatasetCubit() : super(DatasetState());

  Future<void> loadDataset() async {
    emit(state.copyWith(isLoading: true));
    final dataset = await FirestoreHandler.fetchDatasets();
    emit(state.copyWith(
      isLoading: false,
      dataset: dataset,
    ));

    changeModelToModify();
  }

  Future<void> saveData() async {
    final _model = state.modelToModify;
    if (_model != null) {
      final model = _model.copyWith(
        ecoScore: state.ecoScore.toDouble(),
        smoothScore: state.smoothScore.toDouble(),
      );

      final list = List<TripDatasetModel>.from(state.documentToModify.datasets)
          .toSet()
          .toList();
      final index = list.indexWhere((element) => element.id == _model.id);
      list[index] = model;
      final datasetList = List<DatasetsDocument>.from(state.dataset);
      final document = state.documentToModify.copyWith(datasets: list);
      datasetList[state.documentIndex] = document;
      emit(state.copyWith(dataset: datasetList));
      print('saving trip dataset');
      await FirestoreHandler.saveTripDataset(document);
    }

    changeModelToModify();
  }

  void resetScores() {
    emit(state.copyWith(
      ecoScore: -1,
      smoothScore: -1,
    ));
  }

  void changeEcoScore(String value) {
    final score = int.tryParse(value);
    if (score != null) {
      if (score > 100) return;
      emit(state.copyWith(ecoScore: score));
    }
  }

  void changeSmoothScore(String value) {
    final score = int.tryParse(value);
    if (score != null) {
      if (score > 100) return;
      emit(state.copyWith(smoothScore: score));
    }
  }

  Future<void> changeModelToModify() async {
    while (state.modelsToModify.isEmpty && !state.isDatasetEnd) {
      emit(state.copyWith(documentIndex: state.documentIndex + 1));
    }

    if (state.modelsToModify.isNotEmpty) {
      emit(state.copyWith(modelToModify: state.modelsToModify.first));
    } else {
      emit(state.copyWith(modelToModify: null));
    }
    resetScores();
  }

  Future<void> learn() async {
    final messages = <String>[];
    emit(state.copyWith(isLearning: true, messages: [], learningStep: 0));

    /// Eco learning
    final ecoRows = state.dataset
        .map(
          (e) => e.datasets
              .where((e) => e.isReadyToLearn)
              .map((e) => e.toEcoRow)
              .toList(),
        )
        .expand((e) => e)
        .toList();
    final ecoFrame = DataFrame(
      ecoRows,
      headerExists: false,
      header: TripDatasetModelExtension.ecoRowHeaders,
    );
    emit(state.copyWith(learningStep: 1));
    final ecoSplits = splitData(ecoFrame.shuffle(), [0.7]);
    final ecoValidationData = ecoSplits[0];
    final ecoTestData = ecoSplits[1];
    emit(state.copyWith(learningStep: 2));

    final ecoValidator = CrossValidator.kFold(
      ecoValidationData,
      numberOfFolds: 5,
    );
    emit(state.copyWith(learningStep: 3));

    final ecoScores =
        await ecoValidator.evaluate(ecoClassifierFunc, MetricType.accuracy);
    final ecoAccuracy = ecoScores.mean();
    messages.add(
        'accuracy on k fold validation: ${ecoAccuracy.toStringAsFixed(2)}');
    emit(state.copyWith(learningStep: 4, messages: messages));
    final ecoTestSplits = splitData(ecoTestData, [0.8]);
    final ecoClassifier = ecoClassifierFunc(ecoTestSplits[0]);
    final ecoFinalScore =
        ecoClassifier.assess(ecoTestSplits[1], MetricType.accuracy);
    messages.add(ecoFinalScore.toStringAsFixed(2));
    emit(state.copyWith(learningStep: 5, messages: messages));

    /// Smooth learning
    final smoothRows = state.dataset
        .map(
          (e) => e.datasets
              .where((e) => e.isReadyToLearn)
              .map((e) => e.toSmoothRow)
              .toList(),
        )
        .expand((e) => e)
        .toList();
    final smoothFrame = DataFrame(
      smoothRows,
      headerExists: false,
      header: TripDatasetModelExtension.ecoRowHeaders,
    );
    emit(state.copyWith(learningStep: 6));
    final smoothSplits = splitData(smoothFrame.shuffle(), [0.7]);
    final smoothValidationData = smoothSplits[0];
    final smoothTestData = smoothSplits[1];

    final smoothValidator = CrossValidator.kFold(
      smoothValidationData,
      numberOfFolds: 5,
    );
    emit(state.copyWith(learningStep: 7));

    final smoothScores = await smoothValidator.evaluate(
        smoothClassifierFunc, MetricType.accuracy);
    final smoothAccuracy = smoothScores.mean();
    messages.add(
        'accuracy on k fold validation: ${smoothAccuracy.toStringAsFixed(2)}');
    emit(state.copyWith(learningStep: 8, messages: messages));
    final smoothTestSplits = splitData(smoothTestData, [0.8]);
    final smoothClassifier = smoothClassifierFunc(smoothTestSplits[0]);
    final smoothFinalScore =
        smoothClassifier.assess(smoothTestSplits[1], MetricType.accuracy);
    messages.add(smoothFinalScore.toStringAsFixed(2));
    emit(
        state.copyWith(learningStep: 9, messages: messages, isLearning: false));
  }

  Assessable ecoClassifierFunc(DataFrame frame) {
    return LogisticRegressor(
      frame,
      TripDatasetModelExtension.ecoRowHeaders.last,
      iterationsLimit: 90,
      learningRateType: LearningRateType.timeBased,
      probabilityThreshold: 0.7,
    );
  }

  Assessable smoothClassifierFunc(DataFrame frame) {
    return LogisticRegressor(
      frame,
      TripDatasetModelExtension.ecoRowHeaders.last,
      iterationsLimit: 90,
      learningRateType: LearningRateType.timeBased,
      probabilityThreshold: 0.7,
    );
  }
}
