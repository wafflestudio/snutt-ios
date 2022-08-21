//
//  Setting.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/06/25.
//

import SwiftUI
import Combine

class Setting: ObservableObject {
    
    @Published var accountMenuList: [[AccountSettings]] = []
    
    var colorList: String? // STColorList
    var snuevWebUrl: String?

    var menuSheetSetting: MenuSheetSetting = .init()
}
