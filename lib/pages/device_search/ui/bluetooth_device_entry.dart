// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothDeviceListEntry extends StatelessWidget {
  const BluetoothDeviceListEntry({
    required this.device,
    this.onTap,
  });

  final BluetoothDevice device;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: const Icon(Icons.devices),
      title: Text(device.name ?? "no-name"),
      subtitle: Text(device.address),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          device.isConnected
              ? const Icon(Icons.import_export)
              : const SizedBox.square(dimension: 0),
          device.isBonded
              ? const Icon(Icons.link)
              : const SizedBox.square(dimension: 0),
        ],
      ),
    );
  }
}
