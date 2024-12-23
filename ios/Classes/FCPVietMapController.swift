//
//  FCPVietMapController.swift
//  Pods
//
//  Created by dev on 18/12/24.
//


import CarPlay
import MapKit
import UIKit
import VietMap

/// A custom CarPlay map view controller.
class FCPVietMapController: UIViewController, CLLocationManagerDelegate {
    
    /// The map view associated with the map view controller.
    var mapView: MLNMapView!
    
    var listViewMap: FCPMapListController?

    var listViewMapHeader: FCPHeaderMapList?
    
    var coordinates: [CLLocationCoordinate2D] = []
    
    var _url: String
    //  = Bundle.main.object(forInfoDictionaryKey: "VietMapURL") as! String
    
    var colorUser: Bool = false
    
    var markerId:Int = 0
    
    var listMarker = [Int : Any]()
    
    init(styleUrl: String, nibName: String, bundle: Bundle?) {
        self._url = styleUrl
        super.init(nibName: nibName, bundle: bundle)
    }
    
    required init?(coder: NSCoder) {
        self._url = ""
        super.init(coder: coder)
    }

    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startMapView()
    }
    
    /// View did appear
    /// - Parameter animated: Animated
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound]) { _,_ in
                DispatchQueue.main.async {
                    CLLocationManager().requestWhenInUseAuthorization()
                }
            }
        }
        
    }
    
    /// View safe area insets
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        
    }
    
    func startMapView() {
        mapView = MLNMapView(frame: view.bounds, styleURL: URL(string: _url))
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.delegate = self
        mapView.userTrackingMode = .follow
        mapView.compassView.compassVisibility = .hidden
        mapView.isRotateEnabled = true
        mapView.isScrollEnabled = true
        mapView.isZoomEnabled = true
        mapView.allowsScrolling = true
        
        view.addSubview(mapView)
    }
    
    func addPoint(point: FCPMapPointModel) -> Int {
        var resizedImage : UIImage? = nil
        if(point.getWidth() != nil && point.getHeight() != nil){
            resizedImage = resizeImage(image: point.getIcon()!, targetSize: CGSize(width: point.getWidth()!, height: point.getWidth()!))
        }
        else{
            resizedImage = point.getIcon()
        }
        
        _ = MLNAnnotationImage(image: resizedImage!, reuseIdentifier: "custom-marker")
        // Create a custom MLNPointAnnotation
        let customMarker = MLNPointAnnotation()
        
        customMarker.coordinate = CLLocationCoordinate2D(latitude: point.getLat() ?? 0.0, longitude: point.getLng() ?? 0.0)
        customMarker.title = point.getTitle() ?? "marker_job"
        customMarker.subtitle = point.getSnippet() ?? "marker_job_check_in"
        
        listMarker.updateValue(customMarker, forKey: markerId)
        
        // Add the annotation to the map
        mapView.addAnnotation(customMarker)
        return markerId
    }
    
    // Function to resize the UIImage
    private func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size

        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        // Determine the scale factor that preserves aspect ratio
        let scaleFactor = min(widthRatio, heightRatio)

        // Calculate the new size that preserves aspect ratio
        let scaledImageSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)

        // Create a new context for the resized image
        UIGraphicsBeginImageContextWithOptions(scaledImageSize, false, 0.0)
        image.draw(in: CGRect(origin: .zero, size: scaledImageSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage ?? image
    }

    
    func addMarker(mapPoints: [FCPMapPointModel]) -> [Int]{
        var listMarkerIds = [Int]()
        for point in mapPoints {
            let subMarkerId = addPoint(point: point)
            listMarkerIds.append(subMarkerId)
            markerId += 1
        }
        return listMarkerIds
    }
    
    func clearAnnotaion() {
        mapView.removeAnnotations(mapView.annotations ?? [])
    }
    
    func addPolyline(coordinates: [CLLocationCoordinate2D], colorUser: Bool = false) {
        self.colorUser = colorUser
        let polyline = MLNPolyline(coordinates: coordinates, count: UInt(coordinates.count))
        mapView.addAnnotation(polyline)
    }
    
    func showSubviews() {
    }
    
    func hideSubviews() {
    }
    
    func zoomInMapView() {
        let currentZoomLevel = mapView.zoomLevel
        if currentZoomLevel > 15 {return}
        let newZoomLevel = currentZoomLevel + 1
        mapView.setZoomLevel(newZoomLevel, animated: true)
    }
    
    func zoomOutMapView() {
        let currentZoomLevel = mapView.zoomLevel
        if currentZoomLevel < 2 {return}
        let newZoomLevel = currentZoomLevel - 1
        mapView.setZoomLevel(newZoomLevel, animated: true)
    }
    
    func centerMap() {
        if let coordinate = mapView.userLocation?.coordinate {
            let camera = MLNMapCamera(lookingAtCenter: coordinate, altitude: 250, pitch: mapView.camera.pitch, heading: mapView.camera.heading)
            mapView.setCamera(camera, animated: true)
        }
    }
    
    func panInDirection(_ direction: CPMapTemplate.PanDirection) {
        let constantChange = 100.0
        let cameraCenter = mapView.camera
        var offset = mapView.convert(cameraCenter.centerCoordinate, toPointTo: mapView)
        
        switch direction {
        case .down:
            offset.y += constantChange
        case .up:
            offset.y -= constantChange
        case .left:
            offset.x -=  constantChange
        case .right:
            offset.x +=  constantChange
        default:
            return
        }
        
        // Update the Map camera position
        let offsetCoordinate = mapView.convert(offset, toCoordinateFrom: mapView)
        let camera = MLNMapCamera(lookingAtCenter: offsetCoordinate, altitude: mapView.camera.altitude, pitch: mapView.camera.pitch, heading: mapView.camera.heading)
        mapView.setCamera(camera, animated: true)
    }
    
    func addMapList(data: [FCPMapListModel], estimatePoint: FCPMapListHeaderModel?) {
        mapView.frame = CGRect(x: 300, y: 0, width: view.frame.width - 300, height: view.frame.height)
        // Add header
        if data.last?.getIsCheckIn() == true {
            listViewMapHeader = FCPHeaderMapList(estimatePoint: estimatePoint, nextPoint: nil)
        } else {
            // find nextPoint
            var nextPoint: FCPMapListModel?
            for itemMapList in data {
                if itemMapList.getIsNextPoint() == true {
                    nextPoint = itemMapList
                    break
                }
            }
            listViewMapHeader = FCPHeaderMapList(estimatePoint: estimatePoint, nextPoint: nextPoint ?? data.first)
        }
        if let listViewMapHeader = listViewMapHeader {
            listViewMapHeader.view.frame = CGRect(x: 0, y: 0, width: 300, height: 70)
            listViewMapHeader.view.backgroundColor = UIColor.white
            listViewMapHeader.viewRespectsSystemMinimumLayoutMargins = false
            addChild(listViewMapHeader)
            view.addSubview(listViewMapHeader.view)
            listViewMapHeader.didMove(toParent: self)
        }
        // Add listview
        let heightBoundsListView = view.frame.height - 70
        listViewMap = FCPMapListController(data: data, heightBounds:heightBoundsListView)
        if let listViewMap = listViewMap {
            listViewMap.view.frame = CGRect(x: 0, y: 70, width: 300, height:heightBoundsListView)
            listViewMap.view.backgroundColor = UIColor.white
            listViewMap.viewRespectsSystemMinimumLayoutMargins = false
            addChild(listViewMap)
            view.addSubview(listViewMap.view)
            listViewMap.didMove(toParent: self)
        }
    }
    
    func scrollUpSubList() {
        DispatchQueue.main.async {
            guard let listViewMap = self.listViewMap else {return}
            let currentOffset = listViewMap.tableView.contentOffset.y
            let newOffset = max(currentOffset - listViewMap.heightCell, 0)
            listViewMap.tableView.setContentOffset(CGPoint(x: 0, y: newOffset), animated: true)
        }
    }
    
    func scrollDownSubList() {
        DispatchQueue.main.async {
            guard let listViewMap = self.listViewMap else {return}
            guard listViewMap.tableView.contentSize.height > listViewMap.tableView.bounds.height else {
                return
            }
            let currentOffset = listViewMap.tableView.contentOffset.y
            let maxOffset = listViewMap.tableView.contentSize.height - listViewMap.tableView.bounds.height
            let newOffset = min(currentOffset + listViewMap.heightCell, maxOffset)
            listViewMap.tableView.setContentOffset(CGPoint(x: 0, y: newOffset), animated: true)
        }
    }
    
    func scrollToIndex(index: Int) {
        DispatchQueue.main.async {
            guard let listViewMap = self.listViewMap else {return}
            let indexPath = IndexPath(row: index, section: 0)
            listViewMap.tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
        }
        
    }
    
    func clearMapList() {
        if let listViewMap = listViewMap, let listViewMapHeader = listViewMapHeader {
            listViewMapHeader.view.removeFromSuperview()
            listViewMap.view.removeFromSuperview()
            mapView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        }
    }
    
    func updateMapList(data: [FCPMapListModel]) {
        if let listViewMap = listViewMap {
            listViewMap.data = data
            listViewMap.tableView.reloadData()
        }
    }
    
    func updateHeaderMapList(data: FCPMapListHeaderModel, nextPoint: FCPMapListModel) {
        if let listViewMapHeader = listViewMapHeader {
            listViewMapHeader.updateValue(data: data, nextPoint: nextPoint)
        }
    }
}


extension FCPVietMapController: MLNMapViewDelegate {
    func mapView(_ mapView: MLNMapView, strokeColorForShapeAnnotation annotation: MLNShape) -> UIColor {
        return colorUser ? .red : .blue
    }
    
    
    func mapView(_ mapView: MLNMapView, didFinishLoading style: MLNStyle) {
    }
}
