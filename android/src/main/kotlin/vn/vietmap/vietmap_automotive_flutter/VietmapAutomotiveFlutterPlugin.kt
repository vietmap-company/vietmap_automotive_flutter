package vn.vietmap.vietmap_automotive_flutter

import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import vn.vietmap.androidauto.VietMapCarAppScreen
class VietmapAutomotiveFlutterPlugin: FlutterPlugin, MethodCallHandler {
  private lateinit var channel : MethodChannel
  var vietmapCarApp : VietMapCarAppScreen? = null
  var styleUrl: String = ""
  var apiKey: String = ""
  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {

    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "vietmap_automotive_flutter")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    if(!isConnectedToAndroidAuto(result)) return

    if (call.method == "getPlatformVersion") {
      result.success("Android ${android.os.Build.VERSION.RELEASE}")
    }
    if (call.method == "initAutomotive") {
      val data = call.arguments as Map<*, *>
      apiKey = data["vietMapAPIKey"] as String
      styleUrl = data["styleUrl"] as String
      vietmapCarApp?.init(styleUrl)
      result.success("car_app_initialized")
    }
    else {
      result.notImplemented()
    }
  }

  private fun isConnectedToAndroidAuto(result: Result): Boolean {
    val carApp = VietMapCarAppScreen.getInstance()
    vietmapCarApp = carApp
    if(vietmapCarApp == null){
      result.success("android_auto_disconnected")
    }
    return vietmapCarApp != null
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
