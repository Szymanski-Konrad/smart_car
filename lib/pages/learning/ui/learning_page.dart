import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_car/app/blocs/global_bloc.dart';
import 'package:smart_car/pages/machine_learning/bloc/dataset_cubit.dart';
import 'package:smart_car/pages/machine_learning/bloc/dataset_state.dart';

class LearningPage extends StatelessWidget {
  const LearningPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Uczenie maszynowe'),
        centerTitle: true,
      ),
      body: BlocBuilder<DatasetCubit, DatasetState>(
        bloc: GlobalBlocs.learning,
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Elementy gotowe do nauki: ${state.readyToLearnCount}'),
              ElevatedButton(
                onPressed: GlobalBlocs.learning.learn,
                child: const Text('Learn'),
              ),
              if (state.isLearning) const Text('Learning...'),
              if (state.isLearning) Text('Step ${state.learningStep} of 9'),
              ...state.messages.map((e) => Text(e)).toList(),
            ],
          );
        },
      ),
    );
  }
}
