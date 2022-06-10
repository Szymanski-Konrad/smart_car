import 'package:bloc/bloc.dart';
import 'package:smart_car/feautures/trip_score/trip_dataset_model.dart';
import 'package:smart_car/pages/machine_learning/bloc/learning_state.dart';
import 'package:smart_car/services/firestore_handler.dart';

class LearningCubit extends Cubit<LearningState> {
  LearningCubit() : super(LearningState());

  Future<void> loadDataset() async {
    emit(state.copyWith(isLoading: true));
    final dataset = await FirestoreHandler.fetchTripDatasets();
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
        ecoScore: state.ecoScore,
        aggresiveScore: state.aggresiveScore,
      );
      print(
          'Eco score: ${state.ecoScore}, Aggresive score: ${state.aggresiveScore}, id: ${model.id}');
      await FirestoreHandler.saveTripDataset(model);
      final list = List<TripDatasetModel>.from(state.dataset);
      list.removeWhere((element) => element.id == model.id);
      emit(state.copyWith(dataset: list));
    }

    changeModelToModify();
  }

  void resetScores() {
    emit(state.copyWith(
      ecoScore: -1,
      aggresiveScore: -1,
    ));
  }

  void changeEcoScore(String value) {
    final score = double.tryParse(value);
    if (score != null) {
      emit(state.copyWith(ecoScore: score));
    }
  }

  void changeAggresiveScore(String value) {
    final score = double.tryParse(value);
    if (score != null) {
      emit(state.copyWith(aggresiveScore: score));
    }
  }

  void changeModelToModify() {
    emit(state.copyWith(modelToModify: state.modelsToModify.first));
    resetScores();
  }
}
