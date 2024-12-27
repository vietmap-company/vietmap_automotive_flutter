//
//  FCPBarButton.swift
//  Pods
//
//  Created by dev on 18/12/24.
//


import CarPlay

/// A wrapper class for CPBarButton with additional functionality.
@available(iOS 14.0, *)
class FCPBarButton {
    // MARK: Properties

    /// The underlying CPBarButton instance.
    private(set) var _super: CPBarButton?

    /// The image associated with the bar button (optional).
    private var image: UIImage?

    /// The title associated with the bar button (optional).
    private var title: String?

    /// The style of the bar button.
    private var style: CPBarButtonStyle

    /// The enabled state of the bar button.
    private var isEnabled: Bool = true
    
    /// An enum indicating the event of this bar button
    private var onClickEvent: String?

    // MARK: Initializer

    /// Initializes an instance of FCPBarButton with the provided parameters.
    ///
    /// - Parameter obj: A dictionary containing information about the bar button.
    init(obj: [String: Any]) {
        title = obj["title"] as? String

        if let imageName = obj["image"] as? String {
            image = UIImage.dynamicImage(lightImage: imageName)
        }
        
        onClickEvent = obj["onClickEvent"] as? String

        isEnabled = obj["isEnabled"] as? Bool ?? true

        style = (obj["style"] as? String == "none") ? .none : .rounded
    }

    // MARK: Computed Property

    /// Returns the underlying CPBarButton instance configured with the specified properties.
    var get: CPBarButton {
        var barButton: CPBarButton

        if let barTitle = title {
            barButton = CPBarButton(title: barTitle, handler: { _ in
                guard let mapTemplate = VietmapAutomotiveFlutterPlugin.getMapViewTemplate()
                else{
                    return
                }

                switch self.onClickEvent{
                    case FCPChannelTypes.showPanningInterface:
                        mapTemplate.showPanningInterface(animated: true)
                    case FCPChannelTypes.dismissPanningInterface:
                        mapTemplate.dismissPanningInterface(animated: true)
                    case FCPChannelTypes.zoomInMapView:
                        mapTemplate.fcpMapViewController?.zoomInMapView()
                    case FCPChannelTypes.zoomOutMapView:
                        mapTemplate.fcpMapViewController?.zoomOutMapView()
                    case FCPChannelTypes.recenterMapView:
                        mapTemplate.fcpMapViewController?.centerMap()

                    default:
                        debugPrint("Method not implemented")
                }
            })
        } else if let barImage = image {
            barButton = CPBarButton(image: barImage, handler: { _ in
                guard let mapTemplate = VietmapAutomotiveFlutterPlugin.getMapViewTemplate()
                else{
                    return
                }

                switch self.onClickEvent{
                    case FCPChannelTypes.showPanningInterface:
                        mapTemplate.showPanningInterface(animated: true)
                    case FCPChannelTypes.dismissPanningInterface:
                        mapTemplate.dismissPanningInterface(animated: true)
                    case FCPChannelTypes.zoomInMapView:
                        mapTemplate.fcpMapViewController?.zoomInMapView()
                    case FCPChannelTypes.zoomOutMapView:
                        mapTemplate.fcpMapViewController?.zoomOutMapView()
                    case FCPChannelTypes.recenterMapView:
                        mapTemplate.fcpMapViewController?.centerMap()

                    default:
                        debugPrint("Method not implemented")
                }
            })
        } else {
            barButton = CPBarButton(title: "", handler: { _ in })
        }

        barButton.isEnabled = isEnabled
        barButton.buttonStyle = style
        _super = barButton
        return barButton
    }
}
