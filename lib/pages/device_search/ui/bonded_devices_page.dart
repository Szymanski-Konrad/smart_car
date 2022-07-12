import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:smart_car/pages/device_search/ui/bluetooth_device_entry.dart';

class SelectBondedDevicePage extends StatefulWidget {
  const SelectBondedDevicePage({Key? key});

  @override
  _SelectBondedDevicePage createState() => _SelectBondedDevicePage();
}

class _SelectBondedDevicePage extends State<SelectBondedDevicePage> {
  _SelectBondedDevicePage();

  List<BluetoothDevice> devices = List<BluetoothDevice>.empty(growable: true);

  @override
  void initState() {
    super.initState();
    // Setup a list of the bonded devices
    FlutterBluetoothSerial.instance.getBondedDevices().then(
        (List<BluetoothDevice> bondedDevices) =>
            setState(() => devices = bondedDevices));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select device'),
      ),
      body: ListView(
        children: devices
            .map(
              (device) => BluetoothDeviceListEntry(
                device: device,
                onTap: () => Navigator.of(context).pop(device),
              ),
            )
            .toList(),
      ),
    );
  }
}
