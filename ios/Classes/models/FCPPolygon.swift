//
//  FCPPolygon.swift
//  Pods
//
//  Created by dev on 24/12/24.
//

class FCPPolygon {
    private var points: [FCPMapPointModel]?
    private var holes: [[FCPMapPointModel]]?
    
    init(obj: [String: Any]) {
        if let pointArray = obj["points"] as? [[String: Double]] {
            self.points = pointArray.compactMap { pointDict in
                if let lat = pointDict["lat"], let lng = pointDict["lng"] {
                    return FCPMapPointModel(lat: lat, lng: lng)
                }
                return nil
            }
        }
        
        if let holesArray = obj["holes"] as? [[[String: Double]]] {
            self.holes = holesArray.map { holeArray in
                holeArray.compactMap { pointDict in
                    if let lat = pointDict["lat"], let lng = pointDict["lng"] {
                        return FCPMapPointModel(lat: lat, lng: lng)
                    }
                    return nil
                }
            }
        }
    }
    
    func getPoints() -> [FCPMapPointModel]? {
        return points
    }
    
    func getHoles() -> [[FCPMapPointModel]]? {
        return holes
    }
}
