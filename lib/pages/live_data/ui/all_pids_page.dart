import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_car/app/blocs/global_bloc.dart';
import 'package:smart_car/app/resources/pids.dart';
import 'package:smart_car/pages/live_data/bloc/live_data_cubit.dart';
import 'package:smart_car/pages/live_data/bloc/live_data_state.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';
import 'package:smart_car/utils/list_extension.dart';

class AllPidsPage extends StatelessWidget {
  const AllPidsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LiveDataCubit, LiveDataState>(
      bloc: GlobalBlocs.liveData,
      builder: (context, state) {
        final cubit = GlobalBlocs.liveData;
        final pids = List<String>.from(state.supportedPids)..sort();

        return Scaffold(
          appBar: AppBar(title: Text('All PIDs (${pids.length})')),
          body: pids.isEmpty
              ? const Center(child: Text('No supported PIDs'))
              : ListView.separated(
                  itemCount: pids.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final fullPid = pids[index];
                    final pid = fullPid.substring(fullPid.length - 2);

                    final command = cubit.commands.safeFirstWhere(
                      (c) => c.command == fullPid,
                    );

                    final description =
                        pidsDescription[pid] ?? 'No description';

                    String valueText = '-';
                    String? reactionTime;

                    if (command is VisibleObdCommand) {
                      valueText = command.formattedResult;
                      reactionTime = command.formattedReactionTime;
                    } else if (command != null && command.result.isFinite) {
                      valueText = command.result.toString();
                    }

                    return ListTile(
                      title: Text(
                        '$fullPid  •  $description',
                        style: TextStyle(fontSize: 16),
                      ),
                      subtitle: reactionTime == null
                          ? null
                          : Text(reactionTime, style: TextStyle(fontSize: 12)),
                      trailing: Text(valueText, style: TextStyle(fontSize: 18)),
                    );
                  },
                ),
        );
      },
    );
  }
}
