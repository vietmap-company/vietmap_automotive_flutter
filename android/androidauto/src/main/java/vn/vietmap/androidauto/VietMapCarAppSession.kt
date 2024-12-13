package vn.vietmap.androidauto

import android.content.Intent
import androidx.car.app.Screen
import androidx.car.app.Session
import androidx.lifecycle.MutableLiveData
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import vn.vietmap.vietmapandroidautosdk.map.VietMapAndroidAutoSurface

class VietMapCarAppSession: Session() {
    companion object {
        private val _carAppScreenInstance = MutableLiveData<VietMapCarAppScreen?>(null)
        val carAppScreenInstance: MutableLiveData<VietMapCarAppScreen?> = _carAppScreenInstance

        fun setCarAppScreenInstance(screen: VietMapCarAppScreen) {
            _carAppScreenInstance.value = screen
        }
    }

    override fun onCreateScreen(intent: Intent): Screen {
        val mNavigationCarSurface = VietMapAndroidAutoSurface(carContext, lifecycle)
        val screenMap = VietMapCarAppScreen(carContext,mNavigationCarSurface)
        setCarAppScreenInstance(screenMap)
        return screenMap
    }
}