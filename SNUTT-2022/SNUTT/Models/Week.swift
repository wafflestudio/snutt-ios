//
//  Week.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/04/09.
//

import Foundation

enum Week : Int, Identifiable {
    case mon,tue,wed,thu,fri,sat,sun

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
