import 'package:flutter/foundation.dart';

/// A Dashboard button object for placement in a CarPlay dashboard.
class CPDashboardButton {
  /// The title displayed on the dashboard button.
  final List<String> titleVariants;

  /// The subtitle displayed on the dashboard button.
  final List<String> subtitleVariants;

  /// The image displayed on the dashboard button.
  final String image;

  /// The dark image displayed on the dashboard button.
  final String? darkImage;

  /// Fired when the user taps a dashboard button.
  final VoidCallback onPressed;

  /// Creates [CPDashboardButton]
  CPDashboardButton({
    required this.onPressed,
    required this.image,
    this.subtitleVariants = const [],
    this.titleVariants = const [],
    this.darkImage,
  });

  Map<String, dynamic> toJson() => {
        'subtitleVariants': subtitleVariants,
        'titleVariants': titleVariants,
        'darkImage': darkImage,
        'image': image,
      };
}
