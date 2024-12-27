//
//  FCPMapButton.swift
//  Pods
//
//  Created by dev on 18/12/24.
//


import CarPlay

@available(iOS 14.0, *)
class FCPMapButton {
    /// The underlying CPMapButton instance.
    private(set) var _super: CPMapButton?

    /// A Boolean value indicating whether the map button is enabled.
    private var isEnabled: Bool = true

    /// A Boolean value indicating whether the map button is hidden.
    private var isHidden: Bool = false
    
    /// An enum indicating the event of this map button
    private var onClickEvent: String?

    /// The image associated with the map button.
    private var image: UIImage?

    /// The focused image associated with the map button.
    private var focusedImage: UIImage?

    /// Initializes an instance of FCPMapButton with the provided parameters.
    ///
    /// - Parameter obj: A dictionary containing information about the map button.
    init(obj: [String: Any]) {
        isEnabled = obj["isEnabled"] as? Bool ?? true
        isHidden = obj["isHidden"] as? Bool ?? false
        
        onClickEvent = obj["onClickEvent"] as? String
        
        
        image = UIImage.dynamicImage(lightImage: obj["image"] as? String,
                                     darkImage: obj["darkImage"] as? String) ?? UIImage(named: FCPIconTypes.getIconType(from: onClickEvent ?? ""), in: Bundle(for: type(of: self)), compatibleWith: nil)!

        if let tintColor = obj["tintColor"] as? Int {
            image = image?.withColor(UIColor(argb: tintColor))
        }

        if let focusedImage = obj["focusedImage"] as? String {
            self.focusedImage = UIImage.dynamicImage(lightImage: focusedImage)
        }
    }

    /// Returns the underlying CPMapButton instance configured with the specified properties.
    var get: CPMapButton {
        let mapButton = CPMapButton { [weak self] _ in
            guard let self = self,
                  let mapTemplate = VietmapAutomotiveFlutterPlugin.getMapViewTemplate()
            else{
                return
            }
            
            switch onClickEvent {
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
        }
        mapButton.isHidden = isHidden
        mapButton.isEnabled = isEnabled
        mapButton.focusedImage = focusedImage
        mapButton.image = image

        _super = mapButton
        return mapButton
    }
}
