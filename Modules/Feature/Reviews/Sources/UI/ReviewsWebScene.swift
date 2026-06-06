//
//  ReviewsWebScene.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SharedUIWebKit
import SwiftUI
import WebKit

public struct ReviewsWebScene: View {
    @State private var viewModel = ReviewsWebViewModel()
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    private let evLectureID: Int?
    public init(evLectureID: Int? = nil) {
        self.evLectureID = evLectureID
    }

    public var body: some View {
        SwiftUIWebView(
            url: viewModel.baseURL(for: evLectureID),
            cookies: viewModel.webCookies,
            scriptHandler: .init(
                name: "snutt",
                handler: { _ in
                    Task { @MainActor in
                        dismiss()
                    }
                }
            ),
            onUpdate: { webView in
                webView.setColorScheme(colorScheme: colorScheme)
            }
        )
        .ignoresSafeArea()
    }
}
