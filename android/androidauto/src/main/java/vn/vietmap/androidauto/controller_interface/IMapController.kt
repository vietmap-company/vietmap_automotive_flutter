package vn.vietmap.androidauto.controller_interface

interface IMapController {
    fun zoomIn()
    fun zoomOut()
    fun recenter()
    fun overviewRoute()
    fun clearRoute() : Boolean
    fun startNavigation()
    fun stopNavigation(): Boolean
}