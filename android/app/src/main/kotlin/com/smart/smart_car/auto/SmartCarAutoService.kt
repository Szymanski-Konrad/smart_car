package com.smart.smart_car.auto

import androidx.car.app.CarAppService
import androidx.car.app.Session
import androidx.car.app.validation.HostValidator

/**
 * Entry point for Android Auto.  Declared in AndroidManifest.xml.
 */
class SmartCarAutoService : CarAppService() {

    override fun createHostValidator(): HostValidator {
        // During development allow all hosts so the DHU test environment works.
        // For production you should replace this with a proper allowlist.
        return HostValidator.ALLOW_ALL_HOSTS_VALIDATOR
    }

    override fun onCreateSession(): Session = SmartCarSession()
}
