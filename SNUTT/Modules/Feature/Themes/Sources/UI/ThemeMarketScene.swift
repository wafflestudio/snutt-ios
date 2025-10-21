//
//  ThemeMarketScene.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SharedUIWebKit
import SwiftUI
import WebKit

public struct ThemeMarketScene: View {
    @State private var viewModel = ThemeMarketViewModel()
    public init() {}
    public var body: some View {
        SwiftUIWebView(url: viewModel.baseURL, cookies: viewModel.webCookies)
    }
}
