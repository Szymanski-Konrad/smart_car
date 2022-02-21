import 'package:flutter/material.dart';
import 'package:smart_car/app/resources/strings.dart';
import 'package:smart_car/pages/fuel_logs/bloc/fuel_logs_cubit.dart';
import 'package:smart_car/pages/fuel_logs/bloc/fuel_logs_state.dart';
import 'package:smart_car/utils/scoped_bloc_builder.dart';
import 'package:smart_car/utils/ui/fuel_log_card.dart';

class FuelLogsPage extends StatelessWidget {
  const FuelLogsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScopedBlocBuilder<FuelLogsCubit, FuelLogsState>(
      listener: (context, state) {},
      listenWhen: (_, __) => false,
      create: (_) => FuelLogsCubit(),
      builder: (context, state, cubit) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Dziennik tankowań'),
            centerTitle: true,
          ),
          body: state.logs.isEmpty
              ? _buildNoContent(context, cubit)
              : _buildContent(context, state, cubit),
          floatingActionButton: FloatingActionButton(
            onPressed: cubit.createNewLog,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildNoContent(
    BuildContext context,
    FuelLogsCubit cubit,
  ) {
    return Center(
      child: Column(
        children: [
          const Text(Strings.addYourFirstLog),
          ElevatedButton(
            onPressed: cubit.createNewLog,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    FuelLogsState state,
    FuelLogsCubit cubit,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      itemCount: state.logs.length,
      itemBuilder: (context, index) {
        final log = state.logs[index];
        return FuelLogCard(fuelLog: log);
      },
    );
  }
}
