import 'latlng.dart';

/// Represents a marker on the map.
/// A marker is an icon placed at a particular point on the map's surface.
/// The marker can be styled with an image, title, and snippet.
class Marker {
  /// The image path of the marker, allow only image in [png], [jpeg], [jpg] format
  final String imagePath;
  final LatLng latLng;
  final String? title;
  final String? snippet;
  int? markerId;
  final int? width;
  final int? height;

  /// The marker must have a valid [imagePath] and [latLng].
  /// The [width] and [height] must be both provided or both null.
  Marker({
    required this.imagePath,
    required this.latLng,
    this.title,
    this.snippet,
    this.width,
    this.height,
  })  : assert(width != null || height == null,
            'Width and height must be both provided or both null'),
        assert(height != null || width == null,
            'Width and height must be both provided or both null');
  toJson() {
    return {
      'lat': latLng.lat,
      'lng': latLng.lng,
      'title': title,
      'snippet': snippet,
      'width': width,
      'height': height,
    };
  }
}
