package com.smart.smart_car

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import org.json.JSONException
import org.json.JSONObject

/**
 * Listens for two events (registered in AndroidManifest.xml):
 *
 *  1. [BluetoothAdapter.ACTION_STATE_CHANGED] → STATE_ON
 *     Fires when the user turns Bluetooth on (or the phone comes back in range
 *     of a car and BT re-enables).  We launch the app so it can connect to OBD
 *     via SPP — Android never auto-connects SPP devices itself.
 *
 *  2. [BluetoothDevice.ACTION_ACL_CONNECTED]
 *     Falls back to the specific-device check in case the OBD adapter happens
 *     to be the one triggering an ACL connection (some adapters do).
 *
 * The app is started only when a saved OBD device address is present in
 * SharedPreferences, so phones without the app configured are not affected.
 */
class BluetoothAutoStartReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "BtAutoStart"
        /** Extra key read by MainActivity to trigger auto-connect in Flutter */
        const val EXTRA_AUTO_CONNECT = "auto_connect_obd"
        /** SharedPreferences file used by Flutter's shared_preferences plugin */
        private const val PREFS_NAME = "FlutterSharedPreferences"
        /** Key within that file (plugin adds "flutter." prefix) */
        private const val SETTINGS_KEY = "flutter.settings"
    }

    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            BluetoothAdapter.ACTION_STATE_CHANGED -> {
                val state = intent.getIntExtra(
                    BluetoothAdapter.EXTRA_STATE, BluetoothAdapter.ERROR
                )
                if (state == BluetoothAdapter.STATE_ON) {
                    Log.d(TAG, "Bluetooth turned ON")
                    // Only launch when a saved OBD address exists
                    if (getSavedDeviceAddress(context) != null) {
                        launchApp(context)
                    }
                }
            }

            BluetoothDevice.ACTION_ACL_CONNECTED -> {
                val device: BluetoothDevice? =
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        intent.getParcelableExtra(
                            BluetoothDevice.EXTRA_DEVICE, BluetoothDevice::class.java
                        )
                    } else {
                        @Suppress("DEPRECATION")
                        intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE)
                    }

                val connectedAddress = device?.address ?: return
                val savedAddress = getSavedDeviceAddress(context) ?: return

                Log.d(TAG, "ACL_CONNECTED: $connectedAddress (saved OBD: $savedAddress)")

                if (connectedAddress.equals(savedAddress, ignoreCase = true)) {
                    Log.i(TAG, "OBD adapter connected directly — launching app")
                    launchApp(context)
                }
            }
        }
    }

    private fun launchApp(context: Context) {
        val launchIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
            putExtra(EXTRA_AUTO_CONNECT, true)
        }
        context.startActivity(launchIntent)
    }

    private fun getSavedDeviceAddress(context: Context): String? {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val json = prefs.getString(SETTINGS_KEY, null) ?: return null
        return try {
            JSONObject(json).optString("deviceAddress").takeIf { it.isNotEmpty() }
        } catch (e: JSONException) {
            Log.e(TAG, "Failed to parse settings JSON", e)
            null
        }
    }
}
