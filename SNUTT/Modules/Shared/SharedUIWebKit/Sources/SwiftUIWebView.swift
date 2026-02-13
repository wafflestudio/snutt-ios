//
//  SwiftUIWebView.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SwiftUI
import WebKit

public struct SwiftUIWebView: UIViewRepresentable {
    let url: URL
    let cookies: [HTTPCookie]
    let allowsBackForwardNavigationGestures: Bool
    var onUpdate: ((WKWebView) -> Void)?
    let scriptHandler: ScriptMessageHandler?

    public init(
        url: URL,
        cookies: [HTTPCookie] = [],
        allowsBackForwardNavigationGestures: Bool = true,
        scriptHandler: ScriptMessageHandler? = nil,
        onUpdate: ((WKWebView) -> Void)? = nil,
    ) {
        self.url = url
        self.cookies = cookies
        self.allowsBackForwardNavigationGestures = allowsBackForwardNavigationGestures
        self.scriptHandler = scriptHandler
        self.onUpdate = onUpdate
    }

    public func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.isOpaque = false
        webView.backgroundColor = .systemBackground
        webView.scrollView.backgroundColor = .systemBackground

        // Set cookies
        cookies.forEach { cookie in
            configuration.websiteDataStore.httpCookieStore.setCookie(cookie)
        }

        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = allowsBackForwardNavigationGestures
        if let scriptHandler {
            webView.configuration.userContentController.add(context.coordinator, name: scriptHandler.name)
        }
        onUpdate?(webView)
        let request = URLRequest(url: url)
        webView.load(request)
        return webView
    }

    public func updateUIView(_ webView: WKWebView, context: Context) {
        onUpdate?(webView)
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(scriptHandler: scriptHandler)
    }

    public class Coordinator: NSObject, WKNavigationDelegate {
        private let scriptHandler: ScriptMessageHandler?
        init(scriptHandler: ScriptMessageHandler?) {
            self.scriptHandler = scriptHandler
        }

        public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        }

        public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        }

        public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: any Error) {
        }
    }
}

public struct ScriptMessageHandler: Sendable {
    public let name: String
    public let handler: @Sendable (String) -> Void

    public init(name: String, handler: @Sendable @escaping (String) -> Void) {
        self.name = name
        self.handler = handler
    }
}

extension SwiftUIWebView.Coordinator: WKScriptMessageHandler {
    public func userContentController(_: WKUserContentController, didReceive message: WKScriptMessage) {
        assert(message.name == scriptHandler?.name)
        if let body = message.body as? String {
            scriptHandler?.handler(body)
        }
    }
}
