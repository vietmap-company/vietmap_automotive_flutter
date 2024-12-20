//
//  FCPMapTemplate.swift
//  Pods
//
//  Created by dev on 18/12/24.
//


import CarPlay
//import heresdk
import MapKit

/// A custom CarPlay map template with additional customization options.
@available(iOS 14.0, *)
class FCPMapTemplate: NSObject {
    // MARK: Properties

    /// The super template object representing the CarPlay map template.
    private(set) var _super: CPMapTemplate?

    /// The view controller associated with the map template.
    private(set) var viewController: UIViewController?

    /// The unique identifier for the map template.
    private(set) var elementId: String

    /// The title displayed on the map template.
    private var title: String?

    /// The map buttons to be displayed on the map template.
    private var mapButtons: [FCPMapButton]

    /// The leading navigation bar buttons for the map template.
    private var leadingNavigationBarButtons: [FCPBarButton]

    /// The trailing navigation bar buttons for the map template.
    private var trailingNavigationBarButtons: [FCPBarButton]

    /// The dashboard buttons to be displayed on the CarPlay dashboard.
    private(set) var dashboardButtons: [FCPDashboardButton]

    /// A boolean value indicating whether the navigation bar is automatically hidden.
    private var automaticallyHidesNavigationBar: Bool = false

    /// A boolean value indicating whether buttons are hidden with the navigation bar.
    private var hidesButtonsWithNavigationBar: Bool = false

    /// A boolean value indicating whether the map is in panning mode.
    var isPanningInterfaceVisible: Bool = false

    /// Navigation session used to manage the upcomingManeuvers and  arrival estimation details
    var navigationSession: CPNavigationSession?

    /// Get the `FCPVietMapController` associated with the map template.
    var fcpMapViewController: FCPVietMapController? {
        return viewController as? FCPVietMapController
    }

    // MARK: Initializer

    /// Initializes a new instance of `FCPMapTemplate` with the specified configuration.
    ///
    /// - Parameter obj: A dictionary containing the configuration parameters for the map template.
    init(obj: [String: Any]) {
        guard let elementId = obj["_elementId"] as? String else {
            fatalError("[FCPMapTemplate] Missing required property: _elementId.")
        }

        self.elementId = elementId
        title = obj["title"] as? String
        automaticallyHidesNavigationBar = obj["automaticallyHidesNavigationBar"] as? Bool ?? false
        hidesButtonsWithNavigationBar = obj["hidesButtonsWithNavigationBar"] as? Bool ?? false
        isPanningInterfaceVisible = obj["isPanningInterfaceVisible"] as? Bool ?? false

        mapButtons = (obj["mapButtons"] as? [[String: Any]] ?? []).map {
            FCPMapButton(obj: $0)
        }

        dashboardButtons = (obj["dashboardButtons"] as? [[String: Any]] ?? []).map {
            FCPDashboardButton(obj: $0)
        }

        leadingNavigationBarButtons = (obj["leadingNavigationBarButtons"] as? [[String: Any]] ?? []).map {
            FCPBarButton(obj: $0)
        }

        trailingNavigationBarButtons = (obj["trailingNavigationBarButtons"] as? [[String: Any]] ?? []).map {
            FCPBarButton(obj: $0)
        }

        /// Initialize the view controller.
        viewController = FCPVietMapController(nibName: "FCPVietMapController", bundle: Bundle(for: FCPVietMapController.self))
    }

    // MARK: Getter

    /// Gets the CarPlay map template object based on the configured parameters.
    var get: CPMapTemplate {
        let mapTemplate = CPMapTemplate()
        mapTemplate.setFCPObject(self)

        var mButtons: [CPMapButton] = []
        for button in mapButtons {
            mButtons.append(button.get)
        }

        var lBButtons: [CPBarButton] = []
        for button in leadingNavigationBarButtons {
            lBButtons.append(button.get)
        }

        var tBButtons: [CPBarButton] = []
        for button in trailingNavigationBarButtons {
            tBButtons.append(button.get)
        }

        mapTemplate.mapButtons = mButtons
        mapTemplate.leadingNavigationBarButtons = lBButtons
        mapTemplate.trailingNavigationBarButtons = tBButtons
        
        mapTemplate.automaticallyHidesNavigationBar = automaticallyHidesNavigationBar
        mapTemplate.hidesButtonsWithNavigationBar = hidesButtonsWithNavigationBar
        mapTemplate.mapDelegate = self
        
        _super = mapTemplate
        return mapTemplate
    }

