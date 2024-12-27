import '/models/on_click_events.dart';

/// A button object for placement in a map.
class CPMapButton {
  /// The enabled state of the map button.
  final bool isEnabled;

  /// The hidden state of the map button.
  final bool isHidden;

  /// The image displayed on the map button.
  final String? image;

  /// The dark image displayed on the map button.
  final String? darkImage;

  /// The tintColor of the map button.
  final int? tintColor;

  /// The image displayed on the focused map button.
  final String? focusedImage;

  /// The enum indicating the type of the map button.
  final OnClickEvents onClickEvent;

  /// Creates [CPMapButton]
  CPMapButton({
    required this.onClickEvent,
    this.isEnabled = true,
    this.isHidden = false,
    this.focusedImage,
    this.tintColor,
    this.darkImage,
    this.image,
  });

  Map<String, dynamic> toJson() => {
        'focusedImage': focusedImage,
        'isEnabled': isEnabled,
        'darkImage': darkImage,
        'tintColor': tintColor,
        'isHidden': isHidden,
        'image': image,
        'onClickEvent': onClickEvent.serverValue,
      };
}
