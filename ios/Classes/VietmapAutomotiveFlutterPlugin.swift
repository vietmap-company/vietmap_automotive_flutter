import Flutter
import UIKit

import CarPlay

@available(iOS 14.0, *)
public class VietmapAutomotiveFlutterPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "vietmap_automotive_flutter", binaryMessenger: registrar.messenger())
    let instance = VietmapAutomotiveFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
      
      self.registrar = registrar

      streamHandler = FCPStreamHandlerPlugin(registrar: registrar)
  }
    
    /// The stream handler for CarPlay communication.
    private static var streamHandler: FCPStreamHandlerPlugin?

    /// The Flutter plugin registrar.
    private(set) static var registrar: FlutterPluginRegistrar?

    /// The root template to be displayed on CarPlay.
    private static var _fcpRootTemplate: FCPRootTemplate?

    /// The root view controller for CarPlay.
    private static var _rootViewController: UIViewController?

    /// The root template for CarPlay.
    private static var _rootTemplate: CPTemplate?

    /// Indicates whether animations should be used.
    public static var animated: Bool = false

    /// The present template object for CarPlay modals.
    private var fcpPresentTemplate: FCPPresentTemplate?

    /// The root template to be displayed on CarPlay.
    public static var rootTemplate: CPTemplate? {
        get {
            return _rootTemplate
        }
        set(template) {
            _rootTemplate = template
        }
    }

    /// The root template to be displayed on CarPlay.
    static var fcpRootTemplate: FCPRootTemplate? {
        get {
            return _fcpRootTemplate
        }
        set(template) {
            _fcpRootTemplate = template
        }
    }

    /// The root view controller for CarPlay.
    public static var rootViewController: UIViewController? {
        get {
            return _rootViewController
        }
        set(viewController) {
            _rootViewController = viewController
        }
    }

    /// The CPTemplate history for CarPlay.
    public static var cpTemplateHistory: [CPTemplate] {
        return FCPTemplateManager.shared.carplayInterfaceController?.templates ?? []
    }


    /// Handles a Flutter method call and provides a result callback.
    ///
    /// This method is responsible for processing Flutter method calls and producing a result
    /// through the provided `FlutterResult` callback. It is typically used as part of a Flutter
    /// plugin implementation.
    ///
    /// - Parameters:
    ///   - call: The `FlutterMethodCall` representing the invoked method.
    ///   - result: The callback to provide the result of the method call to Flutter.
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        MemoryLogger.shared.appendEvent("FlutterMethodCall received : \(call.method)")

        switch call.method {
        case FCPChannelTypes.initAutomotive:
            guard let args = call.arguments as? [String: Any],
                    let rootTemplate = createRootTemplate(from: args, runtimeType: "FCPMapTemplate")
            else{
                result(false)
                return
            }
            setRootTemplate(rootTemplate, args: args, result: result)
        
        case FCPChannelTypes.getPlatformVersion:
            result("iOS " + UIDevice.current.systemVersion)
            
        case FCPChannelTypes.setRootTemplate:
            guard let args = call.arguments as? [String: Any],
                  let runtimeType = args["runtimeType"] as? String,
                  let rootTemplate = createRootTemplate(from: args, runtimeType: runtimeType)
            else {
                result(false)
                return
            }

            setRootTemplate(rootTemplate, args: args, result: result)
        case FCPChannelTypes.forceUpdateRootTemplate:
            FlutterCarplaySceneDelegate.forceUpdateRootTemplate(completion: { completed, _ in
                result(completed)
            })
        case FCPChannelTypes.updateInformationTemplate:
            guard let args = call.arguments as? [String: Any],
                  let elementId = args["_elementId"] as? String
            else {
                result(false)
                return
            }

            updateInformationTemplate(elementId: elementId, args: args)
            result(true)
        case FCPChannelTypes.updateMapTemplate:
            guard let args = call.arguments as? [String: Any],
                  let elementId = args["_elementId"] as? String
            else {
                result(false)
                return
            }

            updateMapTemplate(elementId: elementId, args: args)
            result(true)

        case FCPChannelTypes.popTemplate:
            guard let args = call.arguments as? [String: Any],
                  let count = args["count"] as? Int,
                  let animated = args["animated"] as? Bool
            else {
                result(false)
                return
            }
            for _ in 1 ... count {
                FlutterCarplaySceneDelegate.pop(animated: animated, completion: { _, _ in
                })
            }
            result(true)
        case FCPChannelTypes.closePresent:
            guard let animated = call.arguments as? Bool else {
                result(false)
                return
            }
            FlutterCarplaySceneDelegate.closePresent(animated: animated, completion: { completed, _ in
                result(completed)
            })
            fcpPresentTemplate = nil
        case FCPChannelTypes.pushTemplate:
            guard let args = call.arguments as? [String: Any] else {
                result(false)
                return
            }
            pushTemplate(args: args, result: result)
        case FCPChannelTypes.popToRootTemplate:
            guard let animated = call.arguments as? Bool else {
                result(false)
                return
            }
            FlutterCarplaySceneDelegate.popToRootTemplate(animated: animated, completion: { completed, _ in
                result(completed)
            })
            fcpPresentTemplate = nil

        case FCPChannelTypes.getConfig:
            let config = [
                "maximumItemCount": CPListTemplate.maximumItemCount,
                "maximumSectionCount": CPListTemplate.maximumSectionCount,
            ]
            result(config)

        case FCPChannelTypes.showBanner:
            guard let args = call.arguments as? [String: Any],
                  let elementId = args["_elementId"] as? String,
                  let _ = args["message"] as? String,
                  let _ = args["color"] as? Int
            else {
                result(false)
                return
            }

            // Find the map template based on the provided element ID
            VietmapAutomotiveFlutterPlugin.findMapTemplate(elementId: elementId) { mapTemplate in
//                mapTemplate.fcpMapViewController?.showBanner(message: message, color: color)
                return result(true)
            }
            result(false)
        case FCPChannelTypes.hideBanner:
            guard let args = call.arguments as? [String: Any],
                  let elementId = args["_elementId"] as? String
            else {
                result(false)
                return
            }

            // Find the map template based on the provided element ID
            VietmapAutomotiveFlutterPlugin.findMapTemplate(elementId: elementId) { mapTemplate in
                return result(true)
            }
            result(false)
        case FCPChannelTypes.showToast:
            guard let args = call.arguments as? [String: Any],
                  let elementId = args["_elementId"] as? String,
                  let _ = args["message"] as? String,
                  let _ = args["duration"] as? Double
            else {
                result(false)
                return
            }

            // Find the map template based on the provided element ID
            VietmapAutomotiveFlutterPlugin.findMapTemplate(elementId: elementId) { mapTemplate in
                return result(true)
            }
            result(false)
        case FCPChannelTypes.showOverlay:
            guard let args = call.arguments as? [String: Any],
                  let elementId = args["_elementId"] as? String

            else {
                result(false)
                return
            }

            _ = args["primaryTitle"] as? String
            _ = args["secondaryTitle"] as? String
            _ = args["subtitle"] as? String

            // Find the map template based on the provided element ID
            VietmapAutomotiveFlutterPlugin.findMapTemplate(elementId: elementId) { mapTemplate in
//                mapTemplate.fcpMapViewController?.showOverlay(primaryTitle: primaryTitle, secondaryTitle: secondaryTitle, subtitle: subtitle)
                return result(true)
            }
            result(false)
        case FCPChannelTypes.hideOverlay:
            guard let args = call.arguments as? [String: Any],
                  let elementId = args["_elementId"] as? String
            else {
                result(false)
                return
            }

            // Find the map template based on the provided element ID
            VietmapAutomotiveFlutterPlugin.findMapTemplate(elementId: elementId) { mapTemplate in
                return result(true)
            }
            result(false)

        case FCPChannelTypes.showPanningInterface:
            guard let args = call.arguments as? [String: Any],
                  let elementId = args["_elementId"] as? String,
                  let animated = args["animated"] as? Bool
            else {
                result(false)
                return
            }

            // Find the map template based on the provided element ID
            VietmapAutomotiveFlutterPlugin.findMapTemplate(elementId: elementId) { mapTemplate in
                mapTemplate.showPanningInterface(animated: animated)
                return result(true)
            }
            result(false)

        case FCPChannelTypes.dismissPanningInterface:
            guard let args = call.arguments as? [String: Any],
                  let elementId = args["_elementId"] as? String,
                  let animated = args["animated"] as? Bool
            else {
                result(false)
                return
            }

            // Find the map template based on the provided element ID
            VietmapAutomotiveFlutterPlugin.findMapTemplate(elementId: elementId) { mapTemplate in
                mapTemplate.dismissPanningInterface(animated: animated)
                return result(true)
            }
            result(false)

        case FCPChannelTypes.zoomInMapView:
            guard let args = call.arguments as? [String: Any],
                  let elementId = args["_elementId"] as? String
            else {
                result(false)
                return
            }

            // Find the map template based on the provided element ID
            VietmapAutomotiveFlutterPlugin.findMapTemplate(elementId: elementId) { mapTemplate in
                mapTemplate.fcpMapViewController?.zoomInMapView()
                return result(true)
            }

            result(false)
        case FCPChannelTypes.zoomOutMapView:
            guard let args = call.arguments as? [String: Any],
                  let elementId = args["_elementId"] as? String
            else {
                result(false)
                return
            }

            // Find the map template based on the provided element ID
            VietmapAutomotiveFlutterPlugin.findMapTemplate(elementId: elementId) { mapTemplate in
                mapTemplate.fcpMapViewController?.zoomOutMapView()
                return result(true)
            }

            result(false)

        case FCPChannelTypes.startNavigation:
            guard let args = call.arguments as? [String: Any],
                  let elementId = args["_elementId"] as? String,
                  let trip = args["trip"] as? [String: Any]
            else {
                result(false)
                return
            }

            // Find the map template based on the provided element ID
            VietmapAutomotiveFlutterPlugin.findMapTemplate(elementId: elementId) { mapTemplate in
                let cpTrip = FCPTrip(obj: trip).get
                mapTemplate.startNavigation(trip: cpTrip)
                return result(true)
            }
            result(false)

        case FCPChannelTypes.stopNavigation:
            guard let args = call.arguments as? [String: Any],
                  let elementId = args["_elementId"] as? String
            else {
                result(false)
                return
            }

            // Find the map template based on the provided element ID
            VietmapAutomotiveFlutterPlugin.findMapTemplate(elementId: elementId) { mapTemplate in
                mapTemplate.stopNavigation()
                return result(true)
            }
            result(false)

        case FCPChannelTypes.onManeuverActionTextRequestComplete:
            guard let args = call.arguments as? [String: Any],
                  let text = args["actionText"] as? String,
                  let isPrimary = args["isPrimary"] as? Bool
            else {
                result(false)
                return
            }


            result(true)

        case FCPChannelTypes.recenterMapView:
            guard let args = call.arguments as? [String: Any],
                  let elementId = args["_elementId"] as? String
            else {
                result(false)
                return
            }
            // Find the map template based on the provided element ID
            VietmapAutomotiveFlutterPlugin.findMapTemplate(elementId: elementId) { mapTemplate in
                mapTemplate.fcpMapViewController?.centerMap()
                return result(true)
            }
            
            result(false)

        case FCPChannelTypes.updateMapCoordinates:
            guard call.arguments is [String: Any]
            else {
                result(false)
                return
            }

            result(false)
        
        case FCPChannelTypes.clearListSubMap:
            guard let args = call.arguments as? [String: Any],
                  let elementId = args["_elementId"] as? String
            else {
                result(false)
                return
            }
            // Find the map template based on the provided element ID
            VietmapAutomotiveFlutterPlugin.findMapTemplate(elementId: elementId) { mapTemplate in
                mapTemplate.fcpMapViewController?.clearMapList()
                return result(true)
            }

            result(false)
            
        case FCPChannelTypes.scrollUpListSubMap:
            guard let args = call.arguments as? [String: Any],
                  let elementId = args["_elementId"] as? String
            else {
                result(false)
                return
            }
            // Find the map template based on the provided element ID
            VietmapAutomotiveFlutterPlugin.findMapTemplate(elementId: elementId) { mapTemplate in
                mapTemplate.fcpMapViewController?.scrollUpSubList()
                return result(true)
            }

            result(false)

        case FCPChannelTypes.scrollDownListSubMap:
            guard let args = call.arguments as? [String: Any],
                  let elementId = args["_elementId"] as? String
            else {
                result(false)
                return
            }
            // Find the map template based on the provided element ID
            VietmapAutomotiveFlutterPlugin.findMapTemplate(elementId: elementId) { mapTemplate in
                mapTemplate.fcpMapViewController?.scrollDownSubList()
                return result(true)
            }

            result(false)
            
        case FCPChannelTypes.scrollToIndexListSubMap:
            guard let args = call.arguments as? [String: Any],
                  let elementId = args["_elementId"] as? String,
                  let index = args["index"] as? Int
            else {
                result(false)
                return
            }
            // Find the map template based on the provided element ID
            VietmapAutomotiveFlutterPlugin.findMapTemplate(elementId: elementId) { mapTemplate in
                mapTemplate.fcpMapViewController?.scrollToIndex(index: index)
                return result(true)
            }

            result(false)

        case FCPChannelTypes.addMarkers:
            guard let dataArray = call.arguments as? [[String: Any]]
            else {
                result([])
                return
            }
            let mapPoints: [FCPMapPointModel] = dataArray.map { jsonData in
                FCPMapPointModel(obj: jsonData)
            }
            
            // Find the map template
            let mapTemplate = VietmapAutomotiveFlutterPlugin.getMapViewTemplate()
            if let mapTemplate {
                let markerIdsList = mapTemplate.fcpMapViewController?.addMarker(mapPoints: mapPoints)
                return result(markerIdsList)
            }

            result([])
        
        case FCPChannelTypes.removeMarker:
            guard let args = call.arguments as? [String: Any],
                  let markerIdsList = args["markerIds"] as? [Int]
            else{
                result(false)
                return
            }
            
            let mapTemplate = VietmapAutomotiveFlutterPlugin.getMapViewTemplate()
            if let mapTemplate {
                let resp = mapTemplate.fcpMapViewController?.removeMarkers(markerIdsList: markerIdsList)
                result(resp)
            }
            
            result(false)
        
        case FCPChannelTypes.removeAllMarkers:
            let mapTemplate = VietmapAutomotiveFlutterPlugin.getMapViewTemplate()
            if let mapTemplate {
                let resp = mapTemplate.fcpMapViewController?.removeAllMarkers()
                result(resp)
            }
            
            result(false)

        case FCPChannelTypes.addPolylines:
            guard let args = call.arguments as? [String: Any],
                  let polylinesArgs = args["polylines"] as? [[String: Any]]
            else {
                result([])
                return
            }
            
            let polylineModels: [FCPPolyline] = polylinesArgs.map{
                jsonData in
                FCPPolyline(obj: jsonData)
            }
            
            if let mapTemplate = VietmapAutomotiveFlutterPlugin.getMapViewTemplate() {
                let resp = mapTemplate.fcpMapViewController?.addPolylines(polylines: polylineModels)
                result(resp)
            }
        
            result([])
        
        case FCPChannelTypes.removePolyline:
            guard let args = call.arguments as? [String: Any],
                  let polylineIds = args["polylineIds"] as? [Int]
            else {
                result(false)
                return
            }
            
            if let mapTemplate = VietmapAutomotiveFlutterPlugin.getMapViewTemplate(){
                let resp = mapTemplate.fcpMapViewController?.removePolylines(polylineIdsList: polylineIds)
                result(resp)
            }
            
            result(false)
        
        case FCPChannelTypes.removeAllPolylines:
            if let mapTemplate = VietmapAutomotiveFlutterPlugin.getMapViewTemplate() {
                let resp = mapTemplate.fcpMapViewController?.removeAllMarkers()
                result(resp)
            }
            
            result(false)

        case FCPChannelTypes.clearAnnotationToMap:
            guard let args = call.arguments as? [String: Any],
                  let elementId = args["_elementId"] as? String
            else {
                result(false)
                return
            }
            // Find the map template based on the provided element ID
            VietmapAutomotiveFlutterPlugin.findMapTemplate(elementId: elementId) { mapTemplate in
                mapTemplate.fcpMapViewController?.clearAnnotaion()
                return result(true)
            }

            result(false)

        default:
            result(false)
        }
    }

    /// Creates an event channel for communication with Flutter.
    ///
    /// - Parameter event: The name of the event channel.
    /// - Returns: A Flutter event channel for communication with Flutter.
    static func createEventChannel(event: String?) -> FlutterEventChannel {
        let eventChannel = FlutterEventChannel(name: makeFCPChannelId(event: event),
                                               binaryMessenger: VietmapAutomotiveFlutterPlugin.registrar!.messenger())
        return eventChannel
    }
}

