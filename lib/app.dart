import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_mailer/flutter_mailer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smart_car/app/blocs/global_bloc.dart';
import 'package:smart_car/app/navigation/navigation.dart';
import 'package:smart_car/app/navigation/routes.dart';
import 'package:smart_car/app/resources/strings.dart';
import 'package:smart_car/pages/live_data/ui/live_data_page.dart';
import 'package:smart_car/pages/settings/bloc/settings_cubit.dart';
import 'package:smart_car/pages/settings/bloc/settings_state.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  List<String> files = [];
  List<String> canFiles = [];

  @override
  void initState() {
    super.initState();
    showFilesInDirectory();

    FlutterBluetoothSerial.instance.state.then(
      (value) => setState(() {
        _bluetoothState = value;
      }),
    );

    Future.doWhile(() async {
      if ((await FlutterBluetoothSerial.instance.isEnabled) ?? false) {
        return false;
      }
      await Future.delayed(const Duration(milliseconds: 200));
      return true;
    });

    FlutterBluetoothSerial.instance.onStateChanged().listen((event) {
      setState(() {
        _bluetoothState = event;
      });
    });
  }

  @override
  void dispose() {
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    showFilesInDirectory();
    return BlocBuilder<SettingsCubit, SettingsState>(
      bloc: GlobalBlocs.settings,
      builder: (context, state) {
        return Scaffold(
          body: ListView(
            children: [
              const SectionTitle(title: Strings.bluetooth),
              SwitchListTile(
                title: const Text(Strings.enableBluetooth),
                value: _bluetoothState.isEnabled,
                onChanged: (bool value) {
                  future() async {
                    if (value) {
                      await FlutterBluetoothSerial.instance.requestEnable();
                    } else {
                      await FlutterBluetoothSerial.instance.requestDisable();
                    }
                  }

                  future().then((_) {
                    setState(() {});
                  });
                },
              ),
              const Divider(color: Colors.yellow),
              const SectionTitle(title: Strings.obdSection),
              if (_bluetoothState.isEnabled)
                ListTile(
                  title: ElevatedButton(
                    child: const Text(Strings.connectToObd),
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(Strings.firstlyChooseDevice),
                        ),
                      );
                    },
                  ),
                ),
              if (kDebugMode)
                ListTile(
                  title: ElevatedButton(
                    child: const Text(Strings.localMode),
                    onPressed: () async {
                      _showLiveData(context, true);
                    },
                  ),
                ),
              ListTile(
                title: ElevatedButton(
                  child: const Text('Statystyki jazd'),
                  onPressed: () =>
                      Navigation.instance.push(SharedRoutes.tripSummary),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.yellow),
              const SectionTitle(title: Strings.fuelSection),
              ListTile(
                title: ElevatedButton(
                  child: const Text(Strings.fuelLogs),
                  onPressed: () {
                    Navigation.instance.push(SharedRoutes.fuelLogs);
                  },
                ),
              ),
              ListTile(
                title: ElevatedButton(
                  child: const Text(Strings.fuelStations),
                  onPressed: () {
                    Navigation.instance.push(SharedRoutes.fuelStations);
                  },
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.yellow),
              const SectionTitle(title: Strings.settings),
              ListTile(
                title: ElevatedButton(
                  child: const Text(Strings.settings),
                  onPressed: () =>
                      Navigation.instance.push(SharedRoutes.settings),
                ),
              ),
              if (files.isNotEmpty)
                ListTile(
                  title: ElevatedButton(
                    child: Text(Strings.sendSavedTrips(files.length)),
                    onPressed: () async {
                      await sendTripsToMail(files);
                    },
                  ),
                ),
              if (canFiles.isNotEmpty)
                ListTile(
                  title: ElevatedButton(
                    child: Text(Strings.sendSavedTrips(files.length)),
                    onPressed: () async {
                      await sendTripsToMail(canFiles);
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showLiveData(BuildContext context, bool isLocalMode) {
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

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18.0,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
