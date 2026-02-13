//
//  ReviewsScene.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SharedUIWebKit
import SwiftUI
import WebKit

public struct ReviewsScene: View {
    @State private var viewModel = ReviewsViewModel()
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
    }
}

extension WKWebView {
    func setColorScheme(colorScheme: ColorScheme) {
        guard let domain = url?.host(),
            let themeCookie = HTTPCookie(properties: [
                .name: "theme",
                .value: colorScheme.descriptionForWebView,
                .domain: domain,
                .path: "/",
            ])
        else { return }
        configuration.websiteDataStore.httpCookieStore.setCookie(themeCookie)
        evaluateJavaScript("changeTheme('\(colorScheme.descriptionForWebView)')")
    }
}

extension ColorScheme {
    var descriptionForWebView: String {
        switch self {
        case .light: "light"
        case .dark: "dark"
        default: "light"
        }
    }
}
