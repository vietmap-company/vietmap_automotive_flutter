//
//  FCPHelpers.swift
//  Pods
//
//  Created by dev on 18/12/24.
//

func makeFCPChannelId(event: String?) -> String {
    return "com.oguzhnatly.flutter_carplay" + (event ?? "")
}
