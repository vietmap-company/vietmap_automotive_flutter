import 'package:vietmap_automotive_flutter/models/on_click_events.dart';

/// Enum defining different styles of bar buttons in CarPlay.
enum CPBarButtonStyles {
  /// The default style for a bar button.
  none,

  /// The style for a bar button that has rounded corners.
  rounded,
}

/// A button object for placement in a navigation bar.
class CPBarButton {
  /// The title displayed on the bar button.
  final String? title;

  /// The image displayed on the bar button.
  final String? image;

  /// The enabled state of the bar button.
  final bool isEnabled;

  /// The style to use when displaying the button.
  /// Default is [CPBarButtonStyles.rounded]
  final CPBarButtonStyles style;

  /// Fired when the user taps a bar button.
  final OnClickEvents onClickEvent;

  /// Creates [CPBarButton]
  CPBarButton({
    required this.onClickEvent,
    this.style = CPBarButtonStyles.rounded,
    this.isEnabled = true,
    this.image,
    this.title,
  })  : assert(
          image != null || title != null,
          "Properties [image] and [title] both can't be null at the same time.",
        ),
        assert(
          image == null || title == null,
          "Properties [image] and [title] both can't be set at the same time.",
        );

  Map<String, dynamic> toJson() => {
        'isEnabled': isEnabled,
        if (title != null) 'title': title,
        if (image != null) 'image': image,
        'style': style.name,
        'onClickEvent': onClickEvent.name,
      };

  /// Creates a copy of this object but with the given fields replaced with new values.
  CPBarButton copyWith({
    String? title,
    String? image,
    bool? isEnabled,
    CPBarButtonStyles? style,
    OnClickEvents? onClickEvent,
  }) {
    return CPBarButton(
      title: title ?? this.title,
      image: image ?? this.image,
      style: style ?? this.style,
      onClickEvent: onClickEvent ?? this.onClickEvent,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}
