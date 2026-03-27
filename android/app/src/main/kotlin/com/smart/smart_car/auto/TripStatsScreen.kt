package com.smart.smart_car.auto

import androidx.car.app.CarContext
import androidx.car.app.Screen
import androidx.car.app.model.*
import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.LifecycleOwner

/**
 * Secondary Android Auto screen – detailed trip statistics.
 * Opened via the "Trip Details" action button on DashboardScreen.
 * Uses ListTemplate so all rows are visible at a glance.
 */
class TripStatsScreen(carContext: CarContext) : Screen(carContext) {

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
        val d = CarDataRepository

        val distanceRow = Row.Builder()
            .setTitle("Trip distance")
            .addText("${String.format("%.2f", d.tripDistance)} km")
            .build()

        val avgFuelRow = Row.Builder()
            .setTitle("Average fuel consumption")
            .addText(fmtOpt(d.avgFuelL100, "L/100 km"))
            .build()

        val instFuelRow = Row.Builder()
            .setTitle("Instant fuel consumption")
            .addText(fmtOpt(d.instantFuelL100, "L/100 km"))
            .build()

        val engineLoadRow = Row.Builder()
            .setTitle("Engine load")
            .addText(fmtOpt(d.engineLoad, "%", 0))
            .build()

        val coolantRow = Row.Builder()
            .setTitle("Coolant temperature")
            .addText(
                d.coolantTemp?.let {
                    if (it > 100) "${it}°C ⚠️" else "${it}°C"
                } ?: "—"
            )
            .build()

        val voltageRow = Row.Builder()
            .setTitle("Battery voltage")
            .addText(
                d.voltage?.let {
                    val s = "${String.format("%.1f", it)} V"
                    if (it < 12.5) "$s ⚠️" else s
                } ?: "—"
            )
            .build()

        val fuelLevelRow = Row.Builder()
            .setTitle("Fuel level")
            .addText(
                d.fuelLevel?.let {
                    val s = "${it.toInt()}%"
                    if (it < 10) "$s ⚠️" else s
                } ?: "—"
            )
            .build()

        val itemList = ItemList.Builder()
            .addItem(distanceRow)
            .addItem(avgFuelRow)
            .addItem(instFuelRow)
            .addItem(engineLoadRow)
            .addItem(coolantRow)
            .addItem(voltageRow)
            .addItem(fuelLevelRow)
            .build()

        return ListTemplate.Builder()
            .setTitle("Trip Details")
            .setHeaderAction(Action.BACK)
            .setSingleList(itemList)
            .build()
    }

    private fun fmtOpt(value: Double?, unit: String, decimals: Int = 1): String =
        if (value == null || value < 0) "—" else "${String.format("%.${decimals}f", value)} $unit"
}
