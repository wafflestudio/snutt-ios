//
//  STConfig.swift
//  SNUTT
//
//  Created by Rajin on 2016. 1. 13..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation
import Alamofire

class STConfig {
    // MARK: Singleton
    
    private static var sharedConfig : STConfig? = nil
    
    static var sharedInstance : STConfig {
        get {
            if sharedConfig == nil {
                sharedConfig = STConfig()
            }
            return sharedConfig!
        }
    }
    private init() {
        baseURL = "http://walnut.wafflestudio.com:3000/api"
        loadData()
    }
    
    var token : String? {
        didSet {
            saveData()
        }
    }
    let baseURL : String
    
    func saveData() {
        if let token = self.token {
            NSUserDefaults.standardUserDefaults().setObject(token, forKey: "token")
        } else {
            NSUserDefaults.standardUserDefaults().removeObjectForKey("token")
        }
        
    }
    
    func loadData() {
        if let token = NSUserDefaults.standardUserDefaults().objectForKey("token") as? String {
            self.token = token
        } else {
            self.token = nil
        }
    }
}