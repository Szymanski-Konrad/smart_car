import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:smart_car/app/resources/pids.dart';
import 'package:smart_car/pages/live_data/bloc/live_data_cubit.dart';
import 'package:smart_car/pages/live_data/bloc/live_data_state.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';
import 'package:smart_car/pages/live_data/model/fuel_system_status_command.dart';
import 'package:smart_car/pages/live_data/ui/live_data_tile.dart';
import 'package:smart_car/pages/live_data/ui/supported_pids_tile.dart';
import 'package:smart_car/pages/live_data/ui/trip_tile.dart';
import 'package:smart_car/utils/scoped_bloc_builder.dart';
import 'package:smart_car/pages/live_data/model/trip_record.dart';
import 'package:smart_car/utils/ui/fuel_stats_tile.dart';
import 'package:smart_car/utils/ui/info_tile.dart';

class LiveDataPage extends StatelessWidget {
  const LiveDataPage({Key? key, required this.device}) : super(key: key);

  final BluetoothDevice device;

  @override
  Widget build(BuildContext context) {
    return ScopedBlocBuilder<LiveDataCubit, LiveDataState>(
      create: (_) => LiveDataCubit(device: device),
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
        return Scaffold(
          appBar: AppBar(
            title: Text(state.isConnecting ? 'Connecting...' : 'Connected! :D'),
            actions: [
              // IconButton(
              //     onPressed: cubit.sendVinCommand,
              //     icon: const Icon(Icons.villa_rounded)),
              // IconButton(
              //     onPressed: cubit.sendCheck9Command,
              //     icon: const Icon(Icons.check)),
              if (cubit.testCommands.isNotEmpty)
                IconButton(
                  onPressed: cubit.saveCommands,
                  icon: const Icon(Icons.send_and_archive_outlined),
                ),
              if (state.supportedPids.isNotEmpty)
                IconButton(
                  onPressed: () => showSupportedCommandsDialog(
                      context, state.supportedPids, cubit),
                  icon: const Icon(Icons.list),
                )
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Wrap(
                runSpacing: 8.0,
                spacing: 8.0,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Text(state.fuelSystemStatus.description),
                    ),
                  ),
                  // SupportedPidsTile(checker: state.pidsChecker),
                  ...cubit.commands
                      .whereType<VisibleObdCommand>()
                      .map((command) => LiveDataTile(command: command))
                      .toList(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FuelStatsTile(records: state.tripRecord.fuelSection),
                      const SizedBox.square(dimension: 8.0),
                      FuelStatsTile(records: state.tripRecord.tripSection),
                      const SizedBox.square(dimension: 8.0),
                      FuelStatsTile(records: state.tripRecord.timeSection),
                    ],
                  ),
                  // ...state.tripRecord.tripDetails
                  //     .map((details) => TripTile(details: details)),
                  const SizedBox(height: 20.0),
                  ...state.errors.map((e) => ListTile(title: Text(e))),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void showSupportedCommandsDialog(
      BuildContext context, List<String> pids, LiveDataCubit cubit) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('List of supported commands: ${pids.length}'),
          actions: [
            ElevatedButton(
              onPressed: () => cubit.pidsQueue.addAll(pids),
              child: const Text('Listen for this pids'),
            ),
          ],
          content: SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            width: MediaQuery.of(context).size.width * 0.4,
            child: ListView.builder(
              itemCount: pids.length,
              itemBuilder: (context, index) {
                final pid = pids[index].substring(pids[index].length - 2);
                return ListTile(
                  title: Text(pid),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(pidsDescription[pid] ?? 'no-description'),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
