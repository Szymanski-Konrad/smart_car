import 'package:flutter/material.dart';
import 'package:smart_car/app/resources/strings.dart';
import 'package:smart_car/pages/live_data/bloc/live_data_cubit.dart';
import 'package:smart_car/pages/live_data/bloc/live_data_state.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';
import 'package:smart_car/pages/live_data/ui/live_data_tile.dart';

class LiveStatsSection extends StatelessWidget {
  const LiveStatsSection({
    Key? key,
    required this.state,
    required this.cubit,
  }) : super(key: key);

  final LiveDataState state;
  final LiveDataCubit cubit;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Wrap(
        runSpacing: 8.0,
        spacing: 8.0,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(Strings.avgResponse(state.averageResponseTime)),
              Text(Strings.totalResponse(state.totalResponseTime)),
            ],
          ),
          if (cubit.commands.isNotEmpty)
            ...cubit.commands
                .whereType<VisibleObdCommand>()
                .map((command) => LiveDataTile(command: command))
                .toList(),
          const SizedBox(
            height: 20.0,
            width: double.infinity,
          ),
          ...state.errors.map((e) => ListTile(title: Text(e))),
        ],
      ),
    );
  }
}