// MARK: - Helper
@available(iOS 14.0, *)
extension VietmapAutomotiveFlutterPlugin {
    /// Creates an FCPRootTemplate based on the provided arguments and runtime type.
    /// - Parameters:
    ///   - args: A dictionary containing the root template arguments.
    ///   - runtimeType: A string representing the runtime type of the root template.
    /// - Returns: An instance of FCPRootTemplate if successful, otherwise nil.
    private func createRootTemplate(from args: [String: Any], runtimeType: String) -> FCPRootTemplate? {
        // Ensure that the rootTemplateArgs key exists in the args dictionary
        guard let rootTemplateArgs = args["rootTemplate"] as? [String: Any] else {
            return nil
        }

        // Create an FCPRootTemplate based on the provided runtime type
        switch runtimeType {
//        case String(describing: FCPTabBarTemplate.self):
//            return FCPTabBarTemplate(obj: rootTemplateArgs)
//
//        case String(describing: FCPGridTemplate.self):
//            return FCPGridTemplate(obj: rootTemplateArgs)
//
//        case String(describing: FCPInformationTemplate.self):
//            return FCPInformationTemplate(obj: rootTemplateArgs)
//
//        case String(describing: FCPPointOfInterestTemplate.self):
//            return FCPPointOfInterestTemplate(obj: rootTemplateArgs)

        case String(describing: FCPMapTemplate.self):
            let mapTemplate = FCPMapTemplate(obj: rootTemplateArgs)
            return mapTemplate

//        case String(describing: FCPListTemplate.self):
//            // For FCPListTemplate, set the template type to DEFAULT
//            let templateType = FCPListTemplateTypes.DEFAULT
//            return FCPListTemplate(obj: rootTemplateArgs, templateType: templateType)

        default:
            return nil
        }
    }

