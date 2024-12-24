import 'package:uuid/uuid.dart';

import 'bar_button.dart';
import 'dashboard_button.dart';
import 'map_button.dart';

/// A template object that displays map.
class CPMapTemplate {
  /// Unique id of the object.
  final String _elementId = const Uuid().v4();

  /// A title will be shown in the navigation bar.
  String title;

  /// The array of map buttons as [CPMapButton] displayed on the template.
  List<CPMapButton> mapButtons;

  /// An array of dashboard buttons as [CPDashboardButton] displayed on the template.
  List<CPDashboardButton> dashboardButtons;

  /// The array of map buttons as [CPMapButton] displayed on the template while panning.
  List<CPMapButton> mapButtonsWhilePanningMode;

  /// An array of bar buttons to be displayed on the navigation bar while panning.
  List<CPBarButton> barButtonsWhilePanningMode;

  /// An array of bar buttons to be displayed on the leading side of the navigation bar.
  List<CPBarButton> leadingNavigationBarButtons;

  /// An array of bar buttons to be displayed on the trailing side of the navigation bar.
  List<CPBarButton> trailingNavigationBarButtons;

  /// Automatically hides the navigation bar when the map template is visible.
  bool automaticallyHidesNavigationBar;

  /// Hides the buttons in the navigation bar when the map template is visible.
  bool hidesButtonsWithNavigationBar;

  /// Whether the map template is in panning mode.
  bool isPanningInterfaceVisible;

  String styleUrl;

  /// Creates [CPMapTemplate]
  CPMapTemplate({
    this.title = '',
    this.mapButtons = const [],
    this.dashboardButtons = const [],
    this.mapButtonsWhilePanningMode = const [],
    this.barButtonsWhilePanningMode = const [],
    this.leadingNavigationBarButtons = const [],
    this.trailingNavigationBarButtons = const [],
    this.automaticallyHidesNavigationBar = false,
    this.hidesButtonsWithNavigationBar = false,
    this.isPanningInterfaceVisible = false,
    this.styleUrl = '',
  });

  Map<String, dynamic> toJson() => {
        '_elementId': _elementId,
        'title': title,
        'mapButtons': mapButtons.map((e) => e.toJson()).toList(),
        'dashboardButtons': dashboardButtons.map((e) => e.toJson()).toList(),
        'mapButtonsWhilePanningMode':
            mapButtonsWhilePanningMode.map((e) => e.toJson()).toList(),
        'barButtonsWhilePanningMode':
            barButtonsWhilePanningMode.map((e) => e.toJson()).toList(),
        'leadingNavigationBarButtons':
            leadingNavigationBarButtons.map((e) => e.toJson()).toList(),
        'trailingNavigationBarButtons':
            trailingNavigationBarButtons.map((e) => e.toJson()).toList(),
        'automaticallyHidesNavigationBar': automaticallyHidesNavigationBar,
        'hidesButtonsWithNavigationBar': hidesButtonsWithNavigationBar,
        'isPanningInterfaceVisible': isPanningInterfaceVisible,
        'styleUrl': styleUrl,
      };

  String get uniqueId {
    return _elementId;
  }
}
