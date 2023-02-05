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
        eventSignal = eventSignal ?? .init()
        webView = WKWebView(cookies: NetworkConfiguration.getCookiesFrom(accessToken: accessToken))
        coordinator = coordinator ?? Coordinator(eventSignal: eventSignal!)
        webView?.scrollView.bounces = false
        webView?.backgroundColor = UIColor(STColor.systemBackground)
        webView?.isOpaque = false
        webView?.configuration.userContentController.add(coordinator!, name: MessageHandlerType.snutt.rawValue)
        reload(url: url)
        bindEventSignal()
    }

    func reload(url: URL? = nil) {
        guard let url = url ?? self.url else { return }
        webView?.load(URLRequest(url: url))
        webView?.allowsBackForwardNavigationGestures = url == WebViewType.review.url
        self.url = url
    }
    
    func setColorScheme(_ colorScheme: ColorScheme) {
        webView?.setCookie(name: "theme", value: colorScheme.description)
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
        .store(in: &bag)
            
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
