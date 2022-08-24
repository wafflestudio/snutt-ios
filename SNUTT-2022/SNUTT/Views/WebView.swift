//
//  WebView.swift
//  SNUTT
//
//  Created by 최유림 on 2022/08/21.
//

import SwiftUI
import WebKit
import Foundation
import Combine

// TODO: 강의평 웹뷰를 위한 non-single webview
protocol WebView: UIViewRepresentable {
    var request: URLRequest { get set }
    func makeUIView(context: Context) -> WKWebView
    func updateUIView(_ uiView: WKWebView, context: Context)
}

struct SingleWebView: WebView {
    var request: URLRequest

    func makeUIView(context _: Context) -> WKWebView {
        print(request.url)
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context _: Context) {
        uiView.load(request)
    }
}

struct ReviewWebView: WebView {
    
    var request: URLRequest

    var viewModel: ReviewViewModel

    func makeUIView(context: Context) -> WKWebView {
        guard let cookies = cookiesFromUserDefaults(),
              !cookies.isEmpty else {
            return WKWebView()
        }

        let webView = WKWebView.attach(cookies: cookies)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.bounces = false
        webView.scrollView.delegate = context.coordinator
        context.coordinator.webView = webView

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context _: Context) {
        print("updateUIView")
        uiView.load(request)
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    func cookiesFromUserDefaults() -> [HTTPCookie]? {
        guard let apiUri = request.url?.absoluteString else {
            return nil
        }
        
        // TODO: uncomment this
//        guard let apiKey = viewModel.apiKey,
//              let token = viewModel.token else {
//            return nil
//        }
        
        let apiKey = "eyJ0eXAi...."
        let token = "74280a4...."

        guard let apiKeyCookie = HTTPCookie(properties: [
            .domain: apiUri.replacingOccurrences(of: "https://", with: ""),
            .path: "/",
            .name: "x-access-apikey",
            .value: apiKey,
        ]) else {
            return nil
        }

        guard let tokenCookie = HTTPCookie(properties: [
            .domain: apiUri.replacingOccurrences(of: "https://", with: ""),
            .path: "/",
            .name: "x-access-token",
            .value: token,
        ]) else {
            return nil
        }

        return [apiKeyCookie, tokenCookie]
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, UIScrollViewDelegate {
        var webView: WKWebView?

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            print("didStartProvisionalNavigation")
        }

        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            print("didCommit");
        }

        // TODO: implement with ErrorView
        func webView(_ webView: WKWebView, didFailProvisionalNavigation: WKNavigation!, withError: Error) {
            print("didFailProvisionalNavigation")
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("didFail")
        }
    }
}

extension WKWebView {
    static func attach(cookies: [HTTPCookie]) -> Self {
        let dataStore = WKWebsiteDataStore.nonPersistent()
        let configuration = WKWebViewConfiguration()
        for cookie in cookies {
            dataStore.httpCookieStore.setCookie(cookie)
        }
        configuration.websiteDataStore = dataStore
        return .init(frame: .zero, configuration: configuration)
    }
}

// TODO: move to appropriate directory
enum SNUTTWebView {
    case developerInfo
    case termsOfService
    case privacyPolicy
    case review

    var baseURL: String {
        switch self {
        case .review:
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
        }
    }

    var url: URL {
        URL(string: baseURL + path)!
    }
}