    /// Sets the root template for CarPlay based on the provided FCPRootTemplate.
    /// - Parameters:
    ///   - rootTemplate: The FCPRootTemplate to be set as the root template.
    ///   - args: Additional arguments for setting the root template.
    ///   - result: A FlutterResult callback to communicate the success or failure of the operation.
    private func setRootTemplate(_ rootTemplate: FCPRootTemplate, args: [String: Any], result: FlutterResult) {
        var cpRootTemplate: CPTemplate

        // Check the type of the root template and extract the corresponding FCPRootTemplate
        switch rootTemplate {

        case let mapTemplate as FCPMapTemplate:
            // For FCPMapTemplate, set the rootViewController and update the CarPlay window's rootViewController
            cpRootTemplate = mapTemplate.get

            VietmapAutomotiveFlutterPlugin.rootViewController = mapTemplate.viewController

            if FCPTemplateManager.shared.isDashboardSceneActive {
                FCPTemplateManager.shared.dashboardWindow?.rootViewController = mapTemplate.viewController
            } else {
                FCPTemplateManager.shared.carWindow?.rootViewController = mapTemplate.viewController
            }

        default:
            // If the root template type is not recognized, return false
            result(false)
            return
        }

        // If an FCPRootTemplate is successfully extracted, set it as the root template
        VietmapAutomotiveFlutterPlugin.rootTemplate = cpRootTemplate
        FCPTemplateManager.shared.carplayInterfaceController?.setRootTemplate(cpRootTemplate, animated: VietmapAutomotiveFlutterPlugin.animated, completion: nil)
        VietmapAutomotiveFlutterPlugin.fcpRootTemplate = rootTemplate
        VietmapAutomotiveFlutterPlugin.onCarplayConnectionChange(status: FCPTemplateManager.shared.fcpConnectionStatus)
        let animated = args["animated"] as? Bool ?? false
        VietmapAutomotiveFlutterPlugin.animated = animated
        result(true)
    }

