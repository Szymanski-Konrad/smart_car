import 'package:flutter/material.dart';
import 'package:smart_car/feautures/trip_score/trip_dataset_model.dart';
import 'package:smart_car/pages/machine_learning/bloc/learning_cubit.dart';
import 'package:smart_car/pages/machine_learning/bloc/learning_state.dart';
import 'package:smart_car/utils/scoped_bloc_builder.dart';

class LearningPage extends StatelessWidget {
  const LearningPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScopedBlocBuilder<LearningCubit, LearningState>(
      create: (_) => LearningCubit()..loadDataset(),
      builder: (context, state, cubit) {
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
        final ecoText = state.ecoScore >= 0.0 ? state.ecoScore.toString() : '';
        final aggresiveText =
            state.aggresiveScore >= 0.0 ? state.aggresiveScore.toString() : '';
        return Scaffold(
          appBar: AppBar(
            title: Text('${state.modifyCount} elementów'),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '${state.modelToModify?.formattedPrint}',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        onChanged: cubit.changeEcoScore,
                        controller: TextEditingController(text: ecoText),
                        decoration: InputDecoration(
                          labelText: 'Eco score',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        onChanged: cubit.changeAggresiveScore,
                        controller: TextEditingController(text: aggresiveText),
                        decoration: InputDecoration(
                          labelText: 'Aggresive score',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: cubit.saveData,
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
