package vn.vietmap.androidauto.communicate_interface

import io.flutter.plugin.common.MethodCall

interface IAutomotiveCommunicator {
    fun onStyleLoaded()
    fun onMapRendered()
    fun onMapReady()
    fun onMapClick(lat: Double, lng: Double)
}