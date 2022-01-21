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
    
    override func viewWillAppear(_ animated: Bool) {
        loadWebViews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func loadWebViews() {
        let webConfiguration = WKWebViewConfiguration()
        let wkDataStore = WKWebsiteDataStore.nonPersistent()
        
        let url = "https://dkm8g3eihm1nu.cloudfront.net/main"
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
                
                self.webView = WKWebView(frame: CGRect(x: 20, y: 47, width: 388, height: 796), configuration: webConfiguration)
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
            .domain: ".dkm8g3eihm1nu.cloudfront.net",
            .path: "/",
            .name: "x-access-apikey",
            .value: apiKey,
        ]) else {
            print("cannot set api cookie")
            return nil
        }
        
        guard let tokenCookie = HTTPCookie(properties: [
            .domain: ".dkm8g3eihm1nu.cloudfront.net",
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
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("욥욥")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("에러 났따 얌마")
        
        DispatchQueue.main.async {
            self.showNavbar()
            self.addErrorView()
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hideNavbar()
        self.view = self.webView
        print("끝났어용")
    }
}
