package vn.vietmap.vietmap_automotive_flutter

import android.util.Log
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleObserver
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.MediatorLiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ProcessLifecycleOwner
import androidx.lifecycle.lifecycleScope
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import vn.vietmap.androidauto.VietMapCarAppScreen
import vn.vietmap.androidauto.VietMapCarAppSession
import vn.vietmap.androidauto.communicate_interface.IAutomotiveCommunicator
import vn.vietmap.androidauto.events.VietmapAutomotiveEvent
import vn.vietmap.vietmapsdk.geometry.LatLng

class VietmapAutomotiveFlutterPlugin: FlutterPlugin, MethodCallHandler, LifecycleObserver, LifecycleOwner {
    private lateinit var channel : MethodChannel
    private var vietmapCarApp : VietMapCarAppScreen? = null
    private val styleUrl: MutableLiveData<String> = MutableLiveData("")
    private val apiKey: MutableLiveData<String> = MutableLiveData("")
    private val resourcesLiveData: MediatorLiveData<Pair<String, String>> = MediatorLiveData()
    private var isConnectToAndroidAuto = false
    override val lifecycle: Lifecycle
        get() = ProcessLifecycleOwner.get().lifecycle

    private val automotiveCommunicator = object : IAutomotiveCommunicator {
        override fun onStyleLoaded() {
            channel.invokeMethod(VietmapAutomotiveEvent.ON_MAP_STYLE_LOADED.nameValue, null)
        }

        override fun onMapRendered() {
            channel.invokeMethod(VietmapAutomotiveEvent.ON_MAP_RENDERED.nameValue, null)
        }

        override fun onMapReady() {
            channel.invokeMethod(VietmapAutomotiveEvent.ON_MAP_READY.nameValue, null)
        }

        override fun onMapClick(lat: Double, lng: Double) {
            channel.invokeMethod(VietmapAutomotiveEvent.ON_MAP_CLICK.nameValue, mapOf("lat" to lat, "lng" to lng))
        }
    }


