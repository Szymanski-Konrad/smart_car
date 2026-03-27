import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  Timer? _autoConnectTimer;
  bool _autoConnectPending = false;

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
      if (event.isEnabled) {
        _startAutoConnectLoop();
      } else {
        _autoConnectTimer?.cancel();
      }
    });

    // Start auto-connect after settings are loaded
    Future.delayed(const Duration(seconds: 2), _startAutoConnectLoop);

    // If app was launched by BluetoothAutoStartReceiver, skip the timer
    // and connect immediately (also works when app was killed).
    if (Platform.isAndroid) {
      _checkAutoConnectIntent();
    }
  }

  @override
  void dispose() {
    _btStateSub?.cancel();
    _autoConnectTimer?.cancel();
    super.dispose();
  }

  static const _autoConnectChannel = MethodChannel(
    'com.smart.smart_car/auto_connect',
  );

  /// Called once at startup to check if the app was launched by
  /// [BluetoothAutoStartReceiver]. If so, skip the 2-second delay and
  /// connect immediately.
  Future<void> _checkAutoConnectIntent() async {
    try {
      final shouldConnect = await _autoConnectChannel.invokeMethod<bool>(
        'shouldAutoConnect',
      );
      if (shouldConnect == true) {
        // Settings may not be loaded yet — wait briefly then connect
        await Future.delayed(const Duration(milliseconds: 800));
        _tryAutoConnect();
      }
    } on PlatformException catch (_) {
      // Not on Android or channel unavailable — ignore
    }
  }

  void _startAutoConnectLoop() {
    _autoConnectTimer?.cancel();
    _tryAutoConnect();
    _autoConnectTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _tryAutoConnect(),
    );
  }

  void _tryAutoConnect() {
    if (_autoConnectPending) return;
    if (!_bluetoothState.isEnabled) return;

    // Already running a trip — stop loop
    if (GlobalBlocs.liveData.isAlreadyConnected) {
      _autoConnectTimer?.cancel();
      return;
    }

    final settings = GlobalBlocs.settings.state.settings;
    final address = settings.deviceAddress;
    if (address == null) return;

    _autoConnectPending = true;
    _autoConnectTimer?.cancel();

    GlobalBlocs.liveData.createConnection(
      newAddress: address,
      fuelPrice: settings.fuelPrice,
      tankSize: settings.tankSize,
      localFile: settings.selectedJson,
      isLocalMode: false,
    );

    _autoConnectPending = false;

    // Listen for trip end to restart the auto-connect loop
    GlobalBlocs.liveData.stream
        .firstWhere((s) => s.isTripEnded || s.isConnnectingError)
        .then((_) {
          Future.delayed(const Duration(seconds: 5), _startAutoConnectLoop);
        })
        .ignore();
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
                      _ObdStatusCard(
                        bluetoothEnabled: _bluetoothState.isEnabled,
                      ),

                      const SizedBox(height: 10),
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

                                        if (address == null) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                Strings.firstlyChooseDevice,
                                              ),
                                            ),
                                          );
                                          return;
                                        }

                                        if (isConnected) {
                                          // Connection already initiated — open live data
                                          Navigation.instance.push(
                                            SharedRoutes.liveData,
                                            arguments: LiveDataPageArguments(
                                              isLocalMode: false,
                                            ),
                                          );
                                          return;
                                        }

                                        // Not yet connected — start OBD connection in background
                                        final settings = context
                                            .read<SettingsCubit>()
                                            .state
                                            .settings;

                                        GlobalBlocs.liveData.createConnection(
                                          newAddress: address,
                                          fuelPrice: settings.fuelPrice,
                                          tankSize: settings.tankSize,
                                          localFile: settings.selectedJson,
                                          isLocalMode: false,
                                        );
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Nawiązywanie połączenia…',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      child: Text(
                                        isConnected
                                            ? 'Pokaż dane na żywo'
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

// ─── OBD connection status card ────────────────────────────────────────────

