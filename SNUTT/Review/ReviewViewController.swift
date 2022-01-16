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
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadWebViews()
    }
    
    private func loadWebViews() {
        let webConfiguration = WKWebViewConfiguration()
        let wkDataStore = WKWebsiteDataStore.nonPersistent()
        
        let url = "https://apple.com"
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
                
                self.webView = WKWebView(frame: .zero, configuration: webConfiguration)
                self.webView.uiDelegate = self
                self.view = self.webView
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
            .domain: "snutt.wafflestudio.com",
            .path: "/",
            .name: "x-access-apikey",
            .value: apiKey,
        ]) else {
            print("cannot set api cookie")
            return nil
        }
        
        guard let tokenCookie = HTTPCookie(properties: [
            .domain: "snutt.wafflestudio.com",
            .path: "/",
            .name: "x-access-token",
            .value: token,
        ]) else {
            print("cannot set token cookie")
            return nil
        }
        
        return [apiKeyCookie, tokenCookie]
    }
}
