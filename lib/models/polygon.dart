import 'dart:ui';

import 'package:vietmap_automotive_flutter/utils/color_ext.dart';

import 'latlng.dart';

/// Represents a polygon on the map.
/// A polygon is a closed shape consisting of a set of points, where line segments are drawn between consecutive points.
/// The polygon can be styled with a fill color, stroke color, and alpha value.
/// The polygon can also have holes, which are smaller polygons inside the main polygon.
class Polygon {
  final List<LatLng> points;
  final List<List<LatLng>> holes;
  final Color? fillColor;
  final Color? strokeColor;
  final double? alpha;
  int? id;

  /// Each polygon must have at least three points.
  /// Each hole must have at least three points.
  Polygon({
    this.id,
    required this.points,
    this.holes = const [],
    this.fillColor,
    this.strokeColor,
    this.alpha,
  })  : assert(points.length >= 3, 'Polygon must have at least three points'),
        assert(holes.every((hole) => hole.length >= 3),
            'Hole must have at least three points');

  factory Polygon.fromJson(Map<String, dynamic> json) {
    return Polygon(
      id: json['id'],
      points: (json['points'] as List).map((e) => LatLng.fromJson(e)).toList(),
      holes: (json['holes'] as List)
          .map((e) => (e as List).map((e) => LatLng.fromJson(e)).toList())
          .toList(),
      fillColor: json['fillColor'] != null
          ? Color(int.parse(json['fillColor'].toString()))
          : null,
      strokeColor: json['strokeColor'] != null
          ? Color(int.parse(json['strokeColor'].toString()))
          : null,
      alpha: json['alpha']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'points': points.map((e) => e.toJson()).toList(),
      'holes': holes.map((e) => e.map((e) => e.toJson()).toList()).toList(),
      'fillColor': fillColor?.toHex(),
      'strokeColor': strokeColor?.toHex(),
      'alpha': alpha,
    };
  }
}