    /// Updates the properties of the map template.
    ///
    /// - Parameters:
    ///   - title: The new title text.
    ///   - automaticallyHidesNavigationBar: A boolean value indicating whether the navigation bar is automatically hidden.
    ///   - hidesButtonsWithNavigationBar: A boolean value indicating whether buttons are hidden with the navigation bar.
    ///   - mapButtons: The new array of map buttons.
    ///   - leadingNavigationBarButtons: The new array of leading navigation bar buttons.
    ///   - trailingNavigationBarButtons: The new array of trailing navigation bar buttons.
    public func update(title: String?, automaticallyHidesNavigationBar: Bool?, hidesButtonsWithNavigationBar: Bool?, isPanningInterfaceVisible: Bool?, mapButtons: [FCPMapButton]?, leadingNavigationBarButtons: [FCPBarButton]?, trailingNavigationBarButtons: [FCPBarButton]?) {
        if let _title = title {
            self.title = _title
        }

        if let _hidesButtonsWithNavigationBar = hidesButtonsWithNavigationBar {
            self.hidesButtonsWithNavigationBar = _hidesButtonsWithNavigationBar
            _super?.hidesButtonsWithNavigationBar = _hidesButtonsWithNavigationBar
        }

        if let _automaticallyHidesNavigationBar = automaticallyHidesNavigationBar {
            self.automaticallyHidesNavigationBar = _automaticallyHidesNavigationBar
            _super?.automaticallyHidesNavigationBar = _automaticallyHidesNavigationBar
        }

        if let _isPanningInterfaceVisible = isPanningInterfaceVisible {
            self.isPanningInterfaceVisible = _isPanningInterfaceVisible
        }

        if let _mapButtons = mapButtons {
            self.mapButtons = _mapButtons
            _super?.mapButtons = _mapButtons.map { $0.get }
        }

        if let _leadingNavigationBarButtons = leadingNavigationBarButtons {
            self.leadingNavigationBarButtons = _leadingNavigationBarButtons
            _super?.leadingNavigationBarButtons = _leadingNavigationBarButtons.map {
                $0.get
            }
        }

        if let _trailingNavigationBarButtons = trailingNavigationBarButtons {
            self.trailingNavigationBarButtons = _trailingNavigationBarButtons
            _super?.trailingNavigationBarButtons = _trailingNavigationBarButtons.map {
                $0.get
            }
        }
        _super?.setFCPObject(self)
    }
}

// MARK: - Trip

@available(iOS 14.0, *)
extension FCPMapTemplate {
    /// Show trip previews
    /// - Parameters:
    ///   - trips: The array of trips to show
    ///   - selectedTrip: The selected trip
    ///   - textConfiguration: The text configuration
//    func showTripPreviews(trips: [FCPTrip], selectedTrip: FCPTrip?, textConfiguration: FCPTripPreviewTextConfiguration?) {
//        let cpTrips = trips.map { $0.get }
//        _super?.showTripPreviews(cpTrips, selectedTrip: selectedTrip?.get,
//                                 textConfiguration: textConfiguration?.get)
//    }
//
//    /// Hide trip previews.
//    func hideTripPreviews() {
//        _super?.hideTripPreviews()
//    }

    /// Starts the navigation
    /// - Parameter trip: The trip to start navigation
    func startNavigation(trip: CPTrip) {
        if navigationSession != nil {
            navigationSession?.finishTrip()
            navigationSession = nil
        }

//        hideTripPreviews()
        navigationSession = _super?.startNavigationSession(for: trip)

        if #available(iOS 15.4, *) {
            navigationSession?.pauseTrip(for: .loading, description: "", turnCardColor: .systemGreen)
        } else {
            navigationSession?.pauseTrip(for: .loading, description: "")
        }

//        fcpMapViewController?.startNavigation(trip: trip)
    }

    /// Stops the navigation
    func stopNavigation() {
        navigationSession?.finishTrip()
        navigationSession = nil

//        fcpMapViewController?.stopNavigation()
    }

    /// Pans the camera in the specified direction
    /// - Parameter animated: A boolean value indicating whether the transition should be animated
    func showPanningInterface(animated: Bool) {
        _super?.showPanningInterface(animated: animated)
    }

    /// Dismisses the panning interface
    /// - Parameter animated: A boolean value indicating whether the transition should be animated
    func dismissPanningInterface(animated: Bool) {
        _super?.dismissPanningInterface(animated: animated)
    }
}

// MARK: - CPMapTemplateDelegate

@available(iOS 14.0, *)
extension FCPMapTemplate: CPMapTemplateDelegate {
    /// Called when the map template has started a trip
    /// - Parameter
    ///   - mapTemplate: The map template
    ///   - trip: The trip that was started
    ///   - routeChoice: The route choice
    func mapTemplate(_: CPMapTemplate, startedTrip trip: CPTrip, using _: CPRouteChoice) {
        let originCoordinate = trip.origin.placemark.coordinate
        let destinationCoordinate = trip.destination.placemark.coordinate

        DispatchQueue.main.async {
            FCPStreamHandlerPlugin.sendEvent(type: FCPChannelTypes.onNavigationStartedFromCarplay, data: ["sourceLatitude": originCoordinate.latitude, "sourceLongitude": originCoordinate.longitude, "destinationLatitude": destinationCoordinate.latitude, "destinationLongitude": destinationCoordinate.longitude])
        }
    }

    /// Called when the panning interface is shown
    /// - Parameter mapTemplate: The map template
    func mapTemplateDidShowPanningInterface(_: CPMapTemplate) {
//        fcpMapViewController?.hideSubviews()
//        fcpMapViewController?.mapController?.navigationHelper.stopCameraTracking()
    }

    /// Called when the panning interface is dismissed
    /// - Parameter mapTemplate: The map template
    func mapTemplateDidDismissPanningInterface(_: CPMapTemplate) {
//        fcpMapViewController?.showSubviews()
//        fcpMapViewController?.mapController?.navigationHelper.startCameraTracking()
    }

    /// Called when the map template is panning
    /// - Parameters:
    ///   - maptemplate: The map template
    ///   - direction: The direction of the panning
    func mapTemplate(_: CPMapTemplate, panWith direction: CPMapTemplate.PanDirection) {
        fcpMapViewController?.panInDirection(direction)
    }
}

@available(iOS 14.0, *)
extension FCPMapTemplate: FCPRootTemplate {}

@available(iOS 14.0, *)
extension FCPMapTemplate: FCPTemplate {}
