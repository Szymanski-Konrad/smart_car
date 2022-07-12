import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:fl_toast/fl_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mailer/flutter_mailer.dart';
import 'package:ml_algo/ml_algo.dart';
import 'package:ml_dataframe/ml_dataframe.dart';
import 'package:path_provider/path_provider.dart';
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
      final items = list.where((element) => element.isSame(_model)).toList();
      if (items.length > 1) {
        await showAndroidToast(
          child: Text('Podobne elementy: ${items.length}'),
          context: ToastProvider.context,
          duration: const Duration(seconds: 2),
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

  LinearRegressor classifierFunc(DataFrame frame, String target) {
    return LinearRegressor(
      frame,
      target,
      iterationsLimit: 900,
      learningRateType: LearningRateType.exponential,
      collectLearningData: true,
    );
  }

  Future<void> _learn(
    DataFrame dataFrame,
    String target, {
    MetricType metricType = MetricType.rmse,
  }) async {
    final messages = List<String>.from(state.messages);
    final splits = splitData(dataFrame.shuffle(), [0.7]);
    final validationData = splits[0];
    final testData = splits[1];

    final validator = CrossValidator.kFold(
      validationData,
      numberOfFolds: 5,
    );

    final score = await validator.evaluate(
      (frame) => classifierFunc(
        frame,
        target,
      ),
      metricType,
    );
    final accuracy = score.mean();
    messages.add(
        'accuracy on k fold validation $target : ${accuracy.toStringAsFixed(4)}');
    emit(state.copyWith(messages: messages));
    final testSplits = splitData(testData, [0.8]);
    final _classifier = classifierFunc(testSplits[0], target);
    final finalScore = _classifier.assess(testSplits[1], metricType);
    messages.add('Cost per iteration: $_classifier');
    messages.add('Final score: ${finalScore.toStringAsFixed(4)}');
    messages.add('');
    emit(state.copyWith(messages: messages));
  }

  String frameToString(DataFrame frame) {
    final rows = frame.rows.map((e) => e.join(','));
    return rows.join('\n');
  }

  Future<void> learn() async {
    print('Start learning');
    emit(state.copyWith(isLearning: true, messages: [], learningStep: 0));
    final ecoFrame = DataFrame(
      state.ecoRows,
      headerExists: false,
      header: TripDatasetModelExtension.ecoRowHeaders,
    );

    final smoothFrame = DataFrame(
      state.smoothRows,
      headerExists: false,
      header: TripDatasetModelExtension.smoothRowHeaders,
    );

    final smoothTarget = TripDatasetModelExtension.smoothRowHeaders.last;
    final ecoTarget = TripDatasetModelExtension.ecoRowHeaders.last;
    final _frame = getPimaIndiansDiabetesDataFrame();
    const _targetColumnName = 'Outcome';
    await _learn(ecoFrame, ecoTarget);
    await _learn(smoothFrame, smoothTarget);
    await _learn(_frame, _targetColumnName);

    emit(state.copyWith(
      learningStep: 9,
      isLearning: false,
    ));
  }

  Future<void> learnTrees() async {
    await learnEcoTree();
    await learnSmoothTree();
  }

  Future<void> learnEcoTree() async {
    /// Eco learning
    final ecoFrame = DataFrame(
      state.ecoRows,
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
    print('Eco tree value: $value');
    Directory appDocDir = await getApplicationDocumentsDirectory();
    final now = DateTime.now();
    final path = '${appDocDir.path}/ecoTree${now.toString()}.json';
    final file = await model.saveAsJson(path);
    await sendTripsToMail([file.path]);
  }

  Future<void> learnSmoothTree() async {
    /// Eco learning
    final smoothFrame = DataFrame(
      state.smoothRows,
      headerExists: false,
      header: TripDatasetModelExtension.smoothRowHeaders,
    );

    final smoothSplits = splitData(smoothFrame.shuffle(), [0.7]);

    final model = DecisionTreeClassifier(
      smoothSplits[0],
      'smooth_score',
      minError: 0.3,
      minSamplesCount: 5,
      maxDepth: 10,
    );

    final value = model.assess(smoothSplits[1], MetricType.accuracy);
    print('Smooth tree value: $value');
    Directory appDocDir = await getApplicationDocumentsDirectory();
    final now = DateTime.now();
    final path = '${appDocDir.path}/smoothTree${now.toString()}.json';
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

  Future<void> sendDataToMail(String body, String dataType) async {
    final mailOptions = MailOptions(
      body: body,
      subject: 'Dane: $dataType',
      recipients: ['hunteelar.programowanie@gmail.com'],
      isHTML: true,
    );

    await FlutterMailer.send(mailOptions);
  }
}
