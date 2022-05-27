//
//  MenuSheetScene.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/05/27.
//

import SwiftUI

struct MenuSheetScene: View {
    @ObservedObject var testState: TestState
    
    init() {
        testState = AppState.shared.testState
    }
    
    var body: some View {
        MenuSheet(isOpen: $testState.isMenuOpen) {
            Text("helllllo")
        }
    }
}

struct LeftSheetScene_Previews: PreviewProvider {
    static var previews: some View {
        MenuSheetScene()
    }
}
