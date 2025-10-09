//
//  SwiftUIWebView.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SwiftUI
import WebKit

public struct SwiftUIWebView: UIViewRepresentable {
    let url: URL
    let configuration: WKWebViewConfiguration
    let allowsBackForwardNavigationGestures: Bool
    var onUpdate: ((WKWebView) -> Void)?

    public init(
        url: URL,
        cookies: [HTTPCookie] = [],
        allowsBackForwardNavigationGestures: Bool = true,
        onUpdate: ((WKWebView) -> Void)? = nil
    ) {
        self.url = url
        self.configuration = {
            let configuration = WKWebViewConfiguration()
            cookies.forEach {
                configuration.websiteDataStore.httpCookieStore.setCookie($0)
            }
            return configuration
        }()
        self.allowsBackForwardNavigationGestures = allowsBackForwardNavigationGestures
        self.onUpdate = onUpdate
    }

    public func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = allowsBackForwardNavigationGestures
        onUpdate?(webView)
        let request = URLRequest(url: url)
        webView.load(request)
        return webView
    }

    public func updateUIView(_ webView: WKWebView, context: Context) {
        onUpdate?(webView)
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    public class Coordinator: NSObject, WKNavigationDelegate {
        public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        }

        public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        }

        public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: any Error) {
        }
    }
}
