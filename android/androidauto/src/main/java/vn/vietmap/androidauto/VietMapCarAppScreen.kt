package vn.vietmap.androidauto

import android.Manifest.permission.ACCESS_COARSE_LOCATION
import android.Manifest.permission.ACCESS_FINE_LOCATION
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Color
import android.graphics.PointF
import android.graphics.drawable.BitmapDrawable
import android.location.Location
import android.os.Build
import android.util.Log
import androidx.annotation.RequiresApi
import androidx.car.app.CarContext
import androidx.car.app.Screen
import androidx.car.app.SurfaceCallback
import androidx.car.app.model.Template
import androidx.core.app.ActivityCompat
import com.mapbox.api.directions.v5.DirectionsCriteria
import com.mapbox.api.directions.v5.models.DirectionsResponse
import com.mapbox.api.directions.v5.models.DirectionsRoute
import com.mapbox.geojson.Point
import com.mapbox.turf.TurfMisc
import okhttp3.internal.toHexString
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
import vn.vietmap.androidauto.communicate_interface.IAutomotiveCommunicator
import vn.vietmap.androidauto.controller_interface.IMapController
import vn.vietmap.androidauto.helper.VietMapCarSurfaceHelper
import vn.vietmap.androidauto.helper.VietMapNavigationHelper
import vn.vietmap.androidauto.models.CurrentCenterPoint
import vn.vietmap.services.android.navigation.ui.v5.camera.CameraOverviewCancelableCallback
import vn.vietmap.services.android.navigation.ui.v5.voice.NavigationSpeechPlayer
import vn.vietmap.services.android.navigation.ui.v5.voice.SpeechAnnouncement
import vn.vietmap.services.android.navigation.ui.v5.voice.SpeechPlayer
import vn.vietmap.services.android.navigation.ui.v5.voice.SpeechPlayerProvider
import vn.vietmap.services.android.navigation.v5.location.engine.LocationEngineProvider
import vn.vietmap.services.android.navigation.v5.location.replay.ReplayRouteLocationEngine
import vn.vietmap.services.android.navigation.v5.milestone.Milestone
import vn.vietmap.services.android.navigation.v5.milestone.MilestoneEventListener
import vn.vietmap.services.android.navigation.v5.milestone.VoiceInstructionMilestone
import vn.vietmap.services.android.navigation.v5.navigation.NavigationConstants
import vn.vietmap.services.android.navigation.v5.navigation.NavigationEventListener
import vn.vietmap.services.android.navigation.v5.navigation.NavigationMapRoute
import vn.vietmap.services.android.navigation.v5.navigation.NavigationRoute
import vn.vietmap.services.android.navigation.v5.navigation.NavigationTimeFormat
import vn.vietmap.services.android.navigation.v5.navigation.VietmapNavigation
import vn.vietmap.services.android.navigation.v5.navigation.VietmapNavigationOptions
import vn.vietmap.services.android.navigation.v5.offroute.OffRouteListener
import vn.vietmap.services.android.navigation.v5.route.FasterRouteListener
import vn.vietmap.services.android.navigation.v5.routeprogress.ProgressChangeListener
import vn.vietmap.services.android.navigation.v5.routeprogress.RouteProgress
import vn.vietmap.services.android.navigation.v5.snap.SnapToRoute
import vn.vietmap.services.android.navigation.v5.utils.RouteUtils
import vn.vietmap.vietmapandroidautosdk.map.VietMapAndroidAutoSurface
import vn.vietmap.vietmapsdk.R
import vn.vietmap.vietmapsdk.annotations.IconFactory
import vn.vietmap.vietmapsdk.annotations.Marker
import vn.vietmap.vietmapsdk.annotations.MarkerOptions
import vn.vietmap.vietmapsdk.annotations.Polygon
import vn.vietmap.vietmapsdk.annotations.PolygonOptions
import vn.vietmap.vietmapsdk.annotations.Polyline
import vn.vietmap.vietmapsdk.annotations.PolylineOptions
import vn.vietmap.vietmapsdk.camera.CameraPosition
import vn.vietmap.vietmapsdk.camera.CameraUpdate
import vn.vietmap.vietmapsdk.camera.CameraUpdateFactory
import vn.vietmap.vietmapsdk.geometry.LatLng
import vn.vietmap.vietmapsdk.location.LocationComponent
import vn.vietmap.vietmapsdk.location.LocationComponentActivationOptions
import vn.vietmap.vietmapsdk.location.LocationComponentOptions
import vn.vietmap.vietmapsdk.location.engine.LocationEngine
import vn.vietmap.vietmapsdk.location.engine.LocationEngineCallback
import vn.vietmap.vietmapsdk.location.engine.LocationEngineResult
import vn.vietmap.vietmapsdk.location.modes.CameraMode
import vn.vietmap.vietmapsdk.location.modes.RenderMode
import vn.vietmap.vietmapsdk.maps.MapView
import vn.vietmap.vietmapsdk.maps.Style
import vn.vietmap.vietmapsdk.maps.VietMapGL
import vn.vietmap.vietmapsdk.style.layers.LineLayer
import vn.vietmap.vietmapsdk.style.layers.Property.LINE_CAP_ROUND
import vn.vietmap.vietmapsdk.style.layers.Property.LINE_JOIN_ROUND
import vn.vietmap.vietmapsdk.style.layers.PropertyFactory.lineCap
import vn.vietmap.vietmapsdk.style.layers.PropertyFactory.lineColor
import vn.vietmap.vietmapsdk.style.layers.PropertyFactory.lineJoin
import vn.vietmap.vietmapsdk.style.layers.PropertyFactory.lineWidth
import java.util.Locale
import kotlin.math.round

