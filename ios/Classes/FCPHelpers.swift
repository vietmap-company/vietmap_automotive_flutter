//
//  FCPHelpers.swift
//  Pods
//
//  Created by dev on 18/12/24.
//

func makeFCPChannelId(event: String?) -> String {
    return "vietmap_automotive_flutter" + (event ?? "")
}
