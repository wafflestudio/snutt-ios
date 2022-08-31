//
//  Setting.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/06/25.
//

import Combine
import SwiftUI

class Setting: ObservableObject {
    @Published var accountMenuList: [[AccountSettings]] = []

    var colorList: String? // STColorList
    let snuevWebURL: String = NetworkConfiguration.snuevBaseURL

    var menuSheetSetting: MenuSheetSetting = .init()
}
