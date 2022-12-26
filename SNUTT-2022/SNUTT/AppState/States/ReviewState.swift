//
//  ReviewState.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/12/26.
//

import Combine
import SwiftUI
import WebKit

class ReviewState {
    let preloadedMain = WebViewPreloadManager()
    let preloadedDetail = WebViewPreloadManager()
}

class WebViewPreloadManager {
    var url: URL?
    var webView: WKWebView?
    var eventSignal: PassthroughSubject<WebViewEventType, Never>?
    var coordinator: Coordinator?
    private var bag = Set<AnyCancellable>()

    func preload(url: URL, accessToken: String) {
        if eventSignal != nil && webView != nil {
            return
        }
        self.url = url
        eventSignal = eventSignal ?? .init()
        webView = webView ?? WKWebView(cookies: NetworkConfiguration.getCookiesFrom(accessToken: accessToken))
        coordinator = coordinator ?? Coordinator(eventSignal: eventSignal!)
        webView?.allowsBackForwardNavigationGestures = true
        webView?.scrollView.bounces = false
        webView?.backgroundColor = UIColor(STColor.systemBackground)
        webView?.isOpaque = false
        webView?.configuration.userContentController.add(coordinator!, name: MessageHandlerType.snutt.rawValue)
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
            case let .reload(url):
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

extension WebViewPreloadManager {
    class Coordinator: NSObject, WKScriptMessageHandler {
        let eventSignal: PassthroughSubject<WebViewEventType, Never>

        init(eventSignal: PassthroughSubject<WebViewEventType, Never>) {
            self.eventSignal = eventSignal
        }

        func userContentController(_: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == MessageHandlerType.snutt.rawValue {
                eventSignal.send(.close)
            }
        }
    }
}

private enum MessageHandlerType: String {
    case snutt
    // ...
}

enum WebViewEventType {
    case reload(url: URL)
    case colorSchemeChange(to: ColorScheme)
    case close
    case error
    case success
}
