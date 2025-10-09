//
//  ThemeHorizontalScrollView.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SwiftUI
import ThemesInterface

struct ThemeHorizontalScrollView: View {
    var themes: [Theme]
    var onTapCreateButton: (() -> Void)?
    var onTapTheme: (Theme) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                if let onTapCreateButton {
                    Button {
                        onTapCreateButton()
                    } label: {
                        VStack {
                            ThemesAsset.themeNew.swiftUIImage
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                            Text("새 테마")
                                .font(.system(size: 14))
                                .padding(.top, 5)
                        }
                    }
                }

                ForEach(themes, id: \.id) { theme in
                    ThemeButton(theme: theme, action: { onTapTheme(theme) })
                        .id(theme.id)
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 8)
            .animation(.defaultSpring, value: themes)
        }
    }
}

private struct ThemeButton: View {
    let theme: Theme
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack {
                ThemeIcon(theme: theme)
                    .frame(width: 80, height: 80)
                Text(theme.name)
                    .font(.system(size: 14))
                    .lineLimit(1)
                    .padding(.top, 5)
                    .frame(width: 80)
            }
        }
    }
}
