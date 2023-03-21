//
//  Week.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/04/09.
//

import Foundation

enum Weekday: Int, Identifiable, Codable, CaseIterable {
    case mon, tue, wed, thu, fri, sat, sun

    var id: RawValue { rawValue }

    /// 0 for Sunday up to 6 for Monday.
    var sundayIndexedId: Int {
        (id + 1) % 7
    }

    public var symbol: String {
        Calendar.current.weekdaySymbols[sundayIndexedId]
    }

    public var shortSymbol: String {
        Calendar.current.shortWeekdaySymbols[sundayIndexedId]
    }

    public var veryShortSymbol: String {
        Calendar.current.veryShortWeekdaySymbols[sundayIndexedId]
    }
}
