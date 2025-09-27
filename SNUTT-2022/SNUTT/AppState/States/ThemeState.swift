//
//  ThemeState.swift
//  SNUTT
//
//  Created by 이채민 on 2024/01/17.
//

import Combine
import Foundation
import SwiftUI
import WebKit

class ThemeState {
    @Published var themeList: [Theme] = []
    @Published var bottomSheetTarget: Theme?

    @Published var isBottomSheetOpen = false
    @Published var isNewThemeSheetOpen = false
    @Published var isBasicThemeSheetOpen = false
    @Published var isCustomThemeSheetOpen = false
    @Published var isDownloadedThemeSheetOpen = false

    let preloaded = ThemeMarketViewPreloadManager()
}

class ThemeMarketViewPreloadManager {
    var url: URL?
    var webView: WKWebView?
    var eventSignal: PassthroughSubject<ThemeMarketViewEventType, Never>?
    var coordinator: Coordinator?
    private var cancellables = Set<AnyCancellable>()

    func preload(url: URL, accessToken: String) {
        eventSignal = eventSignal ?? .init()
        webView = WKWebView(cookies: NetworkConfiguration.getCookiesFrom(accessToken: accessToken, type: "theme"))
        coordinator = coordinator ?? Coordinator(eventSignal: eventSignal!)
        webView?.scrollView.bounces = true
        webView?.backgroundColor = UIColor(STColor.systemBackground)
        webView?.isOpaque = false
        webView?.configuration.userContentController.add(coordinator!, name: "snutt")
        reload(url: url)
        bindEventSignal()
    }

    func reload(url: URL? = nil) {
        guard let url = url ?? self.url else { return }
        webView?.load(URLRequest(url: url))
        webView?.allowsBackForwardNavigationGestures = url == WebViewType.themeMarket.url
        self.url = url
    }

    func setColorScheme(_ colorScheme: ColorScheme) {
        webView?.setThemeCookie(name: "theme", value: colorScheme.description)
        webView?.evaluateJavaScript("changeTheme('\(colorScheme.description)')")
    }

    private func bindEventSignal() {
        eventSignal?
            .sink { [weak self] event in
                switch event {
                case let .reload(url):
                    self?.reload(url: url)
                default:
                    return
                }
            }
            .store(in: &cancellables)

        /// The `colorScheme` value can be quite unstable, especially during the SwiftUI lifecycle.
        /// To address this, we debounce it for 0.1 seconds.
        eventSignal?
            .debounce(for: .seconds(0.1), scheduler: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case let .colorSchemeChange(to: colorScheme):
                    self?.setColorScheme(colorScheme)
                default:
                    return
                }
            }
            .store(in: &cancellables)
    }
}

extension ThemeMarketViewPreloadManager {
    class Coordinator: NSObject, WKScriptMessageHandler {
        let eventSignal: PassthroughSubject<ThemeMarketViewEventType, Never>

        init(eventSignal: PassthroughSubject<ThemeMarketViewEventType, Never>) {
            self.eventSignal = eventSignal
        }

        func userContentController(_: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "snutt" {
                eventSignal.send(.close)
            }
        }
    }
}

enum ThemeMarketViewEventType {
    case reload(url: URL)
    case colorSchemeChange(to: ColorScheme)
    case close
    case error
    case success
}
