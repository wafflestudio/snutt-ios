//
//  Date+Weekday.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Foundation

public enum Weekday: Int, Sendable, Identifiable, Codable, CaseIterable {
    case mon, tue, wed, thu, fri, sat, sun
    public var id: RawValue { rawValue }

    /// 0 for Sunday up to 6 for Monday.
    private var sundayIndexedId: Int {
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

extension Date {
    public func daysFrom(_ date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
}

extension Date {
    public var weekday: Weekday {
        let weekdayIndex = (Calendar.current.component(.weekday, from: self) + 5) % 7
        let weekday = Weekday(rawValue: weekdayIndex)!
        return weekday
    }

    public var month: Int {
        Calendar.current.component(.month, from: self)
    }

    public var day: Int {
        Calendar.current.component(.day, from: self)
    }

    public var localizedShortDateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("MMM dd")
        return dateFormatter.string(from: self)
    }

    public func localizedDateString(dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = dateStyle
        dateFormatter.timeStyle = timeStyle
        return dateFormatter.string(from: self)
    }
}
