package com.smart.smart_car.auto

import java.util.concurrent.CopyOnWriteArraySet

/**
 * Singleton that holds the latest OBD / trip data coming from Flutter via MethodChannel.
 * Android Auto screens read from here whenever they need to refresh.
 *
 * Optional sensor fields are nullable: null means the value hasn't been received yet
 * (PID not supported or no data). Always-present values (speed, rpm) remain non-null.
 */
object CarDataRepository {

    // ── Always-present OBD values ──────────────────────────────────────────
    @Volatile var speed: Int = 0           // km/h
    @Volatile var rpm: Int = 0             // rev/min

    // ── Optional OBD values (null = not yet received / PID unsupported) ───
    @Volatile var coolantTemp: Int? = null         // °C
    @Volatile var fuelLevel: Double? = null        // %
    @Volatile var engineLoad: Double? = null       // %
    @Volatile var instantFuelL100: Double? = null  // L/100 km
    @Volatile var avgFuelL100: Double? = null      // L/100 km  (trip average)
    @Volatile var voltage: Double? = null          // V

    // ── Trip accumulator (always-present) ─────────────────────────────────
    @Volatile var tripDistance: Double = 0.0       // km

    // ── Connection state ───────────────────────────────────────────────────
    @Volatile var isConnected: Boolean = false

    // ── Thread-safe listener registry ─────────────────────────────────────
    // Each registered Screen calls invalidate() to redraw itself.
    private val listeners = CopyOnWriteArraySet<() -> Unit>()

    fun addListener(fn: () -> Unit)    { listeners.add(fn)    }
    fun removeListener(fn: () -> Unit) { listeners.remove(fn) }

    fun update(map: Map<*, *>) {
        speed           = (map["speed"]        as? Number)?.toInt()    ?: speed
        rpm             = (map["rpm"]          as? Number)?.toInt()    ?: rpm
        coolantTemp     = (map["coolantTemp"]  as? Number)?.toInt()    ?: coolantTemp
        fuelLevel       = (map["fuelLevel"]    as? Number)?.toDouble() ?: fuelLevel
        engineLoad      = (map["engineLoad"]   as? Number)?.toDouble() ?: engineLoad
        instantFuelL100 = (map["instFuel"]     as? Number)?.toDouble() ?: instantFuelL100
        avgFuelL100     = (map["avgFuel"]      as? Number)?.toDouble() ?: avgFuelL100
        voltage         = (map["voltage"]      as? Number)?.toDouble() ?: voltage
        tripDistance    = (map["tripDistance"] as? Number)?.toDouble() ?: tripDistance
        isConnected     = (map["isConnected"]  as? Boolean)            ?: isConnected
        listeners.forEach { it() }
    }
}