    /// Pushes a new CarPlay template onto the navigation stack.
    ///
    /// - Parameters:
    ///   - args: Arguments containing information about the template to be pushed.
    ///   - result: The FlutterResult to return the completion status of the operation.
    private func pushTemplate(args: [String: Any], result: @escaping FlutterResult) {
        // Extract necessary information from the provided arguments
        guard let runtimeType = args["runtimeType"] as? String,
              let templateArgs = args["template"] as? [String: Any],
              let animated = args["animated"] as? Bool
        else {
            result(false)
            return
        }

        var pushTemplate: CPTemplate

        // Create the appropriate FCPTemplate based on the runtime type
        switch runtimeType {
        case String(describing: FCPMapTemplate.self):
            let mapTemplate: FCPMapTemplate = FCPMapTemplate(obj: templateArgs)
            pushTemplate = mapTemplate.get
            // For FCPMapTemplate, set the rootViewController and update the CarPlay window's rootViewController
            VietmapAutomotiveFlutterPlugin.rootViewController = mapTemplate.viewController

            if FCPTemplateManager.shared.isDashboardSceneActive {
                FCPTemplateManager.shared.dashboardWindow?.rootViewController = mapTemplate.viewController
            } else {
                FCPTemplateManager.shared.carWindow?.rootViewController = mapTemplate.viewController
            }
        default:
            result(false)
            return
        }

        // Push the template onto the navigation stack
        FlutterCarplaySceneDelegate.push(template: pushTemplate, animated: animated) { completed, _ in
            result(completed)
        }
    }

