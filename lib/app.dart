import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bluetooth_classic_serial/flutter_bluetooth_classic.dart';
import 'package:flutter_mailer/flutter_mailer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smart_car/app/blocs/global_bloc.dart';
import 'package:smart_car/app/navigation/navigation.dart';
import 'package:smart_car/app/navigation/routes.dart';
import 'package:smart_car/app/resources/strings.dart';
import 'package:smart_car/models/settings.dart';
import 'package:smart_car/models/statistics.dart';
import 'package:smart_car/pages/live_data/bloc/live_data_cubit.dart';
import 'package:smart_car/pages/live_data/bloc/live_data_state.dart';
import 'package:smart_car/pages/live_data/ui/live_data_page.dart';
import 'package:smart_car/pages/settings/bloc/settings_cubit.dart';
import 'package:smart_car/pages/settings/bloc/settings_state.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  final FlutterBluetoothClassic _bluetooth = FlutterBluetoothClassic();
  BluetoothState _bluetoothState = BluetoothState(
    isEnabled: false,
    status: 'unknown',
  );

  StreamSubscription<BluetoothState>? _btStateSub;

  List<String> files = [];
  List<String> canFiles = [];

  @override
  void initState() {
    super.initState();
    showFilesInDirectory();

    _bluetooth.isBluetoothEnabled().then((isEnabled) {
      setState(() {
        _bluetoothState = BluetoothState(
          isEnabled: isEnabled,
          status: isEnabled ? 'enabled' : 'disabled',
        );
      });
    });

    Future.doWhile(() async {
      if (await _bluetooth.isBluetoothEnabled()) {
        return false;
      }
      await Future.delayed(const Duration(milliseconds: 200));
      return true;
    });

    _btStateSub = _bluetooth.onStateChanged.listen((event) {
      setState(() {
        _bluetoothState = event;
      });
    });
  }

  @override
  void dispose() {
    _btStateSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      bloc: GlobalBlocs.settings,
      builder: (context, state) {
        final cs = Theme.of(context).colorScheme;
        final tt = Theme.of(context).textTheme;

        final tankPercent = GlobalBlocs.settings.state.settings.tankPercent;
        final tankPercentLabel = '${(tankPercent * 100).toStringAsFixed(0)} %';
        return Scaffold(
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  elevation: 0,
                  title: Text(
                    'Smart Car',
                    style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _SectionHeader(title: 'Statystyki'),
                      Card(
                        elevation: 0,
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _KeyValueRow(
                                label: 'Spalanie',
                                value:
                                    '${state.stats.refuelingConsumption.toStringAsFixed(1)} l/100km',
                              ),
                              const SizedBox(height: 8),
                              _KeyValueRow(
                                label: 'Zasięg',
                                value:
                                    '${state.stats.range.toStringAsFixed(0)} km',
                              ),
                              const SizedBox(height: 8),
                              _KeyValueRow(
                                label: 'Dystans',
                                value:
                                    '${state.stats.distance.toStringAsFixed(1)} km',
                              ),
                              const SizedBox(height: 8),
                              _KeyValueRow(
                                label: 'Użyte paliwo',
                                value:
                                    '${state.stats.fuelUsed.toStringAsFixed(2)} l',
                              ),
                              const SizedBox(height: 8),
                              _KeyValueRow(
                                label: 'Spalanie z OBD',
                                value:
                                    '${state.stats.avgConsumption.toStringAsFixed(2)} l/100km',
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(999),
                                      child: LinearProgressIndicator(
                                        value: tankPercent,
                                        minHeight: 10,
                                        backgroundColor:
                                            cs.surfaceContainerHighest,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    tankPercentLabel,
                                    style: tt.labelLarge?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                GlobalBlocs.settings.state.settings.tankDetails,
                                style: tt.labelMedium?.copyWith(
                                  color: cs.onSurfaceVariant,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      _SectionHeader(title: Strings.bluetooth),
                      Card(
                        elevation: 0,
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            SwitchListTile(
                              title: const Text(Strings.enableBluetooth),
                              subtitle: Text(
                                _bluetoothState.isEnabled
                                    ? 'Włączony'
                                    : 'Wyłączony',
                              ),
                              value: _bluetoothState.isEnabled,
                              onChanged: (bool value) {
                                future() async {
                                  if (value) {
                                    await _bluetooth.enableBluetooth();
                                  } else {
                                    // Plugin doesn't support disabling adapter programmatically.
                                    await _bluetooth.disconnect();
                                  }
                                }

                                future().then((_) {
                                  setState(() {});
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      _SectionHeader(title: Strings.obdSection),
                      Card(
                        elevation: 0,
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: BlocBuilder<LiveDataCubit, LiveDataState>(
                            builder: (context, liveState) {
                              final isConnected =
                                  GlobalBlocs.liveData.isAlreadyConnected;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (_bluetoothState.isEnabled)
                                    FilledButton(
                                      onPressed: () async {
                                        final address = context
                                            .read<SettingsCubit>()
                                            .state
                                            .settings
                                            .deviceAddress;

                                        if (address != null) {
                                          _showLiveData(context, false);
                                          return;
                                        }
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              Strings.firstlyChooseDevice,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        isConnected
                                            ? 'Wróć do danych'
                                            : Strings.connectToObd,
                                      ),
                                    )
                                  else
                                    FilledButton.tonal(
                                      onPressed: null,
                                      child: const Text('Bluetooth wyłączony'),
                                    ),
                                  const SizedBox(height: 10),
                                  if (isConnected)
                                    FilledButton.tonal(
                                      onPressed: () async {
                                        GlobalBlocs.liveData.closeConnection();
                                      },
                                      child: const Text('Zakończ połączenie'),
                                    ),
                                  if (!isConnected) ...[
                                    FilledButton.tonal(
                                      onPressed: () async {
                                        _showLiveData(context, true);
                                      },
                                      child: const Text(Strings.localMode),
                                    ),
                                  ],
                                  const SizedBox(height: 10),
                                  FilledButton.tonal(
                                    onPressed: () => Navigation.instance.push(
                                      SharedRoutes.tripSummary,
                                    ),
                                    child: const Text('Statystyki jazd'),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      _SectionHeader(title: Strings.fuelSection),
                      Card(
                        elevation: 0,
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.receipt_long),
                              title: const Text(Strings.fuelLogs),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => Navigation.instance.push(
                                SharedRoutes.fuelLogs,
                              ),
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.local_gas_station),
                              title: const Text(Strings.fuelStations),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => Navigation.instance.push(
                                SharedRoutes.fuelStations,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      _SectionHeader(title: Strings.settings),
                      Card(
                        elevation: 0,
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            if (kDebugMode) ...[
                              ListTile(
                                leading: const Icon(Icons.science),
                                title: const Text('Surowe dane'),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => Navigation.instance.push(
                                  SharedRoutes.machineLearning,
                                ),
                              ),
                              const Divider(height: 1),
                            ],
                            ListTile(
                              leading: const Icon(Icons.storage),
                              title: const Text('Logi danych'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => Navigation.instance.push(
                                SharedRoutes.dataLogs,
                              ),
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.route),
                              title: const Text('Zapisane przejazdy'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => Navigation.instance.push(
                                SharedRoutes.savedTrips,
                              ),
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.settings),
                              title: const Text(Strings.settings),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => Navigation.instance.push(
                                SharedRoutes.settings,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLiveData(BuildContext context, bool isLocalMode) {
    final address = isLocalMode
        ? null
        : context.read<SettingsCubit>().state.settings.deviceAddress;
    final fuelPrice = context.read<SettingsCubit>().state.settings.fuelPrice;
    final localFile = context.read<SettingsCubit>().state.settings.selectedJson;
    final tankSize = context.read<SettingsCubit>().state.settings.tankSize;
    GlobalBlocs.liveData.createConnection(
      newAddress: address,
      fuelPrice: fuelPrice,
      tankSize: tankSize,
      localFile: localFile,
      isLocalMode: isLocalMode,
    );
    Navigation.instance.push(
      SharedRoutes.liveData,
      arguments: LiveDataPageArguments(isLocalMode: isLocalMode),
    );
  }

  Future<void> showFilesInDirectory() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    final list = appDocDir.listSync();
    final paths = list.map((e) => e.path).toList();
    setState(() {
      files = paths.where((element) => element.contains('trip')).toList();
      canFiles = paths.where((element) => element.contains('CAN')).toList();
    });
  }

  Future<void> sendTripsToMail(List<String> files) async {
    final mailOptions = MailOptions(
      body: 'Wysyłam moje zapisane przejazdy',
      subject: 'Moje zapisane przejazdy',
      recipients: ['hunteelar.programowanie@gmail.com'],
      isHTML: true,
      attachments: files,
    );

    await FlutterMailer.send(mailOptions);
    for (final path in files) {
      final file = File(path);
      file.delete();
    }
    await showFilesInDirectory();
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 10),
      child: Text(
        title,
        style: tt.titleSmall?.copyWith(
          fontWeight: FontWeight.w900,
          color: cs.onSurfaceVariant,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _KeyValueRow extends StatelessWidget {
  const _KeyValueRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: tt.labelLarge?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: tt.labelLarge?.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
