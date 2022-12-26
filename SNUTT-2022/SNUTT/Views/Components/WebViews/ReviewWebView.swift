//
//  ReviewWebView.swift
//  SNUTT
//
//  Created by 최유림 on 2022/10/01.
//

import Combine
import SwiftUI
import WebKit

struct ReviewWebView: UIViewRepresentable {
    var preloadWebView: PreloadedWebView
    
    var webView: WKWebView {
        preloadWebView.webView!
    }
    
    var eventSignal: PassthroughSubject<WebViewEventType, Never> {
        preloadWebView.eventSignal!
    }

    init(preloadedWebView: PreloadedWebView) {
        self.preloadWebView = preloadedWebView
    }

    func makeUIView(context: Context) -> WKWebView {
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_: WKWebView, context _: Context) {
        /// Don't refresh webview here. This method is called quite often.
    }

    func makeCoordinator() -> ReviewWebView.Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: ReviewWebView

        init(_ parent: ReviewWebView) {
            self.parent = parent
            super.init()
        }

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
}
