//
//  ThemeMarketScene.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SharedUIWebKit
import SwiftUI
import WebKit

public struct ThemeMarketScene: View {
    @State private var viewModel = ThemeMarketViewModel()
    @Environment(\.colorScheme) private var colorScheme
    public init() {}
    public var body: some View {
        SwiftUIWebView(
            url: viewModel.baseURL,
            cookies: viewModel.webCookies,
            onUpdate: { webView in
                webView.setColorScheme(colorScheme: colorScheme)
            }
        )
        .ignoresSafeArea()
        .navigationTitle(ThemesStrings.marketTitle)
        .analyticsScreen(.themeMarket)
    }
}