    init {
        resourcesLiveData.apply {
            addSource(styleUrl) { styleUrlString ->
                value = Pair(styleUrlString , apiKey.value ?: "")
            }
            addSource(apiKey) { apiKeyString ->
                value = Pair(styleUrl.value ?: "", apiKeyString)
            }
        }
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "vietmap_automotive_flutter")
        channel.setMethodCallHandler(this)
        lifecycle.addObserver(this)
        VietMapCarAppSession.carAppScreenInstance.observe(this) { screen ->
            if(screen == null) return@observe
            vietmapCarApp = screen
            vietmapCarApp?.setAutomotiveCommunicator(automotiveCommunicator)
            isConnectToAndroidAuto = true
        }
        resourcesLiveData.observe(this) { pair ->
            if(pair.first.isNotEmpty() && pair.second.isNotEmpty() && vietmapCarApp != null){
                vietmapCarApp?.init(pair.first, pair.second)
            }
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if(!isConnectToAndroidAuto){
            result.success("android_auto_disconnected")
            return
        }

        when (call.method) {
            VietmapAutomotiveEvent.GET_PLATFORM_VERSION.nameValue -> {
              result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }
            VietmapAutomotiveEvent.INIT_AUTOMOTIVE.nameValue -> {
              val data = call.arguments as Map<*, *>
              apiKey.postValue(data["vietMapAPIKey"] as String)
              styleUrl.postValue(data["styleUrl"] as String)
              result.success(true)
            }
            VietmapAutomotiveEvent.ADD_MARKERS.nameValue -> {
                val listMarkerIds = vietmapCarApp?.addMarker(call.arguments as List<Map<String, Any>>)
                result.success(listMarkerIds)
            }
            VietmapAutomotiveEvent.REMOVE_MARKER.nameValue -> {
                val data = call.arguments as Map<String, Any>
                val isRemoved = vietmapCarApp?.removeMarker(data) ?: false
                result.success(isRemoved)
            }
            VietmapAutomotiveEvent.REMOVE_ALL_MARKERS.nameValue -> {
                val isRemoved = vietmapCarApp?.removeAllMarkers() ?: false
                result.success(isRemoved)
            }
            VietmapAutomotiveEvent.ADD_POLYLINES.nameValue -> {
                val data = call.arguments as Map<String, Any>
                val listPolylineIds = vietmapCarApp?.addPolylines(data)
                result.success(listPolylineIds)
            }
            VietmapAutomotiveEvent.REMOVE_POLYLINE.nameValue -> {
                val data = call.arguments as Map<String, Any>
                val isRemoved = vietmapCarApp?.removePolyline(data) ?: false
                result.success(isRemoved)
            }
            VietmapAutomotiveEvent.REMOVE_ALL_POLYLINES.nameValue -> {
                val isRemoved = vietmapCarApp?.removeAllPolylines() ?: false
                result.success(isRemoved)
            }
            VietmapAutomotiveEvent.ADD_POLYGONS.nameValue -> {
                val data = call.arguments as Map<String, Any>
                val listPolygonIds = vietmapCarApp?.addPolygons(data)
                result.success(listPolygonIds)
            }
            VietmapAutomotiveEvent.REMOVE_ALL_POLYGONS.nameValue -> {
                val isRemoved = vietmapCarApp?.removeAllPolygons() ?: false
                result.success(isRemoved)
            }
            VietmapAutomotiveEvent.REMOVE_POLYGON.nameValue -> {
                val data = call.arguments as Map<String, Any>
                val isRemoved = vietmapCarApp?.removePolygon(data) ?: false
                result.success(isRemoved)
            }
            VietmapAutomotiveEvent.BUILD_ROUTE.nameValue -> {
                val data = call.arguments as Map<*,*>
                val isRouteBuilt = vietmapCarApp?.buildRoute(data)
                result.success(isRouteBuilt)
            }
            VietmapAutomotiveEvent.OVERVIEW_ROUTE.nameValue -> {
                val data = call.arguments as? Map<*, *>
                vietmapCarApp?.overviewRoute(data)
            }
            VietmapAutomotiveEvent.CLEAR_ROUTE.nameValue -> {
                val clearRouteSuccessfully = vietmapCarApp?.clearRoute()
                result.success(clearRouteSuccessfully)
            }
            VietmapAutomotiveEvent.START_NAVIGATION.nameValue -> {
                val data = call.arguments as? Map<*, *>
                val startNavigationSuccessfully = vietmapCarApp?.startNavigation(data)
                result.success(startNavigationSuccessfully)
            }
            VietmapAutomotiveEvent.STOP_NAVIGATION.nameValue -> {
                val stopNavigationSuccessfully = vietmapCarApp?.stopNavigation()
                result.success(stopNavigationSuccessfully)
            }
            VietmapAutomotiveEvent.ZOOM_IN.nameValue -> {
                vietmapCarApp?.zoomIn()
            }
            VietmapAutomotiveEvent.ZOOM_OUT.nameValue -> {
                vietmapCarApp?.zoomOut()
            }
            VietmapAutomotiveEvent.RECENTER.nameValue -> {
                val args = call.arguments as? Map<*, *>
                val recenterSuccessfully = vietmapCarApp?.recenter(args)
                result.success(recenterSuccessfully)
            }
            VietmapAutomotiveEvent.ANIMATE_CAMERA.nameValue -> {
                val args = call.arguments as? Map<*, *>
                vietmapCarApp?.animateCamera(args)
            }
            VietmapAutomotiveEvent.MOVE_CAMERA.nameValue -> {
                val args = call.arguments as? Map<*, *>
                vietmapCarApp?.moveCamera(args)
            }
            VietmapAutomotiveEvent.DISTANCE_REMAINING.nameValue -> {
                result.success(vietmapCarApp?.getDistanceRemaining())
            }
            VietmapAutomotiveEvent.DURATION_REMAINING.nameValue -> {
                result.success(vietmapCarApp?.getDurationRemaining())
            }
            VietmapAutomotiveEvent.TOGGLE_MUTE.nameValue -> {
                val args = call.arguments as? Map<*,*>
                val isMutedArgs : Boolean = (args?.get("isMuted") as? Boolean) ?: false
                val isMuted = vietmapCarApp?.muteVoiceInstructions(isMutedArgs)
                result.success(isMuted)
            }
            else -> {
              result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
