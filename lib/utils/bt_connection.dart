import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_bluetooth_classic_serial/flutter_bluetooth_classic.dart';
import 'package:smart_car/app/resources/configs.dart';

class BTConnection {
  BTConnection._privateConstructor();
  static final BTConnection _instance = BTConnection._privateConstructor();

  factory BTConnection() {
    return _instance;
  }

  final FlutterBluetoothClassic _bluetooth = FlutterBluetoothClassic();
  StreamSubscription<BluetoothData>? _dataSubscription;

  Future<void> connect({
    required String? address,
    VoidCallback? onSuccess,
    VoidCallback? onError,
    Function(Uint8List)? onData,
  }) async {
    if (address == null || address.isEmpty) {
      onError?.call();
      return;
    }

    try {
      final connected = await _bluetooth.connect(address);
      if (!connected) {
        onError?.call();
        return;
      }

      _dataSubscription?.cancel();
      _dataSubscription = _bluetooth.onDataReceived.listen((data) {
        onData?.call(Uint8List.fromList(data.data));
      });

      await _initBackgroundWorking();
      onSuccess?.call();
    } catch (e) {
      print('Cannot connect, exception occurred');
      print(e);
      onError?.call();
    }
  }

  Future<void> sendCommand(String command, {Function(String)? onError}) async {
    if (command.isNotEmpty) {
      try {
        await _bluetooth.sendString('$command\r\n');
      } catch (e) {
        onError?.call(e.toString());
      }
    }
  }

  Future<void> close() async {
    if (FlutterBackground.isBackgroundExecutionEnabled) {
      await FlutterBackground.disableBackgroundExecution();
    }

    await _dataSubscription?.cancel();
    await _bluetooth.disconnect();
  }

  Future<void> _initBackgroundWorking() async {
    final hasPermissions = await FlutterBackground.initialize(
      androidConfig: Configs.backgroundConfig,
    );
    if (hasPermissions) {
      await FlutterBackground.enableBackgroundExecution();
    }
  }
}
