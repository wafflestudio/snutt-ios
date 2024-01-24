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
    
    @Published var isBottomSheetOpen = false
    @Published var isNewThemeSheetOpen = false
    @Published var isBasicThemeSheetOpen = false
    @Published var isCustomThemeSheetOpen = false
    
    func findTheme(themeId: String?, themeType: Int?) -> Theme? {
        return themeList.last { theme in
            if let id = themeId {
                return theme.id == id
            } else if let type = themeType {
                return theme.theme?.rawValue == type
            } else {
                return false
            }
        }
    }
}
