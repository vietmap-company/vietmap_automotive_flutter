//
//  FCMapPointModel.swift
//  Pods
//
//  Created by dev on 18/12/24.
//

import Foundation

class FCPMapPointModel {
    private var title: String?
    private var subTitle: String?
    private var lat: Double?
    private var lng: Double?

    init(obj: [String: Any]) {
        title = obj["title"] as? String
        subTitle = obj["subTitle"] as? String
        lat = obj["lat"] as? Double
        lng = obj["lng"] as? Double
    }
    
    func getTitle() -> String? {
        return title
    }
    
    func getSubTitle() -> String? {
        return subTitle
    }
    
    func getLat() -> Double? {
        return lat
    }
    
    func getLng() -> Double? {
        return lng
    }
}
