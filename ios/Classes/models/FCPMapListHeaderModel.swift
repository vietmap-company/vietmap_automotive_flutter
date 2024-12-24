//
//  FCPMapListHeaderModel.swift
//  Pods
//
//  Created by dev on 18/12/24.
//

import Foundation

class FCPMapListHeaderModel {
    private var nameTrip: String?
    private var title: String?
    private var titleTime: String?
    private var distance: String?
    private var time: String?

    init(obj: [String: Any]) {
        nameTrip = obj["nameTrip"] as? String
        title = obj["title"] as? String
        titleTime = obj["titleTime"] as? String
        distance = obj["distance"] as? String
        time = obj["time"] as? String
    }
    
    func getNameTrip() -> String? {
        return nameTrip
    }
    
    func getTitle() -> String? {
        return title
    }
    
    func getTitleTime() -> String? {
        return titleTime
    }
    
    func getDistance() -> String? {
        return distance
    }
    
    func getTime() -> String? {
        return time
    }
}
