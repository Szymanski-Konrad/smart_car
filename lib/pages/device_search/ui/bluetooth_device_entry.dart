// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_classic_serial/flutter_bluetooth_classic.dart';

class BluetoothDeviceListEntry extends StatelessWidget {
  const BluetoothDeviceListEntry({required this.device, this.onTap});

  final BluetoothDevice device;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: const Icon(Icons.devices),
      title: Text(device.name),
      subtitle: Text(device.address),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          device.paired
              ? const Icon(Icons.link)
              : const SizedBox.square(dimension: 0),
        ],
      ),
    );
  }
}
