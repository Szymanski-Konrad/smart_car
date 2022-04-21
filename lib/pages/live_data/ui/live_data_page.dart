import 'package:flutter/material.dart';
// ignore: implementation_imports
import 'package:provider/src/provider.dart';
import 'package:smart_car/app/navigation/navigation.dart';
import 'package:smart_car/app/navigation/routes.dart';
import 'package:smart_car/app/resources/pids.dart';
import 'package:smart_car/app/resources/strings.dart';
import 'package:smart_car/pages/live_data/bloc/live_data_cubit.dart';
import 'package:smart_car/pages/live_data/bloc/live_data_state.dart';
import 'package:smart_car/pages/live_data/ui/live_stats_section.dart';
import 'package:smart_car/pages/live_data/ui/trip_stats_section.dart';
import 'package:smart_car/pages/settings/bloc/settings_cubit.dart';
import 'package:smart_car/utils/route_argument.dart';
import 'package:smart_car/utils/scoped_bloc_builder.dart';
import 'package:smart_car/utils/trip_files.dart';

class LiveDataPageArguments {
  LiveDataPageArguments({this.isLocalMode = false});

  final bool isLocalMode;
}

class LiveDataPage extends StatelessWidget
    with RouteArgument<LiveDataPageArguments> {
  const LiveDataPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLocalMode = getArgument(context).isLocalMode;
    final address = isLocalMode
        ? null
        : context.read<SettingsCubit>().state.settings.deviceAddress;
    final fuelPrice = context.read<SettingsCubit>().state.settings.fuelPrice;
    final localFile = context.read<SettingsCubit>().state.settings.selectedJson;
    final tankSize = context.read<SettingsCubit>().state.settings.tankSize;
    return ScopedListenerBlocBuilder<LiveDataCubit, LiveDataState>(
      create: (_) => LiveDataCubit(
        address: address,
        localFile: localFile,
        fuelPrice: fuelPrice,
        tankSize: tankSize,
      ),
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errors.last),
          ),
        );
      },
      listenWhen: (previous, current) {
        return previous.errors.length < current.errors.length;
      },
      builder: (context, state, cubit) {
        return state.isConnnectingError
            ? Scaffold(
                appBar: AppBar(),
                body: const Center(
                  child: Text(Strings.cannotConnect),
                ),
              )
            : Scaffold(
                appBar: AppBar(
                  title: Text(
                    state.isLocalMode
                        ? Strings.progress(state.localTripProgress)
                        : state.isConnecting
                            ? Strings.connecting
                            : Strings.connected,
                  ),
                  actions: [
                    if (state.supportedPids.isNotEmpty)
                      IconButton(
                        onPressed: () => showSupportedCommandsDialog(
                            context, state.supportedPids, cubit, state),
                        icon: const Icon(Icons.list),
                      )
                  ],
                ),
                body: SafeArea(
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        const TabBar(
                          tabs: [
                            Tab(text: Strings.liveData),
                            Tab(text: Strings.tripStats),
                          ],
                        ),
                        const SizedBox(height: 20.0),
                        Expanded(
                          child: TabBarView(
                            children: [
                              LiveStatsSection(state: state, cubit: cubit),
                              TripStatsSection(state: state, cubit: cubit),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
      },
    );
  }

  void showSupportedCommandsDialog(
    BuildContext context,
    List<String> pids,
    LiveDataCubit cubit,
    LiveDataState state,
  ) {
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              actions: [
                ElevatedButton(
                    onPressed: () => cubit.listenAllPids(pids),
                    child: const Text('Send')),
              ],
              title: Text(
                Strings.supportedCommandsCount(
                    cubit.commands.length, pids.length),
              ),
              content: SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                width: MediaQuery.of(context).size.width * 0.5,
                child: ListView.builder(
                  itemCount: pids.length,
                  itemBuilder: (context, index) {
                    final pid = pids[index].substring(pids[index].length - 2);
                    final value = cubit.commands
                        .any((command) => command.command == pids[index]);
                    final isUntouchable = untouchableCommads.contains(pid);
                    return CheckboxListTile(
                      value: value,
                      onChanged: !isUntouchable //&& state.isLocalMode
                          ? (value) {
                              if (value != null) {
                                cubit.editCommandList(value, pids[index]);
                                setState.call(() {});
                              }
                            }
                          : null,
                      title: Text(pid),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child:
                            Text(pidsDescription[pid] ?? Strings.noDescription),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
