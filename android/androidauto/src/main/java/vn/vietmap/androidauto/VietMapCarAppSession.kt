package vn.vietmap.androidauto

import android.content.Intent
import androidx.car.app.Screen
import androidx.car.app.Session
import vn.vietmap.vietmapandroidautosdk.map.VietMapAndroidAutoSurface

class VietMapCarAppSession: Session() {
    override fun onCreateScreen(intent: Intent): Screen {
        val mNavigationCarSurface = VietMapAndroidAutoSurface(carContext, lifecycle)
        val screenMap = VietMapCarAppScreen.createInstance(carContext,mNavigationCarSurface)
        return screenMap
    }
}