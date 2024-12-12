package vn.vietmap.androidauto

import android.app.Notification
import androidx.car.app.CarContext
import androidx.car.app.Screen
import androidx.car.app.ScreenManager
import androidx.car.app.SurfaceCallback
import androidx.car.app.model.Action
import androidx.car.app.model.ActionStrip
import androidx.car.app.model.CarColor
import androidx.car.app.model.CarIcon
import androidx.car.app.model.Template
import androidx.car.app.navigation.model.NavigationTemplate
import androidx.core.graphics.drawable.IconCompat
import vn.vietmap.vietmapandroidautosdk.map.VietMapAndroidAutoSurface
import vn.vietmap.vietmapsdk.maps.OnMapReadyCallback
import vn.vietmap.vietmapsdk.maps.Style
import vn.vietmap.vietmapsdk.maps.VietMapGL

class VietMapCarAppScreen(
    carContext: CarContext,
      val mSurfaceRenderer: VietMapAndroidAutoSurface,
) : Screen(carContext) {

    private var vietmapGL: VietMapGL? = null

    private val mSurfaceCallback: SurfaceCallback = object : SurfaceCallback {
        // Handle surface callback event here
    }
    companion object{
        private var instance: VietMapCarAppScreen? = null
        fun createInstance(carContext: CarContext, mNavigationCarSurface: VietMapAndroidAutoSurface): VietMapCarAppScreen {
            if (instance == null) {
                instance = VietMapCarAppScreen(carContext, mNavigationCarSurface)
            }
            return instance!!
        }
        fun getInstance(): VietMapCarAppScreen? {
            return instance
        }
    }

    init {
//        mSurfaceRenderer.addOnSurfaceCallbackListener(mSurfaceCallback)
        mSurfaceRenderer.init(
            Style.Builder(),
            OnMapReadyCallback {
                vietmapGL = it
            }
        )
    }
    fun init(  styleUrl: String) {
        mSurfaceRenderer.addOnSurfaceCallbackListener(mSurfaceCallback)
        mSurfaceRenderer.init(
            Style.Builder()
                .fromUri(styleUrl),
            OnMapReadyCallback {
                vietmapGL = it
                invalidate()
            }
        )
        invalidate()
    }

    override fun onGetTemplate(): Template {
        val builder = NavigationTemplate.Builder()
        builder.setBackgroundColor(CarColor.SECONDARY)

        // Set the action strip.
        val actionStripBuilder = ActionStrip.Builder()
        actionStripBuilder.addAction(
            Action.Builder()
                .setTitle("Back")
                .setIcon(
                    CarIcon.Builder(
                        IconCompat.createWithResource(
                            carContext,
                            vn.vietmap.vietmapsdk.R.drawable.vietmap_logo_icon
                        )
                    ).build()
                ).setOnClickListener {
                    val screenManager: ScreenManager =
                        carContext.getCarService(ScreenManager::class.java)
                    screenManager.pop()
                }
                .build()
        )

        builder.setActionStrip(actionStripBuilder.build())

        // Set the map action strip
        val panIconBuilder = CarIcon.Builder(
            IconCompat.createWithResource(
                carContext,
                vn.vietmap.vietmapsdk.R.drawable.vietmap_compass_icon
            )
        )
        builder.setMapActionStrip(
            ActionStrip.Builder()
                .addAction(
                    Action.Builder(Action.PAN)
                        .setIcon(panIconBuilder.build())
                        .build()
                )
                .addAction(
                    Action.Builder()
                        .setIcon(
                            CarIcon.Builder(
                                IconCompat.createWithResource(
                                    carContext,
                                    vn.vietmap.vietmapsdk.R.drawable.vietmap_compass_icon
                                )
                            )
                                .build()
                        )
                        .setOnClickListener {
                            //TODO: Add your code here
                        }
                        .build())
                .addAction(
                    Action.Builder()
                        .setIcon(
                            CarIcon.Builder(
                                IconCompat.createWithResource(
                                    carContext,
                                    vn.vietmap.vietmapsdk.R.drawable.vietmap_logo_icon
                                )
                            )
                                .build()
                        )
                        .setOnClickListener {
                            //TODO: Add your code here
                        }
                        .build())
                .build())

        return builder.build()
    }
}