class VietMapCarAppScreen(
    carContext: CarContext,
    val mSurfaceRenderer: VietMapAndroidAutoSurface,
) : Screen(carContext), IMapController, NavigationEventListener, FasterRouteListener, MilestoneEventListener, OffRouteListener, ProgressChangeListener {
    private val routeUtils = RouteUtils()
    private var vietmapGL: VietMapGL? = null
    private var mapView: MapView? = null
    private var apikey: String? = null
    private var locationEngine: LocationEngine? = null
    private var locationComponent: LocationComponent? = null
    private var vietmapNavigation: VietmapNavigation? = null
    private var navigationOptions =
        VietmapNavigationOptions.builder().maxTurnCompletionOffset(30.0).maneuverZoneRadius(40.0)
            .maximumDistanceOffRoute(50.0).deadReckoningTimeInterval(5.0)
            .maxManipulatedCourseAngle(25.0).userLocationSnapDistance(20.0).secondsBeforeReroute(3)
            .enableOffRouteDetection(true).enableFasterRouteDetection(false).snapToRoute(false)
            .manuallyEndNavigationUponCompletion(false).defaultMilestonesEnabled(true)
            .minimumDistanceBeforeRerouting(10.0).metersRemainingTillArrival(20.0)
            .isFromNavigationUi(false).isDebugLoggingEnabled(false)
            .roundingIncrement(NavigationConstants.ROUNDING_INCREMENT_FIFTY)
            .timeFormatType(NavigationTimeFormat.NONE_SPECIFIED)
            .locationAcceptableAccuracyInMetersThreshold(100).build()
    private var directionsRoutes: List<DirectionsRoute>? = null
    private var navigationMapRoute: NavigationMapRoute? = null
    private var currentRoute: DirectionsRoute? = null

    private var isMapReady = false
    private var isNavigationInProgress = false
    private var isNavigationCanceled = false
    private val listMarkers: ArrayList<Marker> = ArrayList()
    private val listPolylines: ArrayList<Polyline> = ArrayList()
    private val listPolygons: ArrayList<Polygon> = ArrayList()
    private var currentCenterPoint: CurrentCenterPoint? = null
    private lateinit var automotiveCommunicator: IAutomotiveCommunicator
    private val snapEngine = SnapToRoute()
    private var routeProgress: RouteProgress? = null
    private var isRefreshing = false
    private var isNextTurnHandling = false
    private var distanceToOffRoute = 30.0
    private var speechPlayer: SpeechPlayer? = null
    private var bitmapDrawable: BitmapDrawable? = null
    private var isPreviewingRoute = false
    private var isOverviewing = false
    private var primaryRouteIndex = 0
    private var isBuildingRoute = false
    private val vietmapNavigationSurfaceHelper: VietMapCarSurfaceHelper =
        VietMapCarSurfaceHelper(this, carContext)

    companion object {

        private var disposed = false

        //Config
        var isMapViewStarted: Boolean = false
        var initialLatitude: Double? = null
        var initialLongitude: Double? = null
        var profile: String = "driving-traffic"
        val wayPoints: MutableList<Point> = mutableListOf()
        var navigationMode = DirectionsCriteria.PROFILE_DRIVING_TRAFFIC
        var simulateRoute = false
        var mapStyleURL: String? = null
        var navigationLanguage = Locale("vi")
        var navigationVoiceUnits = DirectionsCriteria.IMPERIAL
        var zoom = 20.0
        var bearing = 0.0
        var tilt = 0.0
        var distanceRemaining: Double? = null
        var durationRemaining: Double? = null
        var alternatives = true
        var voiceInstructionsEnabled = true
        var bannerInstructionsEnabled = true
        var longPressDestinationEnabled = true
        var animateBuildRoute = true
        var isOptimized = false
        var originPoint: Point? = null
        var destinationPoint: Point? = null
        var isRunning: Boolean = false

        var padding: IntArray = intArrayOf(300, 200, 30, 30)
    }

    fun muteVoiceInstructions(isMute: Boolean) : Boolean {
        voiceInstructionsEnabled = !isMute
        speechPlayer?.let {
            speechPlayer!!.isMuted = isMute
            return speechPlayer!!.isMuted
        }
        return false
    }

    fun getDistanceRemaining(): Double? {
        return distanceRemaining
    }

    fun getDurationRemaining(): Double? {
        return durationRemaining
    }

    private val mSurfaceCallback: SurfaceCallback = object : SurfaceCallback {
        // Handle surface callback event here
        override fun onClick(x: Float, y: Float) {
            val clickedLatLng = vietmapGL?.projection?.fromScreenLocation(PointF(x, y))
            clickedLatLng?.let {
                automotiveCommunicator.onMapClick(it.latitude, it.longitude)
            }
        }
    }

    fun setAutomotiveCommunicator(automotiveCommunicator: IAutomotiveCommunicator) {
        this.automotiveCommunicator = automotiveCommunicator
    }

    fun init(styleUrl: String, apiKey: String) {
        this.apikey = apiKey
        locationEngine = if (simulateRoute) {
            ReplayRouteLocationEngine()
        } else {
            LocationEngineProvider.getBestLocationEngine(carContext)
        }

        mSurfaceRenderer.addOnSurfaceCallbackListener(mSurfaceCallback)
        mSurfaceRenderer.init(
            Style.Builder()
                .fromUri(styleUrl),
            {
                val routeLineLayer = LineLayer("line-layer-id", "source-id")
                routeLineLayer.setProperties(
                    lineWidth(9f),
                    lineColor(Color.RED),
                    lineCap(LINE_CAP_ROUND),
                    lineJoin(LINE_JOIN_ROUND)
                )

                enableLocationComponent(it)
                initMapRoute()
                automotiveCommunicator.onStyleLoaded()
            },
            {
                isMapReady = true
                isMapViewStarted = true
                automotiveCommunicator.onMapReady()
                vietmapGL = it
                invalidate()
            }
        )
        mapView = mSurfaceRenderer.getMapView()
        mapView?.addOnDidFinishRenderingMapListener { isFinished ->
            if (isFinished) automotiveCommunicator.onMapRendered()
        }
        vietmapNavigation = VietmapNavigation(
            carContext,
            navigationOptions,
            locationEngine!!,
        )
        configSpeechPlayer()
        invalidate()
    }

    private fun initMapRoute() {
        if (vietmapGL != null) {
            navigationMapRoute =
                NavigationMapRoute(
                    mSurfaceRenderer.getMapView()!!,
                    vietmapGL!!,
                    "vmadmin_province"
                )
        }
    }


    private fun configSpeechPlayer() {
        var speechPlayerProvider = SpeechPlayerProvider(carContext, "vi", true)
        this.speechPlayer = NavigationSpeechPlayer(speechPlayerProvider)
    }


    override fun onGetTemplate(): Template {
        return vietmapNavigationSurfaceHelper.getNavigationTemplate()
    }


    fun addMarker(data: List<Map<String, Any>>): ArrayList<Long> {
        val listMarkerId = ArrayList<Long>()
        try {
            data.forEach {
                try {
                    val d = it
                    val latitude = d["lat"] as? Double ?: return@forEach
                    val longitude = d["lng"] as? Double ?: return@forEach
                    val position = LatLng(latitude, longitude)
                    val title = d["title"] as? String ?: ""
                    val snippet = d["snippet"] as? String ?: ""
                    val base64Encoded = d["base64Encoded"] as? String
                    val width = d["width"] as? Int
                    val height = d["height"] as? Int

                    val iconBitmap = base64Encoded?.let {
                        val decodedString =
                            android.util.Base64.decode(it, android.util.Base64.DEFAULT)
                        BitmapFactory.decodeByteArray(decodedString, 0, decodedString.size)
                    }

                    val scaledBitmap = if (iconBitmap != null && width != null && height != null) {
                        Bitmap.createScaledBitmap(iconBitmap, width, height, false)
                    } else {
                        iconBitmap
                    }

                    val icon = scaledBitmap?.let { scaledBM ->
                        IconFactory.getInstance(carContext).fromBitmap(scaledBM)
                    }

                    val markerOption = MarkerOptions()
                        .icon(icon)
                        .title(title)
                        .snippet(snippet)
                        .position(position)

                    val marker = vietmapGL?.addMarker(markerOption)

                    marker?.let { m ->
                        listMarkerId.add(m.id)
                        listMarkers.add(m)
                    }
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }

            return listMarkerId
        } catch (e: Exception) {
            e.printStackTrace()
            return listMarkerId
        }
    }

    fun removeMarker(data: Map<String, Any>): Boolean {
        val markersIdList = data["markerIds"] as ArrayList<Int>
        try {
            markersIdList.forEach { markerId ->
                val temp = ArrayList<Marker>()
                listMarkers.forEach {
                    if (it.id == markerId.toLong()) {
                        it.remove()
                        temp.add(it)
                    }
                }
                listMarkers.removeAll(temp.toSet())
            }
            return true
        } catch (e: Exception) {
            e.printStackTrace()
            return false
        }
    }

    fun removeAllMarkers(): Boolean {
        try {
            listMarkers.forEach {
                it.remove()
            }
            return true
        } catch (e: Exception) {
            e.printStackTrace()
            return false
        }
    }

    fun addPolylines(mapData: Map<String, Any>): ArrayList<Long> {
        val polylineIds = ArrayList<Long>()
        try {
            val polylineList = mapData["polylines"] as List<Map<String, Any>>
            polylineList.forEach { data ->
                try {
                    val points = data["points"] as List<Map<String, Double>>
                    val latLngList = ArrayList<LatLng>()
                    points.forEach {
                        val lat = it["lat"] as Double
                        val lng = it["lng"] as Double
                        latLngList.add(LatLng(lat, lng))
                    }
                    val polylineColor =
                        data["color"] as? String? ?: "#${R.color.vietmap_blue.toHexString()}"

                    val polylineOptions = PolylineOptions().let {
                        it.addAll(latLngList)
                        it.color(Color.parseColor(polylineColor))
                        it.width(data["width"] as? Float? ?: 10.0f)
                        it.alpha(data["alpha"] as? Float? ?: 1.0f)
                        it
                    }

                    val polyline = vietmapGL?.addPolyline(polylineOptions)
                    polyline?.let { p ->
                        polylineIds.add(p.id)
                        listPolylines.add(p)
                    }
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }
            return polylineIds
        } catch (e: Exception) {
            e.printStackTrace()
            return polylineIds
        }
    }

    fun removePolyline(data: Map<String, Any>): Boolean {
        val polylineIds = data["polylineIds"] as ArrayList<Long>
        try {
            val temp = ArrayList<Polyline>()
            polylineIds.forEach { polylineId ->
                listPolylines.forEach {
                    if (it.id == polylineId) {
                        it.remove()
                        temp.add(it)
                    }
                }
            }
            listPolylines.removeAll(temp.toSet())
            return true
        } catch (e: Exception) {
            e.printStackTrace()
            return false
        }
    }

    fun removeAllPolylines(): Boolean {
        try {
            listPolylines.forEach {
                it.remove()
            }
            return true
        } catch (e: Exception) {
            e.printStackTrace()
            return false
        }
    }

    fun addPolygons(mapData: Map<String, Any>): ArrayList<Long> {
        val polygonIds = ArrayList<Long>()
        try {
            val polygonList = mapData["polygons"] as List<Map<String, Any>>
            polygonList.forEach { data ->
                try {
                    val points = data["points"] as List<Map<String, Double>>
                    val holes = data["holes"] as List<List<Map<String, Double>>>
                    val pointLatLngList = ArrayList<LatLng>()
                    val holeLatLngList = ArrayList<List<LatLng>>()

                    points.forEach {
                        val lat = it["lat"] as Double
                        val lng = it["lng"] as Double
                        pointLatLngList.add(LatLng(lat, lng))
                    }

                    holes.forEach { hole ->
                        val holeList = ArrayList<LatLng>()
                        hole.forEach {
                            val lat = it["lat"] as Double
                            val lng = it["lng"] as Double
                            holeList.add(LatLng(lat, lng))
                        }
                        holeLatLngList.add(holeList)
                    }

                    val fillColor =
                        data["fillColor"] as? String? ?: "#${R.color.vietmap_blue.toHexString()}"
                    val strokeColor =
                        data["strokeColor"] as? String? ?: "#${R.color.vietmap_blue.toHexString()}"

                    val polygonOptions = PolygonOptions().let {
                        it.addAll(pointLatLngList)
                        it.fillColor(Color.parseColor(fillColor))
                        it.strokeColor(Color.parseColor(strokeColor))
                        it.alpha(data["alpha"] as? Float? ?: 1.0f)
                        it.addAllHoles(holeLatLngList)
                        it
                    }

                    val polygon = vietmapGL?.addPolygon(polygonOptions)
                    polygon?.let { p ->
                        polygonIds.add(p.id)
                        listPolygons.add(p)
                    }
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }
            return polygonIds
        } catch (e: Exception) {
            e.printStackTrace()
            return polygonIds
        }
    }

    fun removePolygon(data: Map<String, Any>): Boolean {
        val polygonIds = data["polygonIds"] as ArrayList<Long>
        try {
            val temp = ArrayList<Polygon>()
            polygonIds.forEach { polygonId ->
                listPolygons.forEach {
                    if (it.id == polygonId) {
                        it.remove()
                        temp.add(it)
                    }
                }
            }
            listPolygons.removeAll(temp.toSet())
            return true
        } catch (e: Exception) {
            e.printStackTrace()
            return false
        }
    }

    fun removeAllPolygons(): Boolean {
        try {
            listPolygons.forEach {
                it.remove()
            }
            return true
        } catch (e: Exception) {
            e.printStackTrace()
            return false
        }
    }

    fun buildRoute(arguments: Map<*, *>): Boolean {
        isNavigationCanceled = false
        isNavigationInProgress = false

        setOptions(arguments)

        if (isMapReady) {
            wayPoints.clear()
            val wayPointsList = arguments["wayPoints"] as HashMap<*, *>
            for (item in wayPointsList) {
                val point = item.value as HashMap<*, *>
                val latitude = point["latitude"] as Double
                val longitude = point["longitude"] as Double
                wayPoints.add(Point.fromLngLat(longitude, latitude))
            }
            val profile = arguments["profile"] as? String ?: "driving-traffic"
            val originWayPoint = wayPoints[0]
            originPoint = Point.fromLngLat(originWayPoint.longitude(), originWayPoint.latitude())
            val destinationWayPoint = wayPoints[1]
            destinationPoint =
                Point.fromLngLat(destinationWayPoint.longitude(), destinationWayPoint.latitude())
            val startNavigation = arguments["startNavigation"] as? Boolean ?: false
            fetchRouteWithBearing(startNavigation, profile)

            return true
        } else {
            return false
        }
    }

    private fun setOptions(arguments: Map<*, *>) {
        val navMode = arguments["mode"] as? String
        if (navMode != null) {
            profile = navMode
            when (navMode) {
                "walking" -> {
                    navigationMode = DirectionsCriteria.PROFILE_WALKING
                }

                "cycling" -> {
                    navigationMode = DirectionsCriteria.PROFILE_CYCLING
                }

                "driving" -> {
                    navigationMode = DirectionsCriteria.PROFILE_DRIVING
                }

            }
        }

        val simulated = arguments["simulateRoute"] as? Boolean
        if (simulated != null) {
            simulateRoute = simulated
        }

        val language = arguments["language"] as? String
        if (language != null) navigationLanguage = Locale(language)

        val units = arguments["units"] as? String

        if (units != null) {
            if (units == "imperial") navigationVoiceUnits = DirectionsCriteria.IMPERIAL
            else if (units == "metric") navigationVoiceUnits = DirectionsCriteria.METRIC
        }
        val styleUrl = arguments["mapStyle"] as? String

        if (styleUrl != null && styleUrl != "") {
            mapStyleURL = styleUrl
        }
        val apik = arguments["apikey"] as? String
        if (apik != null && apik != "") {
            apikey = apik
        }


        val byteArray = arguments["customLocationCenterIcon"] as? ByteArray
        if (byteArray != null) {
            this.bitmapDrawable = loadImageFromBinary(byteArray)
        }

        initialLatitude = arguments["initialLatitude"] as? Double
        initialLongitude = arguments["initialLongitude"] as? Double

        val zm = arguments["zoom"] as? Double
        if (zm != null) zoom = zm

        val br = arguments["bearing"] as? Double
        if (br != null) bearing = br

        val tt = arguments["tilt"] as? Double
        if (tt != null) tilt = tt

        val optim = arguments["isOptimized"] as? Boolean
        if (optim != null) isOptimized = optim

        val anim = arguments["animateBuildRoute"] as? Boolean
        if (anim != null) animateBuildRoute = anim

        val altRoute = arguments["alternatives"] as? Boolean
        if (altRoute != null) alternatives = altRoute

        val voiceEnabled = arguments["voiceInstructionsEnabled"] as? Boolean
        if (voiceEnabled != null) {
            voiceInstructionsEnabled = voiceEnabled
            speechPlayer?.let {

                speechPlayer!!.isMuted = voiceEnabled
            }
        }

        val bannerEnabled = arguments["bannerInstructionsEnabled"] as? Boolean
        if (bannerEnabled != null) bannerInstructionsEnabled = bannerEnabled

        var longPress = arguments["longPressDestinationEnabled"] as? Boolean
        if (longPress != null) longPressDestinationEnabled = longPress
    }


    override fun zoomIn() {
        vietmapGL?.animateCamera(CameraUpdateFactory.zoomIn())
    }

    override fun zoomOut() {
        vietmapGL?.animateCamera(CameraUpdateFactory.zoomBy(-1.0))
    }

    override fun recenter() {
        isOverviewing = false
        if (currentCenterPoint != null) {
            moveCamera(
                LatLng(currentCenterPoint!!.latitude, currentCenterPoint!!.longitude),
                currentCenterPoint!!.bearing
            )
        } else {
            vietmapGL?.locationComponent?.lastKnownLocation?.let {
                moveCamera(
                    LatLng(it.latitude, it.longitude),
                    it.bearing
                )
            }
        }
    }

    fun recenter(args: Map<*, *>?) {
        if (args != null) {
            setOptions(args)
        }
        recenter()
    }

    override fun overviewRoute() {
        isOverviewing = true
        if (currentRoute != null) {
            val routePoints: List<Point> =
                currentRoute?.routeOptions()?.coordinates() as List<Point>
            animateVietmapGLForRouteOverview(padding, routePoints)
        }
    }

    override fun clearRoute(): Boolean {
        if (navigationMapRoute != null) {
            navigationMapRoute?.removeRoute()
        }
        currentRoute = null
        vietmapNavigationSurfaceHelper.initNavigationTemplate()
        invalidate()
        recenter()
        return true
    }

    fun startNavigation(arguments: Map<*, *>?): Boolean {
        if (arguments != null) setOptions(arguments)

        startNavigation()

        return currentRoute != null
    }

    override fun startNavigation() {
        tilt = 45.0
        zoom = 19.0
        isOverviewing = false
        isNavigationCanceled = false
        vietmapGL?.locationComponent?.cameraMode = CameraMode.TRACKING_GPS_NORTH

        if (currentRoute != null) {
            if (simulateRoute) {
                val mockLocationEngine = ReplayRouteLocationEngine()
                mockLocationEngine.assign(currentRoute)
                vietmapNavigation?.locationEngine = mockLocationEngine
            } else {
                locationEngine?.let {
                    vietmapNavigation?.locationEngine = it
                }
            }
            isRunning = true
            vietmapGL?.locationComponent?.locationEngine = null
            vietmapNavigation?.addNavigationEventListener(this)
            vietmapNavigation?.addFasterRouteListener(this)
            vietmapNavigation?.addMilestoneEventListener(this)
            vietmapNavigation?.addOffRouteListener(this)
            vietmapNavigation?.addProgressChangeListener(this)
            vietmapNavigation?.snapEngine = snapEngine
            navigationMapRoute!!.showAlternativeRoutes(true)
            currentRoute?.let {
                vietmapNavigationSurfaceHelper.updateOnStartNavigationTemplate()
                invalidate()
                isNavigationInProgress = true
                vietmapNavigation?.startNavigation(currentRoute!!)
                recenter()
            }
        }
    }

    override fun stopNavigation() : Boolean {
        finishNavigation()
        return currentRoute != null
    }

    fun overviewRoute(arguments: Map<*, *>?) {
        if (arguments != null) setOptions(arguments)
        overviewRoute()
    }

    private fun moveCamera(location: LatLng, bearing: Float?) {
        val cameraPosition = CameraPosition.Builder().target(location).zoom(zoom).tilt(tilt)

        if (bearing != null) {
            cameraPosition.bearing(bearing.toDouble())
        }

        val duration = 1000
        vietmapGL?.easeCamera(
            CameraUpdateFactory.newCameraPosition(cameraPosition.build()), duration
        )
    }

    private fun fetchRouteWithBearing(isStartNavigation: Boolean, profile: String) {
        isPreviewingRoute = true
        if (!checkPermission()) return
        locationEngine?.getLastLocation(object : LocationEngineCallback<LocationEngineResult> {
            override fun onSuccess(result: LocationEngineResult) {

                val location = result.lastLocation
                location?.let {
                    originPoint = Point.fromLngLat(it.longitude, it.latitude)
                }
                if (location != null) {
                    getRoute(isStartNavigation, location.bearing, profile)
                } else {
                    getRoute(isStartNavigation, null, profile)
                }
            }

            override fun onFailure(exception: Exception) {
                getRoute(isStartNavigation, null, profile)
            }
        })
    }

    private fun getRoute(
        isStartNavigation: Boolean, bearing: Float?, profile: String,
    ) {
        val br = bearing ?: 0.0
        val builder = NavigationRoute.builder(carContext)
            .apikey(apikey ?: "")
            .origin(originPoint!!, 60.0, br.toDouble()).destination(destinationPoint!!)
            .alternatives(true)
            ///driving-traffic
            ///cycling
            ///walking
            ///motorcycle
            .profile(profile).build()
        builder.getRoute(object : Callback<DirectionsResponse> {
            override fun onResponse(
                call: Call<DirectionsResponse?>, response: Response<DirectionsResponse?>,
            ) {
                if (response.body() == null || response.body()!!.routes().size < 1) {
                    return
                }
                directionsRoutes = response.body()!!.routes()
                currentRoute = if (directionsRoutes!!.size <= primaryRouteIndex) {
                    directionsRoutes!![0]
                } else {
                    directionsRoutes!![primaryRouteIndex]
                }

                // Draw the route on the map
                if (navigationMapRoute != null) {
                    navigationMapRoute?.removeRoute()
                } else {
                    navigationMapRoute = NavigationMapRoute(
                        mSurfaceRenderer.getMapView()!!,
                        vietmapGL!!,
                        "vmadmin_province"
                    )
                }

                //show multiple route to map
                if (response.body()!!.routes().size > 1) {
                    navigationMapRoute?.let {
                        it.addRoutes(directionsRoutes!!)
                        it.showAlternativeRoutes(true)
                    }
                } else {
                    navigationMapRoute?.addRoute(currentRoute)
                }


                isBuildingRoute = false
                // get route point from current route
                val routePoints: List<Point> =
                    currentRoute?.routeOptions()?.coordinates() as List<Point>
                animateVietmapGLForRouteOverview(padding, routePoints)
                vietmapNavigationSurfaceHelper.updateOnRouteBuiltTemplate()
                invalidate()
                //Start Navigation again from new Point, if it was already in Progress
                if (isNavigationInProgress || isStartNavigation) {
                    startNavigation()
                }
            }

            override fun onFailure(call: Call<DirectionsResponse?>, throwable: Throwable) {
                isBuildingRoute = false

            }
        })
    }

    private fun animateVietmapGLForRouteOverview(padding: IntArray, routePoints: List<Point>) {
        isOverviewing = true
        if (routePoints.size <= 1) {
            return
        }
        val resetUpdate: CameraUpdate = VietMapNavigationHelper.buildResetCameraUpdate()
        val overviewUpdate: CameraUpdate =
            VietMapNavigationHelper.buildOverviewCameraUpdate(padding, routePoints)
        vietmapGL?.animateCamera(
            resetUpdate, 150, CameraOverviewCancelableCallback(overviewUpdate, vietmapGL)
        )
    }


    private fun enableLocationComponent(loadedMapStyle: Style) {
        locationComponent = vietmapGL?.locationComponent
        if (locationComponent != null) {
            locationComponent!!.activateLocationComponent(
                LocationComponentActivationOptions.builder(
                    carContext, loadedMapStyle
                ).locationComponentOptions(
                    LocationComponentOptions.builder(carContext)
                        .pulseEnabled(true)
                        .maxZoomIconScale(2.5f)
                        .minZoomIconScale(2.0f)
                        .build()
                ).build()
            )
            if (!checkPermission()) {
                return
            }
            locationComponent!!.setCameraMode(
                CameraMode.TRACKING_GPS_NORTH, 750L,
                zoom,
                locationComponent!!.lastKnownLocation?.bearing?.toDouble() ?: 0.0,
                tilt,
                null
            )
            locationComponent!!.isLocationComponentEnabled = true
            locationComponent!!.zoomWhileTracking(19.0)
            locationComponent!!.renderMode = RenderMode.GPS
            locationComponent!!.locationEngine = locationEngine
        }
    }

    private fun checkPermission(): Boolean {
        return ActivityCompat.checkSelfPermission(
            carContext, ACCESS_FINE_LOCATION
        ) == PackageManager.PERMISSION_GRANTED || ActivityCompat.checkSelfPermission(
            carContext, ACCESS_COARSE_LOCATION
        ) == PackageManager.PERMISSION_GRANTED
    }

    private fun loadImageFromBinary(binaryData: ByteArray): BitmapDrawable {
        val bitmap: Bitmap = BitmapFactory.decodeByteArray(binaryData, 0, binaryData.size)
        return BitmapDrawable(carContext.resources, bitmap)
    }

    override fun onRunning(running: Boolean) {
        /// On running
    }

    override fun fasterRouteFound(p0: DirectionsRoute?) {
        /// Faster route found
    }

    override fun onMilestoneEvent(
        routeProgress: RouteProgress?,
        instruction: String?,
        milestone: Milestone?
    ) {
        if (voiceInstructionsEnabled) {
            playVoiceAnnouncement(milestone)
        }
        if (routeProgress == null || milestone == null) return
        if (routeUtils.isArrivalEvent(routeProgress, milestone) && isNavigationInProgress) {
            vietmapGL?.locationComponent?.locationEngine = locationEngine
            isPreviewingRoute = false
            finishNavigation()
        }
        if (!isNavigationCanceled) {
            Log.d("Milestone", "Milestone: $milestone")
        }
    }

    private fun playVoiceAnnouncement(milestone: Milestone?) {
        if (milestone is VoiceInstructionMilestone) {
            val announcement = SpeechAnnouncement.builder()
                .voiceInstructionMilestone(milestone as VoiceInstructionMilestone?).build()
            speechPlayer!!.play(announcement)
        }
    }


    override fun userOffRoute(location: Location) {
        if (checkIfUserOffRoute(location)) {
            speechPlayer?.onOffRoute()
            doOnNewRoute(Point.fromLngLat(location.longitude, location.latitude))
        }
    }

    private fun doOnNewRoute(offRoutePoint: Point?) {
        if (!isBuildingRoute) {
            isBuildingRoute = true

            offRoutePoint?.let {
                finishNavigation(isOffRouted = true)
                moveCamera(LatLng(it.latitude(), it.longitude()), null)
            }

            originPoint = offRoutePoint
            isNavigationInProgress = true
            fetchRouteWithBearing(false, profile)
        }
    }

    private fun finishNavigation(isOffRouted: Boolean = false) {
        bearing = 0.0
        tilt = 0.0
        isNavigationCanceled = true

        if (!isOffRouted) {
            isNavigationInProgress = false
        }

        if (currentRoute != null) {
            isRunning = false
            currentCenterPoint = null
            vietmapNavigation?.stopNavigation()
            vietmapNavigation?.removeFasterRouteListener(this)
            vietmapNavigation?.removeMilestoneEventListener(this)
            vietmapNavigation?.removeNavigationEventListener(this)
            vietmapNavigation?.removeOffRouteListener(this)
            vietmapNavigation?.removeProgressChangeListener(this)
            clearRoute()
            vietmapNavigationSurfaceHelper.initNavigationTemplate()
            invalidate()
            recenter()
        }
    }



    private fun checkIfUserOffRoute(location: Location): Boolean {
        if (routeProgress?.currentStepPoints() != null) {
            val snapLocation: Location = snapEngine.getSnappedLocation(location, routeProgress)
            val distance: Double =
                VietMapNavigationHelper.calculateDistanceBetween2Point(location, snapLocation)
            return distance > this.distanceToOffRoute && checkIfUserIsDrivingToOtherRoute(location)
        }
        return false
    }

    private fun checkIfUserIsDrivingToOtherRoute(location: Location): Boolean {
        directionsRoutes?.forEach {
            //get list point
            snapLocationLatLng(
                location,
                it.routeOptions()?.coordinates() as List<Point>
            )?.let { snapLocation ->
                val distance: Double = VietMapNavigationHelper.calculateDistanceBetween2Point(location, snapLocation)
                if (distance < 30) {
                    if (it != currentRoute) {
                        currentRoute = it
                        currentRoute?.toJson()?.let { it1 ->
//                            PluginUtilities.sendEvent(
//                                VietMapEvents.ON_NEW_ROUTE_SELECTED,
//                                it1
//                            )
                            return false
                        }
                    }

                }
            }
        }
        return true
    }

    private fun snapLocationLatLng(location: Location, stepCoordinates: List<Point>): Location? {
        val snappedLocation = Location(location)
        val locationToPoint = Point.fromLngLat(location.longitude, location.latitude)
        if (stepCoordinates.size > 1) {
            val feature = TurfMisc.nearestPointOnLine(locationToPoint, stepCoordinates)
            val point = feature.geometry() as Point?
            snappedLocation.longitude = point!!.longitude()
            snappedLocation.latitude = point.latitude()
        }
        return snappedLocation
    }

    @RequiresApi(26)
    override fun onProgressChange(location: Location?, routeProgress: RouteProgress?) {
        var currentSpeed = location?.speed
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            currentSpeed = location?.speedAccuracyMetersPerSecond
        }
        if (!isNavigationCanceled) {
            try {
                val noRoutes: Boolean = directionsRoutes?.isEmpty() ?: true
                if (primaryRouteIndex >= (directionsRoutes?.size ?: 0)) {
                    primaryRouteIndex = directionsRoutes?.size?.minus(1) ?: 0
                }
                val newCurrentRoute: Boolean = !routeProgress!!.directionsRoute()
                    .equals(directionsRoutes?.get(primaryRouteIndex))
                val isANewRoute: Boolean = noRoutes || newCurrentRoute
                if (!isANewRoute) {
                    distanceRemaining = routeProgress.distanceRemaining()
                    durationRemaining = routeProgress.durationRemaining()

                    if (!isBuildingRoute) {
                        val snappedLocation: Location =
                            snapEngine.getSnappedLocation(location, routeProgress)

                        currentCenterPoint =
                            CurrentCenterPoint(
                                snappedLocation.latitude,
                                snappedLocation.longitude,
                                snappedLocation.bearing
                            )
                        if (!isOverviewing) {
                            this.routeProgress = routeProgress
                            if (currentSpeed!! > 0) {
                                animateBuildRoute = false
                                moveCamera(
                                    LatLng(snappedLocation.latitude, snappedLocation.longitude),
                                    snappedLocation.bearing
                                )
                            }
                        }

                        vietmapGL?.locationComponent?.forceLocationUpdate(snappedLocation)
                    }
                    if (!isRefreshing) {
                        isRefreshing = true
                    }
                }

                handleProgressChange(routeProgress, location!!)
            } catch (e: java.lang.Exception) {
                Log.e("onProgressChange", e.message.toString())
                e.printStackTrace()
            }
        }
    }

    @RequiresApi(26)
    private fun handleProgressChange(routeProgress: RouteProgress, location: Location) {
        if (location.speed < 1) return

        val distanceRemainingToNextTurn =
            routeProgress.currentLegProgress()?.currentStepProgress()?.distanceRemaining()
        val turnGuideText: String =
            routeProgress.currentLegProgress()?.currentStep()?.maneuver()?.instruction().toString()

        val distanceToNextTurn =
            routeProgress.currentLegProgress()?.currentStepProgress()?.distanceRemaining().let {
                if (it != null) {
                    round(it)
                } else {
                    0.0
                }
            }
        val distanceEstimate = round(routeProgress.distanceRemaining())
        val durationEstimate = round(routeProgress.durationRemaining())
        val durationRemaining = round(routeProgress.durationRemaining())
        updateTravelEstimate(
            distanceEstimate,
            durationEstimate.toLong(),
            "Còn ${VietMapNavigationHelper.getDisplayDuration(durationRemaining / 60)}"
        )
        updateManeuver()
        updateStep(turnGuideText)

        updateRoutingInfo(distanceToNextTurn)
        invalidate()
        if (isOverviewing) return
        if (distanceRemainingToNextTurn != null && distanceRemainingToNextTurn < 30) {
            isNextTurnHandling = true
            val resetPosition: CameraPosition =
                CameraPosition.Builder().tilt(tilt).zoom(17.0).bearing(bearing).build()
            val cameraUpdate = CameraUpdateFactory.newCameraPosition(resetPosition)
            vietmapGL?.animateCamera(
                cameraUpdate, 1000
            )
        } else {
            if (routeProgress.currentLegProgress().currentStepProgress()
                    .distanceTraveled() > 30 && !isOverviewing
            ) {
                isNextTurnHandling = false
            }
        }
    }

    @RequiresApi(26)
    private fun updateTravelEstimate(
        distanceEstimate: Double,
        durationEstimate: Long,
        descriptionText: String,
    ) {
        vietmapNavigationSurfaceHelper.updateTravelEstimate(
            distanceEstimate,
            durationEstimate,
            descriptionText
        )
    }

    private fun updateManeuver() {
        vietmapNavigationSurfaceHelper.updateManeuver(routeProgress)
    }

    private fun updateRoutingInfo(distanceToNextTurn: Double) {
        vietmapNavigationSurfaceHelper.updateRoutingInfo(distanceToNextTurn)
    }

    private fun updateStep(cueGuide: String) {
        vietmapNavigationSurfaceHelper.updateStep(cueGuide)
    }


    fun animateCamera(args: Map<*, *>?) {
        val location = LatLng(
            args?.get("latitude") as Double,
            args["longitude"] as Double
        )
        val zoom = args["zoom"] as Double?
        val bearing = args["bearing"] as Double?
        val tilt = args["tilt"] as Double?
        val duration = args["duration"] as Int

        isOverviewing = true
        val cameraPosition = CameraPosition.Builder().target(location)
        zoom?.let {
            cameraPosition.zoom(it)
        }
        tilt?.let {
            cameraPosition.tilt(it)
        }

        if (bearing != null) {
            cameraPosition.bearing(bearing.toDouble())
        }
        vietmapGL?.animateCamera(
            CameraUpdateFactory.newCameraPosition(cameraPosition.build()), duration
        )
    }

    fun moveCamera(args: Map<*, *>?) {
        val location = LatLng(
            args?.get("latitude") as Double,
            args["longitude"] as Double
        )
        val zoom = args["zoom"] as Double?
        val bearing = args["bearing"] as Double?
        val tilt = args["tilt"] as Double?

        isOverviewing = true
        val cameraPosition = CameraPosition.Builder().target(location)
        zoom?.let {
            cameraPosition.zoom(it)
        }
        tilt?.let {
            cameraPosition.tilt(it)
        }

        if (bearing != null) {
            cameraPosition.bearing(bearing.toDouble())
        }
        vietmapGL?.moveCamera(
            CameraUpdateFactory.newCameraPosition(cameraPosition.build())
        )
    }
}