//
//  STPeriod.swift
//  SNUTT
//
//  Created by Rajin on 2016. 2. 21..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation

extension Double {
    func periodString() -> String {
        if Int(self * 2.0) % 2 == 0 {
            return "\(Int(self)+8):00"
        } else {
            return "\(Int(self)+8):30"
        }
    }
}