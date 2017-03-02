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
    }
    
    var baseURL : String! = nil
    
}
