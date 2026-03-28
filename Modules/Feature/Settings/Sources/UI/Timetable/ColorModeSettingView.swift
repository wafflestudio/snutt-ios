//
//  ColorModeSettingView.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SwiftUI

struct ColorModeSettingView: View {
    @AppStorage(AppStorageKeys.preferredColorScheme) private var selectedColorScheme: ColorSchemeSelection = .system

    var body: some View {
        List(ColorSchemeSelection.allCases, id: \.self) { colorScheme in
            Button {
                selectedColorScheme = colorScheme
            } label: {
                HStack {
                    Text(colorScheme.localizedString)
                    Spacer()
                    if selectedColorScheme == colorScheme {
                        Image(systemName: "checkmark")
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(SettingsStrings.displayColorMode)
    }
}

public enum ColorSchemeSelection: String, CaseIterable, Codable {
    case system
    case light
    case dark

    public var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }

    var localizedString: String {
        switch self {
        case .system:
            return SettingsStrings.displayColorModeSystem
        case .light:
            return SettingsStrings.displayColorModeLight
        case .dark:
            return SettingsStrings.displayColorModeDark
        }
    }
}

#Preview {
    ColorModeSettingView()
}
