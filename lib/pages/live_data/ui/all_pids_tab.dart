import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_car/app/blocs/global_bloc.dart';
import 'package:smart_car/app/resources/pids.dart';
import 'package:smart_car/pages/live_data/bloc/live_data_cubit.dart';
import 'package:smart_car/pages/live_data/bloc/live_data_state.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';
import 'package:smart_car/utils/list_extension.dart';

class AllPidsTab extends StatelessWidget {
  const AllPidsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LiveDataCubit, LiveDataState>(
      bloc: GlobalBlocs.liveData,
      buildWhen: (p, n) => p.supportedPids.length != n.supportedPids.length,
      builder: (context, state) {
        final cubit = GlobalBlocs.liveData;
        final pids = List<String>.from(state.supportedPids)..sort();

        return pids.isEmpty
            ? const Center(child: Text('No supported PIDs'))
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: pids.length,
                itemBuilder: (context, index) {
                  final fullPid = pids[index];
                  final pid = fullPid.length >= 2
                      ? fullPid.substring(fullPid.length - 2)
                      : fullPid;

                  final command = cubit.commands.safeFirstWhere(
                    (c) => c.command == fullPid,
                  );

                  final description = pidsDescription[pid] ?? 'No description';

                  String valueText = '-';
                  String? reactionTime;

                  if (command is VisibleObdCommand) {
                    valueText = command.formattedResult;
                    reactionTime = command.formattedReactionTime;
                  } else if (command != null && command.result.isFinite) {
                    valueText = command.result.toString();
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Card(
                      elevation: 0,
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        dense: true,
                        title: Text(
                          '$fullPid  •  $description',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: reactionTime == null
                            ? null
                            : Text(reactionTime),
                        trailing: Text(
                          valueText,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  );
                },
              );
      },
    );
  }
}
