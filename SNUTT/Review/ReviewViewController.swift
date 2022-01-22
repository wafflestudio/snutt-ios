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
    
    private let apiUri = "https://snutt-ev-web.wafflestudio.com"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadWebViews()
    }
    
    @IBOutlet weak var navbarTitle: UIBarButtonItem! {
        didSet {
            navbarTitle.setTitleTextAttributes([NSAttributedString.Key.font : UIFont(name: "AppleSDGothicNeo-Bold", size: 17)], for: .normal)
        }
    }
 
    private func loadWebViews() {
        let webConfiguration = WKWebViewConfiguration()
        let wkDataStore = WKWebsiteDataStore.nonPersistent()
        
        let url = apiUri
        let myURL = URL(string: url)
        let myRequest = URLRequest(url: myURL!)
        
        guard let cookies = getCookiesFromUserDefaults() else {
            print("cannot get cookies form userdefaults")
            return
        }
        
        let dispatchGroup = DispatchGroup()
        
        if cookies.count > 0 {
            for cookie in cookies{
                dispatchGroup.enter()
                wkDataStore.httpCookieStore.setCookie(cookie){
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
        
        view = errorView
    }
    
    private func showNavbar() {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    private func hideNavbar() {
        self.navigationController?.isNavigationBarHidden = true
    }
}

extension ReviewViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        showNavbar()
        addErrorView()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hideNavbar()
        self.view = self.webView
    }
}

extension ReviewViewController: ErrorViewDelegate {
    func retry(_: ErrorView) {
        loadWebViews()
    }
}
