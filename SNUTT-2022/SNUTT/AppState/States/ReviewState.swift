//
//  ReviewState.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/12/26.
//

import WebKit
import Combine
import SwiftUI


class ReviewState {
    let preloadedMain = PreloadedWebView()
    let preloadedDetail = PreloadedWebView()
}


class PreloadedWebView {
    var url: URL? = nil
    var webView: WKWebView? = nil
    var eventSignal: PassthroughSubject<WebViewEventType, Never>? = nil
    private var bag = Set<AnyCancellable>()
    
    func preload(url: URL, accessToken: String) {
        if eventSignal != nil && webView != nil {
            return
        }
        self.url = url
        eventSignal = eventSignal ?? .init()
        webView = webView ?? WKWebView(cookies: NetworkConfiguration.getCookiesFrom(accessToken: accessToken))
        webView?.allowsBackForwardNavigationGestures = true
        webView?.scrollView.bounces = false
        webView?.backgroundColor = UIColor(STColor.systemBackground)
        webView?.isOpaque = false
        webView?.load(URLRequest(url: url))
        bindEventSignal()
    }
    
    func reload(url: URL? = nil) {
        guard let url = url ?? self.url else { return }
        webView?.load(URLRequest(url: url))
        self.url = url
    }
    
    private func bindEventSignal() {
        eventSignal?.sink { [weak self] event in
            switch event {
            case .reload(let url):
                self?.reload(url: url)
            case let .colorSchemeChange(to: colorScheme):
                self?.webView?.setCookie(name: "theme", value: colorScheme.description)
                self?.webView?.evaluateJavaScript("changeTheme('\(colorScheme.description)')")
            default:
                return
            }
        }
        .store(in: &bag)
    }
}

enum WebViewEventType {
    case reload(url: URL)
    case colorSchemeChange(to: ColorScheme)
    case close
    case error
    case success
}
