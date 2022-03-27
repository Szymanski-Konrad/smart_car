import 'package:flutter/material.dart';
import 'package:smart_car/app/blocs/global_bloc.dart';
import 'package:smart_car/app/resources/strings.dart';
import 'package:smart_car/pages/fuel_logs/bloc/fuel_logs_cubit.dart';
import 'package:smart_car/pages/fuel_logs/bloc/fuel_logs_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_car/utils/ui/fuel_log_card.dart';
import 'package:smart_car/utils/ui/fuel_stats_card.dart';

class FuelLogsPage extends StatelessWidget {
  const FuelLogsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FuelLogsCubit, FuelLogsState>(
      bloc: GlobalBlocs.fuelLogs,
      builder: (context, state) {
        final cubit = GlobalBlocs.fuelLogs;
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
    return SingleChildScrollView(
      child: Column(
        children: [
          FuelStatsCard(logs: state.logs),
          const SizedBox(height: 32.0),
          ...state.logs.reversed.map((log) => FuelLogCard(fuelLog: log)),
        ],
      ),
    );
  }
}
