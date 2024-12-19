import 'dart:ui';

/// Extension methods for the [Color] class.
extension ColorExt on Color {
  /// Converts the color to a hexadecimal string.
  String toHex() {
    return '#${value.toRadixString(16).padLeft(6, '0')}';
  }
}
