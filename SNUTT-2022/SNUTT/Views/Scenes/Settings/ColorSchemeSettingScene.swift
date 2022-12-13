//
//  ColorSchemeSettingScene.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/12/14.
//

import SwiftUI

struct ColorSchemeSettingScene: View {
    @Binding var selection: ColorSchemeSelection
    
    var body: some View {
        List {
            ForEach(ColorSchemeSelection.allCases, id: \.self) { scheme in
                Button {
                    withAnimation {
                        selection = scheme
                    }
                } label: {
                    HStack {
                        Text(scheme.rawValue)
                        Spacer()
                        if selection == scheme {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("색상 모드")
    }
}

