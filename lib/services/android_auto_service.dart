import 'dart:io';
import 'package:flutter/services.dart';

/// Sends real-time OBD/trip data to Android Auto via a MethodChannel.
/// Safe to call on any platform – on non-Android platforms it is a no-op.
class AndroidAutoService {
  AndroidAutoService._();

  static const _channel = MethodChannel('com.smart.smart_car/android_auto');

  /// Send the latest vehicle data snapshot to the native Android Auto screen.
  /// All values are optional; pass only the ones you have.
  static Future<void> updateCarData({
    int? speed,
    int? rpm,
    int? coolantTemp,
    double? fuelLevel,
    double? engineLoad,
    double? instFuel,
    double? avgFuel,
    double? voltage,
    double? tripDistance,
    bool? isConnected,
  }) async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod<void>('updateCarData', {
        if (speed != null) 'speed': speed,
        if (rpm != null) 'rpm': rpm,
        if (coolantTemp != null) 'coolantTemp': coolantTemp,
        if (fuelLevel != null) 'fuelLevel': fuelLevel,
        if (engineLoad != null) 'engineLoad': engineLoad,
        if (instFuel != null) 'instFuel': instFuel,
        if (avgFuel != null) 'avgFuel': avgFuel,
        if (voltage != null) 'voltage': voltage,
        if (tripDistance != null) 'tripDistance': tripDistance,
        if (isConnected != null) 'isConnected': isConnected,
      });
    } on PlatformException catch (_) {
      // Ignore errors – Android Auto may not be connected
    }
  }
}
