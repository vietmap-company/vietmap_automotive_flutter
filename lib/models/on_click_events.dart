enum OnClickEvents {
  showPanningInterface('showPanningInterface'),
  dismissPanningInterface('dismissPanningInterface'),
  zoomInMapView("zoomInMapView"),
  zoomOutMapView("zoomOutMapView"),
  recenterMapView("recenterMapView");

  final String serverValue;

  const OnClickEvents(this.serverValue);
}
