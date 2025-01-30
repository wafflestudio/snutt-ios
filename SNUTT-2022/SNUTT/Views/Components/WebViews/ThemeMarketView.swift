//
//  ThemeMarketView.swift
//  SNUTT
//
//  Created by 이채민 on 9/16/24.
//

import Combine
import SwiftUI
import WebKit

struct ThemeMarketView: UIViewRepresentable {
    var preloadWebView: ThemeMarketViewPreloadManager

    var webView: WKWebView {
        preloadWebView.webView!
    }

    var eventSignal: PassthroughSubject<ThemeMarketViewEventType, Never> {
        preloadWebView.eventSignal!
    }

    init(preloadedWebView: ThemeMarketViewPreloadManager) {
        preloadWebView = preloadedWebView
    }

    func makeUIView(context: Context) -> WKWebView {
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_: WKWebView, context _: Context) {
        /// Don't refresh webview here. This method is called quite often.
    }

    func makeCoordinator() -> ThemeMarketView.Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        let parent: ThemeMarketView

        init(_ parent: ThemeMarketView) {
            self.parent = parent
            super.init()
        }
    }
}

extension ThemeMarketView.Coordinator: WKNavigationDelegate {
    func webView(_: WKWebView, didFailProvisionalNavigation _: WKNavigation!, withError _: Error) {
        parent.eventSignal.send(.error)
    }

    func webView(_: WKWebView, didFail _: WKNavigation!, withError _: Error) {
        parent.eventSignal.send(.error)
    }

    func webView(_: WKWebView, didFinish _: WKNavigation!) {
        parent.eventSignal.send(.success)
    }
}
