//
//  ReviewWebView.swift
//  SNUTT
//
//  Created by 최유림 on 2022/10/01.
//

import Combine
import SwiftUI
import WebKit

struct ReviewWebView: WebView {
    var url: URL
    let accessToken: String
    @Binding var connectionState: WebViewConnectionState

    /// An event stream used to control `WKWebView` instance outside current view.
    var eventSignal: PassthroughSubject<WebViewEventType, Never>

    var webView: WKWebView

    init(url: URL, accessToken: String, connectionState: Binding<WebViewConnectionState>, eventSignal: PassthroughSubject<WebViewEventType, Never>, initialColorScheme: ColorScheme) {
        self.url = url
        self.accessToken = accessToken
        _connectionState = connectionState
        self.eventSignal = eventSignal
        webView = WKWebView(cookies: ReviewWebView.getCookiesFrom(accessToken: accessToken, colorScheme: initialColorScheme))
    }

    func makeUIView(context: Context) -> WKWebView {
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.bounces = false
        webView.load(urlRequest)
        webView.backgroundColor = UIColor(STColor.systemBackground)
        webView.isOpaque = false
        return webView
    }

    func updateUIView(_: WKWebView, context _: Context) {
        /// Don't refresh webview here. This method is called quite often.
    }

    func makeCoordinator() -> ReviewWebView.Coordinator {
        Coordinator(self)
    }

    private static func getCookie(name: String, value: String) -> HTTPCookie? {
        return HTTPCookie(properties: [
            .domain: NetworkConfiguration.snuevBaseURL.replacingOccurrences(of: "https://", with: ""),
            .path: "/",
            .name: name,
            .value: value,
        ])
    }

    private static func getCookiesFrom(accessToken: String, colorScheme: ColorScheme) -> [HTTPCookie] {
        guard let apiKeyCookie = getCookie(name: "x-access-apikey", value: NetworkConfiguration.apiKey),
              let tokenCookie = getCookie(name: "x-access-token", value: accessToken),
              let themeCookie = getCookie(name: "theme", value: colorScheme.description) else { return [] }

        return [apiKeyCookie, tokenCookie, themeCookie]
    }

    func reloadWebView() {
        webView.load(urlRequest)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: ReviewWebView
        private var bag = Set<AnyCancellable>()

        init(_ parent: ReviewWebView) {
            self.parent = parent
            super.init()

            self.parent.eventSignal.sink { [weak self] event in
                switch event {
                case .reload:
                    self?.parent.reloadWebView()
                case let .colorSchemeChange(to: colorScheme):
                    self?.parent.webView.evaluateJavaScript("changeTheme(\(colorScheme.descriptionWithQuotes))")
                }
            }.store(in: &bag)
        }

        func webView(_: WKWebView, didFailProvisionalNavigation _: WKNavigation!, withError _: Error) {
            if parent.connectionState == .success {
                parent.connectionState = .error
            }
        }

        func webView(_: WKWebView, didFail _: WKNavigation!, withError _: Error) {
            if parent.connectionState == .success {
                parent.connectionState = .error
            }
        }

        func webView(_: WKWebView, didFinish _: WKNavigation!) {
            if parent.connectionState == .error {
                parent.connectionState = .success
            }
        }
    }
}

private extension ColorScheme {
    var description: String {
        switch self {
        case .dark:
            return "dark"
        case .light:
            return "light"
        @unknown default:
            return "light"
        }
    }

    var descriptionWithQuotes: String {
        "'\(description)'"
    }
}