    /// Notifies Flutter about changes in CarPlay connection status.
    ///
    /// - Parameter status: The CarPlay connection status.
    static func onCarplayConnectionChange(status: String) {
        FCPStreamHandlerPlugin.sendEvent(type: FCPChannelTypes.onCarplayConnectionChange,
                                         data: ["status": status])
    }

    /// Sends an event to Flutter with the updated speech recognition transcript.
    ///
    /// - Parameter transcript: The updated speech recognition transcript.
    static func sendSpeechRecognitionTranscriptChangeEvent(transcript: String) {
        FCPStreamHandlerPlugin.sendEvent(type: FCPChannelTypes.onVoiceControlTranscriptChanged,
                                         data: ["transcript": transcript])
    }
}

// MARK: - Update FCPObjects
@available(iOS 14.0, *)
extension VietmapAutomotiveFlutterPlugin {
    /// Updates a CarPlay information template identified by its element ID with new data.
    ///
    /// - Parameters:
    ///   - elementId: The unique identifier of the information template to be updated.
    ///   - args: Additional arguments for updating the information template.
    private func updateInformationTemplate(elementId: String, args: [String: Any]) {
    }

    /// Updates a CarPlay map template identified by its element ID with new data.
    ///
    /// - Parameters:
    ///   - elementId: The unique identifier of the list template to be updated.
    ///   - args: Additional arguments for updating the list template.
    private func updateMapTemplate(elementId: String, args: [String: Any]) {
        // Find the map template based on the provided element ID
        VietmapAutomotiveFlutterPlugin.findMapTemplate(elementId: elementId) { mapTemplate in
            // Extract and handle the data for updating the map template
            let title = args["title"] as? String
            let hidesButtonsWithNavigationBar = args["hidesButtonsWithNavigationBar"] as? Bool
            let automaticallyHidesNavigationBar = args["automaticallyHidesNavigationBar"] as? Bool
            let isPanningInterfaceVisible = args["isPanningInterfaceVisible"] as? Bool

            // Map dictionary representations to FCPMapButton instances for map buttons
            let mapButtons = (args["mapButtons"] as? [[String: Any]])?.map {
                FCPMapButton(obj: $0)
            }

            // Map dictionary representations to FCPBarButton instances for navigation bar buttons
            let leadingNavigationBarButtons = (args["leadingNavigationBarButtons"] as? [[String: Any]])?.map {
                FCPBarButton(obj: $0)
            }

            let trailingNavigationBarButtons = (args["trailingNavigationBarButtons"] as? [[String: Any]])?.map {
                FCPBarButton(obj: $0)
            }

            mapTemplate.update(
                title: title,
                automaticallyHidesNavigationBar: automaticallyHidesNavigationBar,
                hidesButtonsWithNavigationBar: hidesButtonsWithNavigationBar,
                isPanningInterfaceVisible: isPanningInterfaceVisible,
                mapButtons: mapButtons,
                leadingNavigationBarButtons: leadingNavigationBarButtons,
                trailingNavigationBarButtons: trailingNavigationBarButtons
            )
        }
    }
}

