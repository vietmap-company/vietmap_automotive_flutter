/// The class contains all the events that are used to communicate between the native platform and the plugin.
class Events {
  const Events._();

  static const String getPlatformVersion = 'getPlatformVersion';
  static const String initAutomotive = 'initAutomotive';
  static const String addMarkers = 'addMarkers';
  static const String removeMarker = 'removeMarker';
  static const String removeAllMarkers = 'removeAllMarkers';
  static const String addPolylines = 'addPolylines';
  static const String removePolyline = 'removePolyline';
  static const String removeAllPolylines = 'removeAllPolylines';
  static const String addPolygons = 'addPolygons';
  static const String removePolygon = 'removePolygon';
  static const String removeAllPolygons = 'removeAllPolygons';
  static const String onMapClick = 'onMapClick';
  static const String onStyleLoaded = 'onStyleLoaded';
  static const String onMapRendered = 'onMapRendered';
  static const String onMapReady = 'onMapReady';
  static const String buildRoute = 'buildRoute';
}
