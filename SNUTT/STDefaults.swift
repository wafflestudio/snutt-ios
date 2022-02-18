//
//  STDefaults.swift
//  SNUTT
//
//  Created by Rajin on 2016. 4. 24..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation
import UIKit
import SwiftyUserDefaults

extension DefaultsKeys {
    static let token = DefaultsKey<String?>("token")
    static let userId = DefaultsKey<String?>("userId")
    static let appVersion = DefaultsKey<String>("appVersion")
    static let autoFit = DefaultsKey<Bool>("autoFit", true)
    static let dayRange = DefaultsKey<[Int]>("dayRange", [0,4])
    static let timeRange = DefaultsKey<[Double]>("timeRange", [0.0, 14.0])
    static let apiKey = DefaultsKey<String>("apiKey")
    static let registeredFCMToken = DefaultsKey<String?>("registeredFCMToken")
    static let shouldShowBadge = DefaultsKey<Bool>("shouldShowBadge", false)
    static let currentTimetable = DefaultsKey<NSDictionary?>("currentTimetable")
    static let shouldDeleteFCMInfos = DefaultsKey<STFCMInfoList?>("shouldDeleteFCMInfos")
    static let colorList = DefaultsKey<STColorList?>("colorList")
    static let snuevWebUrl = DefaultsKey<String>("snuevWebUrl")
}

extension UserDefaults {
    subscript(key: DefaultsKey<NSDictionary?>) -> NSDictionary? {
        get { return unarchive(key) }
        set { archive(key, newValue) }
    }
    
    subscript(key: DefaultsKey<STColorList?>) -> STColorList? {
        get { return unarchive(key) }
        set { archive(key, newValue) }
    }

    subscript(key: DefaultsKey<STFCMInfoList?>) -> STFCMInfoList? {
        get { return unarchive(key) }
        set { archive(key, newValue) }
    }
}

public let STDefaults = UserDefaults(suiteName: Bundle.main.object(forInfoDictionaryKey: "AppGroupID") as! String)!
