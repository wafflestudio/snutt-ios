//
//  Date+ext.swift
//  SNUTT
//
//  Created by 최유림 on 2022/11/07.
//

import Foundation

extension Date {
    func daysFrom(_ date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
}

extension Date {
    var weekday: Weekday {
        let weekdayIndex = (Calendar.current.component(.weekday, from: self) + 5) % 7
        let weekday = Weekday(rawValue: weekdayIndex)!
        return weekday
    }

    var month: Int {
        Calendar.current.component(.month, from: self)
    }

    var day: Int {
        Calendar.current.component(.day, from: self)
    }

    var localizedDateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("MMM dd")
        return dateFormatter.string(from: self)
    }
}
