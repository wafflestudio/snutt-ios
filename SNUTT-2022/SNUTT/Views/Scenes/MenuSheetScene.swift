//
//  MenuSheetScene.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/05/27.
//

import SwiftUI

struct MenuSheetScene: View {
    @ObservedObject var menuSheetState: MenuSheetStates
    
    init() {
        menuSheetState = AppState.of.menuSheet
    }
    
    var body: some View {
        MenuSheet(isOpen: $menuSheetState.isMenuOpen) {
            Text("helllllo")
        }
    }
}

struct LeftSheetScene_Previews: PreviewProvider {
    static var previews: some View {
        MenuSheetScene()
    }
}
