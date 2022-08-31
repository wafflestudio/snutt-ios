//
//  WebView.swift
//  SNUTT
//
//  Created by 최유림 on 2022/08/21.
//

import Combine
import SwiftUI
import WebKit

protocol WebView: UIViewRepresentable {
    var request: URLRequest { get set }
    func makeUIView(context: Context) -> WKWebView
    func updateUIView(_ uiView: WKWebView, context: Context)
}

struct SingleWebView: WebView {
    var request: URLRequest

    func makeUIView(context _: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context _: Context) {
        uiView.load(request)
    }
}

struct ReviewWebView: WebView {
    var request: URLRequest

    let viewModel: ReviewViewModel

    func makeUIView(context: Context) -> WKWebView {
        guard let cookies = cookiesFromUserDefaults(),
              !cookies.isEmpty
        else {
            return WKWebView()
        }

        let webView = WKWebView(cookies: cookies)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.bounces = false
        context.coordinator.webView = webView
        webView.load(request)

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context _: Context) {
        if viewModel.reload {
            uiView.load(request)
            DispatchQueue.main.async {
                viewModel.shouldReloadWebView(false)
            }
        }
    }

    func makeCoordinator() -> ReviewWebView.Coordinator {
        Coordinator(self)
    }

    func cookiesFromUserDefaults() -> [HTTPCookie]? {
        let apiURI = viewModel.snuevWebURL

        // TODO: uncomment this
//        guard let apiKey = viewModel.apiKey,
//              let token = viewModel.token else {
//            return nil
//        }

        let apiKey = "eyJ0eXA..."
        let token = "74280a4..."

        guard let apiKeyCookie = HTTPCookie(properties: [
            .domain: apiURI.replacingOccurrences(of: "https://", with: ""),
            .path: "/",
            .name: "x-access-apikey",
            .value: apiKey,
        ]) else {
            return nil
        }

        guard let tokenCookie = HTTPCookie(properties: [
            .domain: apiURI.replacingOccurrences(of: "https://", with: ""),
            .path: "/",
            .name: "x-access-token",
            .value: token,
        ]) else {
            return nil
        }

        return [apiKeyCookie, tokenCookie]
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: ReviewWebView
        let viewModel: ReviewViewModel
        var webView: WKWebView?

        init(_ parent: ReviewWebView) {
            self.parent = parent
            self.viewModel = parent.viewModel
        }

        func webView(_: WKWebView, didFailProvisionalNavigation _: WKNavigation!, withError _: Error) {
            viewModel.changeConnectionState(to: .error)
        }

        func webView(_: WKWebView, didFinish _: WKNavigation!) {
            viewModel.changeConnectionState(to: .success)
        }
    }
}

extension WKWebView {
    convenience init(cookies: [HTTPCookie]) {
        let dataStore = WKWebsiteDataStore.nonPersistent()
        let configuration = WKWebViewConfiguration()
        for cookie in cookies {
            dataStore.httpCookieStore.setCookie(cookie)
        }
        configuration.websiteDataStore = dataStore
        self.init(frame: .zero, configuration: configuration)
    }
}

// TODO: move to appropriate directory
enum SNUTTWebView {
    case developerInfo
    case termsOfService
    case privacyPolicy
    case review
    case reviewDetail(id: String)

    var baseURL: String {
        switch self {
        case .review, .reviewDetail:
            return NetworkConfiguration.snuevBaseURL
        default:
            return NetworkConfiguration.serverBaseURL
        }
    }

    var path: String {
        switch self {
        case .developerInfo:
            return "/member"
        case .termsOfService:
            return "/terms_of_service"
        case .privacyPolicy:
            return "/privacy_policy"
        case .review:
            return ""
        case .reviewDetail(let id):
            return "/detail/?id=\(id)"
        }
    }

    var url: URL {
        URL(string: baseURL + path)!
    }
}
