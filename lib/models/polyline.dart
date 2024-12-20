import 'dart:ui';

import 'package:vietmap_automotive_flutter/utils/color_ext.dart';

import 'latlng.dart';

/// Represents a polyline on the map.
/// A polyline is a list of points, where line segments are drawn between consecutive points.
/// The polyline can be styled with a color, width, and alpha value.
class Polyline {
  final List<LatLng> points;
  final Color? color;
  final double? width;
  final double? alpha;
  int? id;

  /// Each polyline must have at least two points.
  Polyline({
    this.id,
    required this.points,
    this.color,
    this.width,
    this.alpha,
  }) : assert(points.length >= 2, 'Polyline must have at least two points');

  factory Polyline.fromJson(Map<String, dynamic> json) {
    return Polyline(
      id: json['id'],
      points: (json['points'] as List).map((e) => LatLng.fromJson(e)).toList(),
      color: json['color'] != null
          ? Color(int.parse(json['color'].toString()))
          : null,
      width: json['width']?.toDouble(),
      alpha: json['alpha']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'points': points.map((e) => e.toJson()).toList(),
      'color': color?.toHex(),
      'width': width,
      'alpha': alpha,
    };
  }
}
