//
//  ReviewViewController.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/01/08.
//  Copyright © 2022 WaffleStudio. All rights reserved.
//

import UIKit
import WebKit

class ReviewViewController: UIViewController, WKUIDelegate {
    var webView: WKWebView!

    private let apiUri = STDefaults[.snuevWebUrl]

    private var idForLoadDetailView: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        hideNavbar()

        if let id = idForLoadDetailView {
            loadWebViews(withApiUrl: apiUri + "/detail/?id=\(id)")
        } else {
            loadWebViews(withApiUrl: apiUri)
        }
    }

    @IBOutlet weak var navbarTitle: UIBarButtonItem! {
        didSet {
            navbarTitle.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "AppleSDGothicNeo-Bold", size: 17)], for: .normal)
        }
    }

    private func loadWebViews(withApiUrl: String) {
        let webConfiguration = WKWebViewConfiguration()
        let wkDataStore = WKWebsiteDataStore.nonPersistent()

        let url = withApiUrl
        let myURL = URL(string: url)
        let myRequest = URLRequest(url: myURL!)

        guard let cookies = getCookiesFromUserDefaults() else {
            print("cannot get cookies form userdefaults")
            return
        }

        let dispatchGroup = DispatchGroup()

        if cookies.count > 0 {
            for cookie in cookies {
                dispatchGroup.enter()
                wkDataStore.httpCookieStore.setCookie(cookie) {
                    dispatchGroup.leave()
                }
            }

            dispatchGroup.notify(queue: DispatchQueue.main) {
                webConfiguration.websiteDataStore = wkDataStore

                self.webView = WKWebView(frame: CGRect.zero, configuration: webConfiguration)
                self.webView.uiDelegate = self
                self.webView.navigationDelegate = self
                self.webView.load(myRequest)
            }
        }
    }

    private func getCookiesFromUserDefaults() -> [HTTPCookie]? {
        let apiKey = STDefaults[.apiKey]

        guard let token = STDefaults[.token] else {
            print("cannot find token")
            return nil
        }

        guard let apiKeyCookie = HTTPCookie(properties: [
            .domain: apiUri.replacingOccurrences(of: "https://", with: ""),
            .path: "/",
            .name: "x-access-apikey",
            .value: apiKey,
        ]) else {
            print("cannot set api cookie")
            return nil
        }

        guard let tokenCookie = HTTPCookie(properties: [
            .domain: apiUri.replacingOccurrences(of: "https://", with: ""),
            .path: "/",
            .name: "x-access-token",
            .value: token,
        ]) else {
            print("cannot set token cookie")
            return nil
        }

        return [apiKeyCookie, tokenCookie]
    }

    private func addErrorView() {
        let identifier = String(describing: ErrorView.self)
        let nibs = Bundle.main.loadNibNamed(identifier, owner: self, options: nil)

        guard let errorView = nibs?.first as? ErrorView else {
            print("cannot load error view")
            return
        }

        errorView.delegate = self

        view.addSubview(errorView)
        errorView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorView.topAnchor.constraint(equalTo: view.topAnchor),
            errorView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func showNavbar() {
        navigationController?.isNavigationBarHidden = false
    }

    private func hideNavbar() {
        navigationController?.isNavigationBarHidden = true
    }

    private func addWebview() {
        view.addSubview(webView)

        webView.scrollView.bounces = false
        webView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}

extension ReviewViewController: WKNavigationDelegate {
    func webView(_: WKWebView, didFailProvisionalNavigation _: WKNavigation!, withError _: Error) {
        showNavbar()
        addErrorView()
    }

    func webView(_: WKWebView, didFinish _: WKNavigation!) {
        hideNavbar()
        addWebview()
    }
}

extension ReviewViewController: ErrorViewDelegate {
    func retry(_: ErrorView) {
        if let id = idForLoadDetailView {
            loadWebViews(withApiUrl: apiUri + "/detail/\(id)")
        } else {
            loadWebViews(withApiUrl: apiUri)
        }
    }
}

extension ReviewViewController {
    func loadDetailView(withId id: String) {
        let url = apiUri + "/detail/?id=\(id)"
        let myURL = URL(string: url)
        let myRequest = URLRequest(url: myURL!)

        webView.load(myRequest)
    }

    func setIdForLoadDetailView(with id: String) {
        idForLoadDetailView = id
    }

    func loadMainView() {
        let url = apiUri
        let myURL = URL(string: url)
        let myRequest = URLRequest(url: myURL!)

        webView.load(myRequest)
    }
}
