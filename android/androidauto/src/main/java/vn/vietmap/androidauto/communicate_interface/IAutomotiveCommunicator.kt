package vn.vietmap.androidauto.communicate_interface

import com.mapbox.api.directions.v5.models.DirectionsRoute
import vn.vietmap.androidauto.models.VietMapRouteProgressEvent

interface IAutomotiveCommunicator {
    fun onStyleLoaded()
    fun onMapRendered()
    fun onMapReady()
    fun onMapClick(lat: Double, lng: Double)
    fun onNavigationRunning()
    fun onMapMove()
    fun onMapMoveEnd()
    fun onMarkerClick(markerId: Long)
    fun onNewRouteSelected(routeData: DirectionsRoute)
    fun onMapLongClick(lat: Double, lng: Double, x: Float, y: Float)
    fun onRouteBuildFailed(errorMessage: String)
    fun onRouteBuilding()
    fun onRouteBuilt(routeData: DirectionsRoute)
    fun onProgressChange(progressEvent: VietMapRouteProgressEvent)
    fun onUserOffRoute(lat: Double, lng: Double)
    fun onArrival()
    fun onMilestoneEvent(event: String)
    fun onFasterRouteFound(routeData: DirectionsRoute)
}