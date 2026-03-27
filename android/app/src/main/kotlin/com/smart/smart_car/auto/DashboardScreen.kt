package com.smart.smart_car.auto

import androidx.car.app.CarContext
import androidx.car.app.Screen
import androidx.car.app.model.*
import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.LifecycleOwner

/**
 * Main dashboard screen shown in Android Auto.
 * Uses PaneTemplate for a proper heads-up display feel:
 *  • Header shows the app name + current speed for a quick glance
 *  • Rows: Speed/RPM • Coolant/Fuel • Load/Instant fuel • Voltage/Distance
 *  • Action button navigates to the detailed TripStatsScreen
 */
class DashboardScreen(carContext: CarContext) : Screen(carContext) {

    private val dataListener: () -> Unit = { invalidate() }

    init {
        CarDataRepository.addListener(dataListener)
        lifecycle.addObserver(object : DefaultLifecycleObserver {
            override fun onDestroy(owner: LifecycleOwner) {
                CarDataRepository.removeListener(dataListener)
            }
        })
    }

    override fun onGetTemplate(): Template {
        return if (!CarDataRepository.isConnected) {
            buildWaitingTemplate()
        } else {
            buildDashboardTemplate()
        }
    }

    // ─── Disconnected / waiting template ─────────────────────────────────────────
    private fun buildWaitingTemplate(): Template =
        PaneTemplate.Builder(
            Pane.Builder()
                .addRow(
                    Row.Builder()
                        .setTitle("Waiting for OBD connection…")
                        .addText("Open Smart Car and connect to your OBD adapter")
                        .build()
                )
                .build()
        )
        .setTitle("Smart Car")
        .setHeaderAction(Action.APP_ICON)
        .build()

    // ─── Live dashboard template ─────────────────────────────────────────────
    private fun buildDashboardTemplate(): Template {
        val d = CarDataRepository

        val coolantStr = d.coolantTemp?.let {
            if (it > 100) "${it}°C ⚠️" else "${it}°C"
        } ?: "—"

        val fuelStr = d.fuelLevel?.let {
            val s = "${it.toInt()}%"
            if (it < 10) "$s ⚠️" else s
        } ?: "—"

        val voltageStr = d.voltage?.let {
            val s = fmt(it, "V")
            if (it < 12.5) "$s ⚠️" else s
        } ?: "—"

        val speedRpmRow = Row.Builder()
            .setTitle("Speed  •  RPM")
            .addText("${d.speed} km/h   •   ${d.rpm} rpm")
            .build()

        val coolantFuelRow = Row.Builder()
            .setTitle("Coolant  •  Fuel")
            .addText("$coolantStr   •   $fuelStr")
            .build()

        val loadConsumptionRow = Row.Builder()
            .setTitle("Engine load  •  Consumption")
            .addText("${fmtOpt(d.engineLoad, "%", 0)}   •   ${fmtOpt(d.instantFuelL100, "L/100")}")
            .build()

        val voltDistRow = Row.Builder()
            .setTitle("Voltage  •  Distance")
            .addText("$voltageStr   •   ${fmt(d.tripDistance, "km")}")
            .build()

        val tripDetailsAction = Action.Builder()
            .setTitle("Trip Details")
            .setOnClickListener {
                screenManager.push(TripStatsScreen(carContext))
            }
            .build()

        val pane = Pane.Builder()
            .addRow(speedRpmRow)
            .addRow(coolantFuelRow)
            .addRow(loadConsumptionRow)
            .addRow(voltDistRow)
            .addAction(tripDetailsAction)
            .build()

        // Speed in header for instant glanceability
        val headerTitle = if (d.speed > 0) "Smart Car  —  ${d.speed} km/h" else "Smart Car"
        return PaneTemplate.Builder(pane)
            .setTitle(headerTitle)
            .setHeaderAction(Action.APP_ICON)
            .build()
    }

    // ─── Formatting helpers ─────────────────────────────────────────────────
    private fun fmt(value: Double, unit: String, decimals: Int = 1) =
        "${String.format("%.${decimals}f", value)} $unit"

    /** Formats a nullable optional value; returns "—" when null or negative. */
    private fun fmtOpt(value: Double?, unit: String, decimals: Int = 1) =
        if (value == null || value < 0) "—" else "${String.format("%.${decimals}f", value)} $unit"
}
