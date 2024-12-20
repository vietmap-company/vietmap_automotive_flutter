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
    
    let _url = Bundle.main.object(forInfoDictionaryKey: "VietMapURL") as! String
    
    var colorUser: Bool = false
    
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
        
        view.addSubview(mapView)
    }
    
    func addPoint(point: FCPMapPointModel) {
        let annotation = MLNPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: point.getLat() ?? 0.0, longitude: point.getLng() ?? 0.0)
        annotation.title = point.getTitle() ?? "marker_job"
        annotation.subtitle = point.getSubTitle() ?? "marker_job_check_in"
        mapView.addAnnotation(annotation)
    }
    
    func addMarker(mapPoints: [FCPMapPointModel]) {
        for point in mapPoints {
            addPoint(point: point)
        }
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
    
    func mapView(_ mapView: MLNMapView, imageFor annotation: MLNAnnotation) -> MLNAnnotationImage? {
        let imageName = (annotation.subtitle ?? "marker_job") ?? "marker_job"
        let title = (annotation.title ?? "") ?? ""
        let identifier = imageName + title
        
        let image = UIImage(named: imageName)!
        let size = CGSize(width: 40, height: 70)
        let imageWithLabel = createImageWithLabel(image: image, text: title, size: size)
        
        let annotationImage = MLNAnnotationImage(image: imageWithLabel, reuseIdentifier: identifier)
        return annotationImage
    }
    
    func createImageWithLabel(image: UIImage, text: String, size: CGSize) -> UIImage {
        let view = UIView(frame: CGRect(origin: .zero, size: size))
        
        let imageView = UIImageView(image: image)
        imageView.frame = CGRect(origin: .zero, size: size)
        view.addSubview(imageView)

        let label = UILabel(frame: CGRect(x: 0, y: 6, width: size.width, height: 20))
        label.backgroundColor = .clear
        label.text = text
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.textColor = .black
        view.addSubview(label)
        
        // Convert UIView to UIImage
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
