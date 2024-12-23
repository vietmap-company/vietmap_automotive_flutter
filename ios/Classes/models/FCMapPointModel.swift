//
//  FCMapPointModel.swift
//  Pods
//
//  Created by dev on 18/12/24.
//

import Foundation

class FCPMapPointModel {
    private var title: String?
    private var snippet: String?
    private var lat: Double?
    private var lng: Double?
    private var width: Int?
    private var height: Int?
    private var icon: UIImage?

    init(obj: [String: Any]) {
        title = obj["title"] as? String
        snippet = obj["subTitle"] as? String
        lat = obj["lat"] as? Double
        lng = obj["lng"] as? Double
        width = obj["width"] as? Int
        height = obj["height"] as? Int
        let base64EncodedStr = (obj["base64Encoded"]) as? String
        let imageData = Data(base64Encoded: base64EncodedStr!)!
        icon = UIImage(data: imageData)
    }
    
    func getTitle() -> String? {
        return title
    }
    
    func getSnippet() -> String? {
        return snippet
    }
    
    func getLat() -> Double? {
        return lat
    }
    
    func getLng() -> Double? {
        return lng
    }
    
    func getWidth() -> Int? {
        return width
    }
    
    func getHeight() -> Int? {
        return height
    }
    
    func getIcon() -> UIImage? {
        return icon
    }
}