// MARK: - Find FCPObjects
@available(iOS 14.0, *)
private extension VietmapAutomotiveFlutterPlugin {
    /// Finds a CarPlay map template by element ID and performs an action when found.
    ///
    /// - Parameters:
    ///   - elementId: The element ID of the map template.
    ///   - actionWhenFound: The action to perform when the map template is found.
    static func findMapTemplate(elementId: String, actionWhenFound: (_ template: FCPMapTemplate) -> Void) {
        // Get the array of FCPMapTemplate instances.
        let templates = getFCPMapTemplatesFromHistory()

        // Iterate through the templates to find the one with the matching element ID.
        for template in templates where template.elementId == elementId {
            // Perform the specified action when the template is found.
            actionWhenFound(template)
            break
        }
    }
    
    /// Gets Current Map view template
    static func getMapViewTemplate() -> FCPMapTemplate? {
        let templates = getFCPMapTemplatesFromHistory()
        
    
        if !templates.isEmpty {
            return templates.first
        }
        
        return nil
    }
    
    /// Finds a CarPlay map template from history.
    ///
    /// - Returns:
    ///   - [FCPMapTemplate]: Array of FCPMapTemplate instances
    static func getFCPMapTemplatesFromHistory() -> [FCPMapTemplate] {
        // Initialize an array to store FCPMapTemplate instances.
        var templates: [FCPMapTemplate] = []

        // Filter the template history to include only FCPMapTemplate instances.
        for template in VietmapAutomotiveFlutterPlugin.cpTemplateHistory {
            if let fcpTemplate = (((template as? CPMapTemplate)?.userInfo as? [String: Any])?["FCPObject"] as? FCPMapTemplate) {
                templates.append(fcpTemplate)
            }
            // else if let fcpTemplate = (((template as? CPTabBarTemplate)?.userInfo as? [String: Any])?["FCPObject"] as? FCPTabBarTemplate) {
            //     templates.append(contentsOf: fcpTemplate.getTemplates())
            // }
        }

        return templates
    }

}
