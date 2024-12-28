package vn.vietmap.androidauto.helper

import android.content.Context
import android.util.Log
import androidx.car.app.model.Action
import androidx.car.app.model.ActionStrip
import androidx.car.app.model.CarColor
import androidx.car.app.model.CarIcon
import androidx.car.app.navigation.model.NavigationTemplate
import androidx.core.graphics.drawable.IconCompat
import com.mapbox.api.directions.v5.models.DirectionsRoute
import vn.vietmap.androidauto.R
import vn.vietmap.androidauto.controller_interface.IMapController

class VietMapCarSurfaceHelper(
    private val mapController: IMapController,
    private val carContext: Context,
    ) {
    private var navigationTemplate: NavigationTemplate.Builder = NavigationTemplate.Builder()
    private var actionStrip: ActionStrip.Builder = ActionStrip.Builder()
    private var mapActionStrip: ActionStrip.Builder = ActionStrip.Builder()

    init {
        initNavigationTemplate()
    }

    private fun initNavigationTemplate() {
        navigationTemplate.setBackgroundColor(CarColor.SECONDARY)

        // Set the action strip.
        actionStrip.addAction(
            Action.Builder()
                .setIcon(
                    CarIcon.Builder(
                        IconCompat.createWithResource(
                            carContext,
                            R.drawable.recenter
                        )
                    ).build()
                ).setOnClickListener {
                    mapController.recenter()
                }
                .build()
        )

        navigationTemplate.setActionStrip(actionStrip.build())

        // Set the map action strip
        mapActionStrip.addAction(
            Action.Builder(Action.PAN).build()
        ).addAction(
            Action.Builder()
                .setIcon(
                    CarIcon.Builder(
                        IconCompat.createWithResource(
                            carContext,
                            vn.vietmap.androidauto.R.drawable.add
                        )
                    )
                        .build()
                )
                .setOnClickListener {
                    mapController.zoomIn()
                }
                .build())
            .addAction(
                Action.Builder()
                    .setIcon(
                        CarIcon.Builder(
                            IconCompat.createWithResource(
                                carContext,
                                vn.vietmap.androidauto.R.drawable.minus
                            )
                        )
                            .build()
                    )
                    .setOnClickListener {
                        mapController.zoomOut()
                    }
                    .build())

        navigationTemplate.setMapActionStrip(mapActionStrip.build())
    }

    fun getNavigationTemplate(): NavigationTemplate {
        return navigationTemplate.build()
    }

    fun updateOnRouteBuiltTemplate() {
        actionStrip = ActionStrip.Builder()
        // Set the action strip.
        actionStrip.addAction(
            Action.Builder()
                .setTitle("Bắt đầu")
                .setOnClickListener {
                    // TODO: Start navigation
                }
                .build()
        ).addAction(
            Action.Builder()
                .setIcon(
                    CarIcon.Builder(
                        IconCompat.createWithResource(
                            carContext,
                            R.drawable.overview_route
                        )
                    ).build()
                )
                .setOnClickListener {
                    mapController.overviewRoute()
                }
                .build()
        ).addAction(
            Action.Builder()
            .setIcon(
                CarIcon.Builder(
                    IconCompat.createWithResource(
                        carContext,
                        R.drawable.recenter
                    )
                ).build()
            )
            .setOnClickListener {
                mapController.recenter()
            }
            .build()
        )

        mapActionStrip = ActionStrip.Builder()
        mapActionStrip.addAction(
            Action.Builder(Action.PAN).build()
        ).addAction(
            Action.Builder()
                .setIcon(
                    CarIcon.Builder(
                        IconCompat.createWithResource(
                            carContext,
                            R.drawable.add
                        )
                    ).build()
                )
                .setOnClickListener {
                    mapController.zoomIn()
                }
                .build()
        ).addAction(
            Action.Builder()
                .setIcon(
                    CarIcon.Builder(
                        IconCompat.createWithResource(
                            carContext,
                            R.drawable.minus
                        )
                    ).build()
                )
                .setOnClickListener {
                    mapController.zoomOut()
                }
                .build()
        )

        navigationTemplate = NavigationTemplate.Builder()
        navigationTemplate.setBackgroundColor(CarColor.SECONDARY)
        navigationTemplate.setActionStrip(actionStrip.build())
        navigationTemplate.setMapActionStrip(mapActionStrip.build())
    }
}