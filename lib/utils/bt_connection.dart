import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:smart_car/app/resources/configs.dart';

class BTConnection {
  BTConnection._privateConstructor();
  static final BTConnection _instance = BTConnection._privateConstructor();

  factory BTConnection() {
    return _instance;
  }

  BluetoothConnection? _connection;

  Future<void> connect({
    required String? address,
    VoidCallback? onSuccess,
    VoidCallback? onError,
    Function(Uint8List)? onData,
  }) async {
    await BluetoothConnection.toAddress(address).then((connection) {
      _connection = connection;
      _connection?.input?.listen(onData).onDone(() {
        print('Connection is done');
      });
      _initBackgroundWorking();
      onSuccess?.call();
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
      onError?.call();
    });
  }

  Future<void> sendCommand(
    String command, {
    Function(String)? onError,
  }) async {
    if (command.isNotEmpty) {
      try {
        final uft = Uint8List.fromList(utf8.encode('$command\r\n'));
        _connection?.output.add(uft);
        await _connection?.output.allSent;
      } catch (e) {
        onError?.call(e.toString());
      }
    }
  }

  Future<void> close() async {
    if (FlutterBackground.isBackgroundExecutionEnabled) {
      await FlutterBackground.disableBackgroundExecution();
    }
    await _connection?.finish();
    await _connection?.close();
    _connection?.dispose();
  }

  Future<void> _initBackgroundWorking() async {
    final hasPermissions = await FlutterBackground.initialize(
        androidConfig: Configs.backgroundConfig);
    if (hasPermissions) {
      await FlutterBackground.enableBackgroundExecution();
    }
  }
}
