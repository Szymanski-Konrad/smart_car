import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_car/app/blocs/global_bloc.dart';
import 'package:smart_car/feautures/trip_score/trip_dataset_model.dart';
import 'package:smart_car/pages/machine_learning/bloc/dataset_cubit.dart';
import 'package:smart_car/pages/machine_learning/bloc/dataset_state.dart';

class DatasetPage extends StatelessWidget {
  const DatasetPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DatasetCubit, DatasetState>(
      bloc: GlobalBlocs.learning..loadDataset(),
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        final _model = state.modelToModify;
        if (_model == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: Text('Brak nowych danych'),
            ),
          );
        }
        final ecoText = state.ecoScore >= 0 ? state.ecoScore.toString() : '';
        final smoothText =
            state.smoothScore >= 0 ? state.smoothScore.toString() : '';
        final ecoController = TextEditingController(text: ecoText);
        ecoController.selection = TextSelection.fromPosition(
            TextPosition(offset: ecoController.text.length));
        final smoothController = TextEditingController(text: smoothText);
        smoothController.selection = TextSelection.fromPosition(
            TextPosition(offset: smoothController.text.length));
        return Scaffold(
          appBar: AppBar(
            title: Text('${state.notReadyToLearnCount} elementów'),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ..._model.rawDataFormatted
                    .map(((e) => Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          child: Text(
                            e,
                            style: const TextStyle(fontSize: 16),
                          ),
                        )))
                    .toList(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        onChanged: GlobalBlocs.learning.changeEcoScore,
                        controller: ecoController,
                        decoration: const InputDecoration(
                          labelText: 'Eco score',
                        ),
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        onChanged: GlobalBlocs.learning.changeSmoothScore,
                        controller: smoothController,
                        decoration: const InputDecoration(
                          labelText: 'Smooth score',
                        ),
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: GlobalBlocs.learning.saveData,
                  child: const Text('Zapisz'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
