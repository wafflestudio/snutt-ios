//
//  Setting.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/06/25.
//

import SwiftUI

class Setting: ObservableObject {
    var autoFit: Bool = true
    var dayRange: [Int] = [0, 4]
    var timeRange: [Double] = [0.0, 14.0]
    var shouldShowBadge: Bool = false
    var appVersion: String?
    var apiKey: String?
    var shouldDeleteFCMInfos: String? // STFCMInfoList
    var colorList: String? // STColorList
    var snuevWebUrl: String?
    
    var drawing: TimetableSetting = TimetableSetting()
}
