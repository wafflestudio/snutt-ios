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

    var reloadSignal: PassthroughSubject<Void, Never>
    var webView: WKWebView

    init(url: URL, accessToken: String, connectionState: Binding<WebViewConnectionState>, reloadSignal: PassthroughSubject<Void, Never>) {
        self.url = url
        self.accessToken = accessToken
        _connectionState = connectionState
        self.reloadSignal = reloadSignal
        webView = WKWebView(cookies: ReviewWebView.getCookiesFrom(accessToken: accessToken) ?? [])
    }

    func makeUIView(context: Context) -> WKWebView {
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.bounces = false
        webView.load(urlRequest)
        return webView
    }

    func updateUIView(_: WKWebView, context _: Context) {
        /// Don't refresh webview here. This method is called quite often.
    }

    func makeCoordinator() -> ReviewWebView.Coordinator {
        Coordinator(self)
    }

    private static func getCookiesFrom(accessToken: String) -> [HTTPCookie]? {
        let apiURI = NetworkConfiguration.snuevBaseURL

        guard let apiKeyCookie = HTTPCookie(properties: [
            .domain: apiURI.replacingOccurrences(of: "https://", with: ""),
            .path: "/",
            .name: "x-access-apikey",
            .value: NetworkConfiguration.apiKey,
        ]) else {
            return nil
        }

        guard let tokenCookie = HTTPCookie(properties: [
            .domain: apiURI.replacingOccurrences(of: "https://", with: ""),
            .path: "/",
            .name: "x-access-token",
            .value: accessToken,
        ]) else {
            return nil
        }

        return [apiKeyCookie, tokenCookie]
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

            // bind reload signal: refresh webview when triggered
            self.parent.reloadSignal.sink { [weak self] _ in
                self?.parent.reloadWebView()
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
