import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_bluetooth_classic_serial/flutter_bluetooth_classic.dart';
import 'package:smart_car/app/resources/configs.dart';

/// How long to wait for the BT connect handshake before giving up.
const _kConnectTimeout = Duration(seconds: 8);

/// How long to scan for BT devices before deciding the target is out of range.
const _kDiscoveryTimeout = Duration(seconds: 10);

class BTConnection {
  BTConnection._privateConstructor();
  static final BTConnection _instance = BTConnection._privateConstructor();

  factory BTConnection() {
    return _instance;
  }

  final FlutterBluetoothClassic _bluetooth = FlutterBluetoothClassic();
  StreamSubscription<BluetoothData>? _dataSubscription;

  /// Returns true when [address] is still in the device's bonded/paired list.
  /// This is an instant check that does NOT require a discovery scan.
  Future<bool> isDevicePaired(String address) async {
    try {
      final paired = await _bluetooth.getPairedDevices();
      return paired.any(
        (d) => d.address.toLowerCase() == address.toLowerCase(),
      );
    } catch (_) {
      // If we can't read the list, allow the connect attempt to proceed.
      return true;
    }
  }

  /// Returns true when [address] is visible in a Bluetooth discovery scan,
  /// meaning the device is powered on and within radio range.
  ///
  /// Starts a device discovery, waits up to [_kDiscoveryTimeout] for the
  /// target to appear, then stops discovery.  Resolves early as soon as the
  /// device is found so typical checks finish well under the timeout.
  Future<bool> isDeviceInRange(String address) async {
    final target = address.toLowerCase();
    StreamSubscription<BluetoothDevice>? sub;
    final completer = Completer<bool>();

    try {
      await _bluetooth.startDiscovery();

      sub = _bluetooth.onDeviceDiscovered.listen((device) {
        if (device.address.toLowerCase() == target && !completer.isCompleted) {
          completer.complete(true);
        }
      });

      // Resolve false after timeout
      Future.delayed(_kDiscoveryTimeout, () {
        if (!completer.isCompleted) completer.complete(false);
      });

      return await completer.future;
    } catch (_) {
      // Discovery API not available – let connect attempt proceed
      return true;
    } finally {
      await sub?.cancel();
      try {
        await _bluetooth.stopDiscovery();
      } catch (_) {}
    }
  }

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
      // Pair-list check: fast path to detect unpaired / forgotten devices
      final paired = await isDevicePaired(address);
      if (!paired) {
        onError?.call();
        return;
      }

      // Attempt connection with a hard timeout so we fail fast when the
      // device is powered off or out of Bluetooth range.
      final connected = await _bluetooth
          .connect(address)
          .timeout(_kConnectTimeout, onTimeout: () => false);

      if (!connected) {
        onError?.call();
        return;
      }

      _dataSubscription?.cancel();
      _dataSubscription = _bluetooth.onDataReceived.listen(
        (data) {
          onData?.call(Uint8List.fromList(data.data));
        },
        onError: (_) {
          // BT stream dropped mid-session — treat the same as a connection error
          onError?.call();
        },
        cancelOnError: true,
      );

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
