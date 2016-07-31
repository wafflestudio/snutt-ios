//
//  STDefaults.swift
//  SNUTT
//
//  Created by Rajin on 2016. 4. 24..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

extension DefaultsKeys {
    static let token = DefaultsKey<String?>("token")
    static let appVersion = DefaultsKey<String>("appVersion")
    static let autoFit = SwiftyUserDefaults.DefaultsKey<Bool>("autoFit", true)
    static let dayRange = DefaultsKey<[Int]>("dayRange", [0,4])
    static let timeRange = DefaultsKey<[Double]>("timeRange", [0.0, 14.0]) //FIXME: default value
}

public let STDefaults = Defaults
