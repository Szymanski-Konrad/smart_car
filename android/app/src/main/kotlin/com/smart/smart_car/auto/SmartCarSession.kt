package com.smart.smart_car.auto

import android.content.Intent
import androidx.car.app.Screen
import androidx.car.app.Session

/**
 * Manages the lifecycle of the Android Auto session.
 * Creates the initial [DashboardScreen] when the session starts.
 */
class SmartCarSession : Session() {

    override fun onCreateScreen(intent: Intent): Screen {
        return DashboardScreen(carContext)
    }
}
