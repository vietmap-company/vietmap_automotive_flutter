package vn.vietmap.androidauto.events

enum class VietmapAutomotiveEvent(val nameValue: String) {
    GET_PLATFORM_VERSION("getPlatformVersion"),
    INIT_AUTOMOTIVE("initAutomotive"),
    ADD_MARKERS("addMarkers"),
    REMOVE_MARKER("removeMarker"),
    REMOVE_ALL_MARKERS("removeAllMarkers"),
    ADD_POLYLINES("addPolylines"),
    REMOVE_POLYLINE("removePolyline"),
    REMOVE_ALL_POLYLINES("removeAllPolylines"),
    ADD_POLYGONS("addPolygons"),
    REMOVE_POLYGON("removePolygon"),
    REMOVE_ALL_POLYGONS("removeAllPolygons"),
    ON_MAP_CLICK("onMapClick"),
    ON_MAP_STYLE_LOADED("onStyleLoaded"),
    ON_MAP_RENDERED("onMapRendered"),
    ON_MAP_READY("onMapReady"),
    BUILD_ROUTE("buildRoute"),
}