class _ObdStatusCard extends StatelessWidget {
  const _ObdStatusCard({required this.bluetoothEnabled});
  final bool bluetoothEnabled;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LiveDataCubit, LiveDataState>(
      bloc: GlobalBlocs.liveData,
      buildWhen: (p, n) =>
          p.isConnecting != n.isConnecting ||
          p.isRunning != n.isRunning ||
          p.isTripClosing != n.isTripClosing ||
          p.isConnnectingError != n.isConnnectingError ||
          p.vin != n.vin ||
          p.tripRecord.distance != n.tripRecord.distance ||
          p.tripRecord.gpsSpeed != n.tripRecord.gpsSpeed ||
          p.tripRecord.instFuelConsumption != n.tripRecord.instFuelConsumption,
      builder: (context, s) {
        final cubit = GlobalBlocs.liveData;
        final cs = Theme.of(context).colorScheme;
        final tt = Theme.of(context).textTheme;

        // ── Determine status ──────────────────────────────────────
        final _StatusKind kind;
        final String label;

        if (!bluetoothEnabled) {
          kind = _StatusKind.off;
          label = 'Bluetooth wyłączony';
        } else if (s.isConnnectingError) {
          kind = _StatusKind.error;
          label = 'Błąd połączenia';
        } else if (s.isTripClosing) {
          kind = _StatusKind.connecting;
          label = 'Zapisywanie przejazdu…';
        } else if (s.isRunning) {
          kind = _StatusKind.connected;
          label = 'Połączono z OBD2';
        } else if (s.isConnecting && cubit.isAlreadyConnected) {
          kind = _StatusKind.connecting;
          label = 'Łączenie z adapterem…';
        } else {
          kind = _StatusKind.idle;
          label = 'Nie połączono';
        }

        final dotColor = switch (kind) {
          _StatusKind.connected => const Color(0xFF34C759),
          _StatusKind.connecting => const Color(0xFFFF9F0A),
          _StatusKind.error => cs.error,
          _StatusKind.idle => cs.outline,
          _StatusKind.off => cs.outline,
        };

        final address = cubit.address;
        final vin = s.vin?.isNotEmpty == true ? s.vin : null;
        final trip = s.tripRecord;
        final showLive = s.isRunning && !s.isTripClosing;

        return Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Status row ──────────────────────────────────────
                Row(
                  children: [
                    _PulsingDot(
                      color: dotColor,
                      pulse: kind == _StatusKind.connecting,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        label,
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),

                // ── Device address ──────────────────────────────────
                if (address != null &&
                    kind != _StatusKind.idle &&
                    kind != _StatusKind.off) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Adapter: $address',
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],

                // ── VIN ─────────────────────────────────────────────
                if (vin != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'VIN: $vin',
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      letterSpacing: 1,
                    ),
                  ),
                ],

                // ── Live trip stats ──────────────────────────────────
                if (showLive) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _StatChip(
                        icon: Icons.speed,
                        label:
                            '${trip.gpsSpeed > 0 ? trip.gpsSpeed.toStringAsFixed(0) : '0'} km/h',
                        tooltip: 'Prędkość GPS',
                      ),
                      const SizedBox(width: 8),
                      _StatChip(
                        icon: Icons.straighten,
                        label: '${trip.distance.toStringAsFixed(2)} km',
                        tooltip: 'Dystans',
                      ),
                      const SizedBox(width: 8),
                      if (trip.instFuelConsumption > 0)
                        _StatChip(
                          icon: Icons.local_gas_station,
                          label:
                              '${trip.instFuelConsumption.toStringAsFixed(1)} L/100',
                          tooltip: 'Spalanie chwilowe',
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

enum _StatusKind { connected, connecting, error, idle, off }

class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.color, required this.pulse});
  final Color color;
  final bool pulse;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _anim = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    if (widget.pulse) _ctrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_PulsingDot old) {
    super.didUpdateWidget(old);
    if (widget.pulse && !_ctrl.isAnimating) {
      _ctrl.repeat(reverse: true);
    } else if (!widget.pulse && _ctrl.isAnimating) {
      _ctrl.stop();
      _ctrl.value = 1.0;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Opacity(
        opacity: _anim.value,
        child: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.tooltip,
  });
  final IconData icon;
  final String label;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: cs.onSurfaceVariant),
            const SizedBox(width: 5),
            Text(
              label,
              style: tt.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: cs.onSurface,
              ),
            ),
          ],
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
