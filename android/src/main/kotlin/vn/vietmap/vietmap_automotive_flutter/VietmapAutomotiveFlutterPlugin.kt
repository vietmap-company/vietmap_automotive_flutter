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
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import vn.vietmap.androidauto.VietMapCarAppScreen
import vn.vietmap.androidauto.VietMapCarAppSession
import vn.vietmap.androidauto.communicate_interface.IAutomotiveCommunicator
import vn.vietmap.androidauto.events.VietmapAutomotiveEvent

class VietmapAutomotiveFlutterPlugin: FlutterPlugin, MethodCallHandler, LifecycleObserver, LifecycleOwner {
    private lateinit var channel : MethodChannel
    private var eventSink: EventSink? = null
    var vietmapCarApp : VietMapCarAppScreen? = null
    private val styleUrl: MutableLiveData<String> = MutableLiveData("")
    private val apiKey: MutableLiveData<String> = MutableLiveData("")
    private val resourcesLiveData: MediatorLiveData<Pair<String, String>> = MediatorLiveData()
    private var isConnectToAndroidAuto = false
    override val lifecycle: Lifecycle
        get() = ProcessLifecycleOwner.get().lifecycle

    private val automotiveCommunicator = object : IAutomotiveCommunicator {
        override fun onStyleLoaded() {
            sendEvent(VietmapAutomotiveEvent.ON_MAP_STYLE_LOADED.nameValue, mapOf())
        }

        override fun onMapRendered() {
            sendEvent(VietmapAutomotiveEvent.ON_MAP_RENDERED.nameValue, mapOf())
        }

        override fun onMapReady() {
            sendEvent(VietmapAutomotiveEvent.ON_MAP_READY.nameValue, mapOf())
        }

        override fun onMapClick(lat: Double, lng: Double) {
            sendEvent(VietmapAutomotiveEvent.ON_MAP_CLICK.nameValue, mapOf("lat" to lat, "lng" to lng))
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

    fun sendEvent(type: String, eventData: Map<String, Any>){
        val data = mutableMapOf<String, Any>()
        data["type"] = type
        data["data"] = eventData

        eventSink?.success(data)
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "vietmap_automotive_flutter")
        channel.setMethodCallHandler(this)

        EventChannel(flutterPluginBinding.binaryMessenger, "vietmap_automotive_flutter/events").setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventSink?) {
                eventSink = events
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
            }
        })

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
            else -> {
              result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        eventSink = null
    }
}
