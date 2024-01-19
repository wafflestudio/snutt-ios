//
//  ThemeState.swift
//  SNUTT
//
//  Created by 이채민 on 2024/01/17.
//

import Foundation
import SwiftUI

class ThemeState {
    @Published var themeList: [Theme] = []
    @Published var bottomSheetTarget: Theme?
    @Published var detailSheetTarget: Theme?
    
    @Published var isBottomSheetOpen = false
    @Published var isNewThemeSheetOpen = false
    @Published var isBasicThemeSheetOpen = false
    @Published var isCustomThemeSheetOpen = false
}
