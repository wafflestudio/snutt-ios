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
            return "\(Int(self)):00"
        } else {
            return "\(Int(self)):30"
        }
    }

    /// `Double`을 분 단위로 정확하게 60진법 수로 환산한다.
    /// ex) 7.3교시 -> 15시 18분 (`7 + 8 == 15`, `0.3 * 60 == 18`)
    func periodStringPrecise() -> String {
        let hour = Int(self) + 8
        let minute: Double = (truncatingRemainder(dividingBy: 1) * 60).rounded() // schoolbook rounding
        return "\(hour):\(Int(minute))"
    }
}

class STPeriod {
    static let periodNum: Int = 24
    static var allValues: [Double] {
        var arr: [Double] = []
        for i in 0 ..< STPeriod.periodNum {
            arr.append(Double(i))
            arr.append(Double(i) + 0.5)
        }
        return arr
    }
}

class STPeriodFormatter: NumberFormatter {
    override func string(from number: NSNumber) -> String? {
        let val = number.doubleValue
        if Int(val * 2.0) % 2 == 0 {
            return "\(Int(val))"
        } else {
            return "\(Int(val)).5"
        }
    }
}
