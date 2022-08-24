//
//  Setting.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/06/25.
//

import SwiftUI

class Setting: ObservableObject {
    var colorList: String? // STColorList
    var snuevWebUrl: String?

    var menuSheetSetting: MenuSheetSetting = .init()
}
