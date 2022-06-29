import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:fl_toast/fl_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mailer/flutter_mailer.dart';
import 'package:ml_algo/ml_algo.dart';
// ignore: implementation_imports
import 'package:ml_algo/src/model_selection/assessable.dart';
import 'package:ml_dataframe/ml_dataframe.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smart_car/feautures/trip_score/trip_dataset_model.dart';
import 'package:smart_car/pages/machine_learning/bloc/dataset_state.dart';
import 'package:smart_car/services/firestore_handler.dart';
import 'package:ml_preprocessing/ml_preprocessing.dart';

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
      final items = list.where((element) => element.isSame(_model)).toList();
      print('Podobne elementy: ${items.length}');
      if (items.length > 1) {
        await showAndroidToast(
          child: Text('Podobne elementy: ${items.length}'),
          context: ToastProvider.context,
          duration: Duration(seconds: 2),
          alignment: Alignment.center,
        );
      }
      for (final item in items) {
        final index = list.indexWhere((element) => element.id == item.id);
        list[index] = item.copyWith(
          ecoScore: state.ecoScore.toDouble(),
          smoothScore: state.smoothScore.toDouble(),
        );
      }
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
    final _ecoClassifier = ecoClassifierFunc(ecoTestSplits[0]);

    final ecoFinalScore =
        _ecoClassifier.assess(ecoTestData, MetricType.accuracy);
    messages.add('Cost per iteration: ${_ecoClassifier}');
    messages.add(ecoFinalScore.toStringAsFixed(2));
    emit(state.copyWith(learningStep: 5, messages: messages));

    /// Smooth learning
    // final smoothRows = state.dataset
    //     .map(
    //       (e) => e.datasets
    //           .where((e) => e.isReadyToLearn)
    //           .map((e) => e.toSmoothRow)
    //           .toList(),
    //     )
    //     .expand((e) => e)
    //     .toList();
    // final smoothFrame = DataFrame(
    //   smoothRows,
    //   headerExists: false,
    //   header: TripDatasetModelExtension.ecoRowHeaders,
    // );
    // emit(state.copyWith(learningStep: 6));
    // final smoothSplits = splitData(smoothFrame.shuffle(), [0.7]);
    // final smoothValidationData = smoothSplits[0];
    // final smoothTestData = smoothSplits[1];

    // final smoothValidator = CrossValidator.kFold(
    //   smoothValidationData,
    //   numberOfFolds: 5,
    // );
    // emit(state.copyWith(learningStep: 7));

    // final smoothScores = await smoothValidator.evaluate(
    //     smoothClassifierFunc, MetricType.accuracy);
    // final smoothAccuracy = smoothScores.mean();
    // messages.add(
    //     'accuracy on k fold validation: ${smoothAccuracy.toStringAsFixed(2)}');
    // emit(state.copyWith(learningStep: 8, messages: messages));
    // final smoothTestSplits = splitData(smoothTestData, [0.8]);
    // final smoothClassifier = smoothClassifierFunc(smoothTestSplits[0]);
    // final smoothFinalScore =
    //     smoothClassifier.assess(smoothTestSplits[1], MetricType.accuracy);
    // messages.add(smoothFinalScore.toStringAsFixed(2));
    emit(state.copyWith(
      learningStep: 9,
      messages: messages,
      isLearning: false,
    ));
  }

  Assessable ecoClassifierFunc(DataFrame frame) {
    return LogisticRegressor(
      frame,
      TripDatasetModelExtension.ecoRowHeaders.last,
      // iterationsLimit: 200,
      initialLearningRate: 0.00001,
      collectLearningData: true,
      // probabilityThreshold: 0.5,
    );
  }

  Assessable smoothClassifierFunc(DataFrame frame) {
    return LogisticRegressor(
      frame,
      TripDatasetModelExtension.ecoRowHeaders.last,
      iterationsLimit: 300,
      learningRateType: LearningRateType.timeBased,
      probabilityThreshold: 0.5,
    );
  }

  Future<void> learnDecissionTree() async {
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

    final ecoSplits = splitData(ecoFrame.shuffle(), [0.7]);

    final model = DecisionTreeClassifier(
      ecoSplits[0],
      'eco_score',
      minError: 0.3,
      minSamplesCount: 5,
      maxDepth: 10,
    );

    final value = model.assess(ecoSplits[1], MetricType.accuracy);

    print('Result tree: $value');

    Directory appDocDir = await getApplicationDocumentsDirectory();
    final now = DateTime.now();
    final path = '${appDocDir.path}/model${now.toString()}.json';

    final file = await model.saveAsJson(path);
    await sendTripsToMail([file.path]);
  }

  Future<void> sendTripsToMail(List<String> files) async {
    final mailOptions = MailOptions(
      body: 'Drzewo',
      subject: 'Schemat drzewa',
      recipients: ['hunteelar.programowanie@gmail.com'],
      isHTML: true,
      attachments: files,
    );

    await FlutterMailer.send(mailOptions);
    for (final path in files) {
      final file = File(path);
      file.delete();
    }
  }
}
