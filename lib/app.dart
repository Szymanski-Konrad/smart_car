import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_mailer/flutter_mailer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smart_car/app/navigation/navigation.dart';
import 'package:smart_car/app/navigation/routes.dart';
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
      builder: (context, state) {
        return Scaffold(
          body: ListView(
            children: [
              SwitchListTile(
                title: const Text('Enable Bluetooth'),
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
              const Divider(),
              if (_bluetoothState.isEnabled)
                ListTile(
                  title: ElevatedButton(
                    child: const Text('Connect to OBDII'),
                    onPressed: () async {
                      final address = context
                          .read<SettingsCubit>()
                          .state
                          .settings
                          .deviceAddress;

                      final localFile = context
                          .read<SettingsCubit>()
                          .state
                          .settings
                          .selectedJson;

                      if (address != null) {
                        _showLiveData(context, false, localFile);
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Firstly choose default device in settings'),
                        ),
                      );
                    },
                  ),
                ),
              if (kDebugMode)
                ListTile(
                  title: ElevatedButton(
                    child: const Text('Local data'),
                    onPressed: () async {
                      final localFile = context
                          .read<SettingsCubit>()
                          .state
                          .settings
                          .selectedJson;

                      _showLiveData(context, true, localFile);
                    },
                  ),
                ),
              ListTile(
                title: ElevatedButton(
                  child: const Text('Settings'),
                  onPressed: () =>
                      Navigation.instance.push(SharedRoutes.settings),
                ),
              ),
              if (files.isNotEmpty)
                ListTile(
                  title: ElevatedButton(
                    child: Text('Send saved trips (${files.length})'),
                    onPressed: () async {
                      await sendTripsToMail(files);
                    },
                  ),
                )
            ],
          ),
        );
      },
    );
  }

  void _showLiveData(BuildContext context, bool isLocalMode, String file) {
    Navigation.instance.push(
      SharedRoutes.liveData,
      arguments: LiveDataPageArguments(
        isLocalMode: isLocalMode,
        localFile: file,
      ),
    );
  }

  Future<void> showFilesInDirectory() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    final list = appDocDir.listSync();
    final paths = list.map((e) => e.path).toList();
    setState(() {
      files = paths.where((element) => element.contains('trip')).toList();
    });
  }

  Future<void> sendTripsToMail(List<String> files) async {
    final mailOptions = MailOptions(
      body: 'Sending my last trips',
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
