//
//  ColorModeSettingView.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SwiftUI

struct ColorModeSettingView: View {
    
    var body: some View {
        List(ColorScheme.allCases, id: \.self) { scheme in
            Button {
                
            } label: {
                
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(SettingsStrings.displayColorMode)
    }
}

#Preview {
    ColorModeSettingView()
}
