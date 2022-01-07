import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_mailer/flutter_mailer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smart_car/pages/device_search/ui/bonded_devices_page.dart';
import 'package:smart_car/pages/device_search/ui/discovery_page.dart';
import 'package:smart_car/pages/live_data/ui/live_data_page.dart';
import 'package:smart_car/pages/settings/ui/settings_page.dart';

class DeviceSearchPage extends StatefulWidget {
  const DeviceSearchPage({Key? key}) : super(key: key);

  @override
  _DeviceSearchPageState createState() => _DeviceSearchPageState();
}

class _DeviceSearchPageState extends State<DeviceSearchPage> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  Timer? _discoverableTimeoutTimer;
  int _discoverableTimeoutSecondsLeft = 0;

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

        // Discoverable mode is disabled when Bluetooth gets disabled
        _discoverableTimeoutTimer = null;
        _discoverableTimeoutSecondsLeft = 0;
      });
    });
  }

  @override
  void dispose() {
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    _discoverableTimeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    showFilesInDirectory();
    return Scaffold(
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Enable Bluetooth'),
            value: _bluetoothState.isEnabled,
            onChanged: (bool value) {
              // Do the request and update with the true value then
              future() async {
                // async lambda seems to not working
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
          ListTile(
            title: ElevatedButton(
              child: const Text('Explore discovered devices'),
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return const DiscoveryPage();
                    },
                  ),
                );
              },
            ),
          ),
          ListTile(
            title: ElevatedButton(
              child: const Text('Connect to paired device to chat'),
              onPressed: () async {
                final BluetoothDevice? selectedDevice =
                    await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return const SelectBondedDevicePage(
                          checkAvailability: false);
                    },
                  ),
                );

                if (selectedDevice != null) {
                  _showLiveData(context, selectedDevice);
                } else {
                  print('Connect -> no device selected');
                }
              },
            ),
          ),
          ListTile(
            title: ElevatedButton(
              child: const Text('Local data'),
              onPressed: () async {
                const server = BluetoothDevice(address: 'AA:AA');
                _showLiveData(context, server);
              },
            ),
          ),
          ListTile(
            title: ElevatedButton(
              child: const Text('Settings'),
              onPressed: () async {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) {
                    return const SettingsPage();
                  },
                ));
              },
            ),
          ),
          if (files.isNotEmpty)
            ListTile(
              title: ElevatedButton(
                child: const Text('Send saved trips'),
                onPressed: () async {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) {
                      return const SettingsPage();
                    },
                  ));
                },
              ),
            )
        ],
      ),
    );
  }

  void _showLiveData(BuildContext context, BluetoothDevice server) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return LiveDataPage(device: server);
    }));
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
  }
}
