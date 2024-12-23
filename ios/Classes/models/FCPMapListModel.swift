//
//  FCPMapListModel.swift
//  Pods
//
//  Created by dev on 18/12/24.
//

import Foundation

class FCPMapListModel {
    private var time: String?
    private var title: String?
    private var address: String?
    private var isCheckIn: Bool?
    private var isCurrentPoint: Bool?
    private var isNextPoint: Bool?
    private var isShowLabelUserConfirm: Bool?
    private var isShowUserDrop: Bool?
    private var isShowUserPick: Bool?
    private var isConfirmUser: Bool?
    private var confirmUser: String?
    private var userPick: String?
    private var userDrop: String?
    private var estimateTime: String?
    private var lateEstimateTimeLate: Bool?
    private var lat: Double?
    private var lng: Double?

    init(obj: [String: Any]) {
        title = obj["title"] as? String
        time = obj["time"] as? String
        isCheckIn = obj["isCheckIn"] as? Bool
        isCurrentPoint = obj["isCurrentPoint"] as? Bool
        isNextPoint = obj["isNextPoint"] as? Bool
        address = obj["address"] as? String
        isShowLabelUserConfirm = obj["isShowLabelUserConfirm"] as? Bool
        confirmUser = obj["confirmUser"] as? String
        isShowUserDrop = obj["isShowUserDrop"] as? Bool
        isShowUserPick = obj["isShowUserPick"] as? Bool
        isConfirmUser = obj["isConfirmUser"] as? Bool
        userPick = obj["userPick"] as? String
        userDrop = obj["userDrop"] as? String
        estimateTime = obj["estimateTime"] as? String
        lateEstimateTimeLate = obj["lateEstimateTimeLate"] as? Bool
        lat = obj["lat"] as? Double
        lng = obj["lng"] as? Double
    }
    
    func getTitle() -> String? {
        return title
    }
    
    func getTime() -> String? {
        return time
    }
    
    func getIsCheckIn() -> Bool {
        return isCheckIn ?? false
    }
    
    func getIsCurrentPoint() -> Bool {
        return isCurrentPoint ?? false
    }
    
    func getIsNextPoint() -> Bool {
        return isNextPoint ?? false
    }
    
    func getAddress() -> String? {
        return address
    }
    
    func getIsShowLabelUserConfirm() -> Bool {
        return isShowLabelUserConfirm ?? false
    }
    
    func getConfirmUser() -> String? {
        return confirmUser
    }
    
    func getIsShowUserDrop() -> Bool {
        return isShowUserDrop ?? false
    }
    
    func getIsShowUserPick() -> Bool {
        return isShowUserPick ?? false
    }
    
    func getIsConfirmUser() -> Bool {
        return isConfirmUser ?? false
    }
    
    func getUserPick() -> String? {
        return userPick
    }
    
    func getUserDrop() -> String? {
        return userDrop
    }
    
    func getEstimateTime() -> String? {
        return estimateTime
    }
    
    func getLateEstimateTime() -> Bool {
        return lateEstimateTimeLate ?? false
    }
    
    func getLat() -> Double? {
        return lat
    }
    
    func getLng() -> Double? {
        return lng
    }
}
