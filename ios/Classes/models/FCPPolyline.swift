//
//  FCPPolyline.swift
//  Pods
//
//  Created by dev on 24/12/24.
//
import Foundation
import CoreLocation
import CoreGraphics

class FCPPolyline{
    private var points: [FCPMapPointModel]?
    private var color: UIColor?
    private var width: Double?
    private var alpha: Double?
    
    init(obj: [String: Any]) {
        let points = obj["points"] as? [[String: Double]]
        let colorHex = obj["color"] as? String
        let width = obj["width"] as? Double
        let alpha = obj["alpha"] as? Double
        
        if points != nil {
            self.points = points?.compactMap{
                FCPMapPointModel(obj: $0)
            }
        }
        else{
            self.points = nil
        }
        if(colorHex != nil){
            self.color = UIColor(hexCode: colorHex!)
        }
        self.width = width
        self.alpha = alpha
    }
    
    func getPoints() -> [FCPMapPointModel]? {
        return points
    }
    
    func getColor() -> UIColor? {
        return color
    }
    
    func getWidth() -> Double? {
        return width
    }
    
    func getAlpha() -> Double? {
        return alpha
    }
}
