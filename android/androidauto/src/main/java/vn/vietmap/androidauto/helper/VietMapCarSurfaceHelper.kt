package vn.vietmap.androidauto.helper

import android.content.Context
import android.util.Log
import androidx.annotation.RequiresApi
import androidx.car.app.model.Action
import androidx.car.app.model.ActionStrip
import androidx.car.app.model.CarColor
import androidx.car.app.model.CarIcon
import androidx.car.app.model.CarText
import androidx.car.app.model.DateTimeWithZone
import androidx.car.app.navigation.model.Maneuver
import androidx.car.app.navigation.model.NavigationTemplate
import androidx.car.app.navigation.model.RoutingInfo
import androidx.car.app.navigation.model.Step
import androidx.car.app.navigation.model.TravelEstimate
import androidx.core.graphics.drawable.IconCompat
import com.mapbox.api.directions.v5.models.BannerInstructions
import com.mapbox.api.directions.v5.models.DirectionsRoute
import vn.vietmap.androidauto.R
import vn.vietmap.androidauto.controller_interface.IMapController
import vn.vietmap.services.android.navigation.v5.routeprogress.RouteProgress
import java.time.Duration
import java.time.ZonedDateTime

class VietMapCarSurfaceHelper(
    private val mapController: IMapController,
    private val carContext: Context,
    ) {
    private lateinit var navigationTemplate: NavigationTemplate.Builder
    private lateinit var actionStrip: ActionStrip.Builder
    private lateinit var mapActionStrip: ActionStrip.Builder
    private var travelEstimate: TravelEstimate.Builder? = null
    private var maneuver: Maneuver.Builder? = null
    private var step: Step.Builder? = null
    private var routingInfo: RoutingInfo.Builder? = null

    init {
        initNavigationTemplate()
    }

    fun initNavigationTemplate() {
        navigationTemplate = NavigationTemplate.Builder()
        navigationTemplate.setBackgroundColor(CarColor.SECONDARY)

        actionStrip = ActionStrip.Builder()
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

        mapActionStrip = ActionStrip.Builder()
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

    @RequiresApi(26)
    fun updateTravelEstimate(
        distanceEstimate: Double,
        durationEstimate: Long,
        descriptionText: String,
    ) {
        travelEstimate = TravelEstimate.Builder(
            VietMapNavigationHelper.getDisplayDistance(distanceEstimate),
            DateTimeWithZone.create(
                ZonedDateTime.now().plusSeconds(durationEstimate)
            )
        )
        travelEstimate?.setRemainingTime(Duration.ofMinutes(durationEstimate))
        travelEstimate?.setTripText(CarText.create(descriptionText))
        travelEstimate?.build()?.let {
            navigationTemplate.setDestinationTravelEstimate(
                it
            )
        }
    }

    fun updateManeuver(routeProgress: RouteProgress?) {
        val maneuverType = getManeuver(routeProgress)
        if (maneuverType.isEmpty()) return
        maneuver = Maneuver.Builder(Maneuver.TYPE_STRAIGHT)
            .setIcon(
                CarIcon.Builder(
                    IconCompat.createWithResource(
                        carContext,
                        VietMapNavigationHelper.getDrawableResId(maneuverType)
                    )
                ).build()
            )
    }

    fun updateStep(cueGuide: String) {
        step = maneuver?.let {
            Step.Builder()
                .setManeuver(it.build())
                .setCue(cueGuide)
        }
    }

    fun updateRoutingInfo(distanceToNextTurn: Double) {
        routingInfo = step?.let {
            RoutingInfo.Builder()
                .setLoading(false)
                .setCurrentStep(
                    it.build(),
                    VietMapNavigationHelper.getDisplayDistance(distanceToNextTurn)
                )
        }

        routingInfo?.let {
            navigationTemplate.setNavigationInfo(
                it.build()
            )
        }
    }


    private fun getManeuver(routeProgress: RouteProgress?): String {
        val bannerInstructionsList: List<BannerInstructions>? =
            routeProgress?.currentLegProgress()?.currentStep()?.bannerInstructions()
        if (bannerInstructionsList?.isEmpty() == true) return ""
        val currentModifier = bannerInstructionsList?.get(0)?.primary()?.modifier()
        val currentModifierType = bannerInstructionsList?.get(0)?.primary()?.type()
        return listOf(currentModifierType, currentModifier).joinToString("_").replace(" ", "_")
    }

    fun updateOnRouteBuiltTemplate() {
        actionStrip = ActionStrip.Builder()
        // Set the action strip.
        actionStrip.addAction(
            Action.Builder()
                .setTitle("Bắt đầu")
                .setOnClickListener {
                    mapController.startNavigation()
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

    fun updateOnStartNavigationTemplate(){
        actionStrip = ActionStrip.Builder()
        // Set the action strip.
        actionStrip.addAction(
            Action.Builder()
                .setTitle("Kết thúc")
                .setOnClickListener {
                    mapController.stopNavigation()
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