package com.smart.smart_car

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.smart.smart_car.auto.CarDataRepository
import com.smart.smart_car.BluetoothAutoStartReceiver

class MainActivity : FlutterActivity() {

    companion object {
        const val CHANNEL = "com.smart.smart_car/android_auto"
        const val AUTO_CHANNEL = "com.smart.smart_car/auto_connect"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Android Auto data channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "updateCarData" -> {
                        val args = call.arguments
                        if (args is Map<*, *>) {
                            CarDataRepository.update(args)
                        }
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }

        // Auto-connect channel — Flutter asks if launched by BT receiver
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, AUTO_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "shouldAutoConnect" -> {
                        val flag = intent?.getBooleanExtra(
                            BluetoothAutoStartReceiver.EXTRA_AUTO_CONNECT, false
                        ) ?: false
                        // Consume the flag so it doesn't trigger twice
                        intent?.removeExtra(BluetoothAutoStartReceiver.EXTRA_AUTO_CONNECT)
                        result.success(flag)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}

