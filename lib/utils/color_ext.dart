import 'dart:ui';

/// Extension methods for the [Color] class.
extension ColorExt on Color {
  /// Converts the color to a hexadecimal string.
  String toHex() {
    final red = (r * 255).toInt().toRadixString(16).padLeft(2, '0');
    final green = (g * 255).toInt().toRadixString(16).padLeft(2, '0');
    final blue = (b * 255).toInt().toRadixString(16).padLeft(2, '0');
    final alpha = (a * 255).toInt().toRadixString(16).padLeft(2, '0');

    return '$alpha$red$green$blue';
  }
}
