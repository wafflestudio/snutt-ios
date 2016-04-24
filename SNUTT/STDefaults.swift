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
    static let appVersion = DefaultsKey<String?>("appVersion")
}

public let STDefaults = Defaults