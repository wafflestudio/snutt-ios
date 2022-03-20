//
//  STConfig.swift
//  SNUTT
//
//  Created by Rajin on 2016. 1. 13..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Alamofire
import Foundation

class STConfig {
    // MARK: Singleton

    fileprivate static var sharedConfig: STConfig?

    static var sharedInstance: STConfig {
        if sharedConfig == nil {
            sharedConfig = STConfig()
        }
        return sharedConfig!
    }

    fileprivate init() {}

    var baseURL: String!
}
