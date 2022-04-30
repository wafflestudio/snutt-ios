//
//  Week.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/04/09.
//

import Foundation

enum Weekday : Int, Identifiable, Codable {
    case sun, mon,tue,wed,thu,fri,sat
    
    var id: RawValue { rawValue }
    
    public var symbol: String {
        Calendar.current.weekdaySymbols[self.id]
    }
    
    public var shortSymbol: String {
        Calendar.current.shortWeekdaySymbols[self.id]
    }

    public var veryShortSymbol: String {
        Calendar.current.veryShortWeekdaySymbols[self.id]
    }
}
