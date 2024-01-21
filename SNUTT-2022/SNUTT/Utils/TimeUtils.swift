//
//  TimeUtils.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/09/11.
//

import Foundation

struct TimeUtils {
    struct Time {
        var hour: Int
        var minute: Int

        func toString() -> String {
            return "\(String(format: "%02d", hour)):\(String(format: "%02d", minute))"
        }
    }
    
    static func getDate(from time: Time) -> Date? {
        return Calendar.current.date(from: DateComponents(hour: time.hour, minute: time.minute))
    }

    static func getTime(from date: Date) -> Time {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        return .init(hour: hour, minute: minute)
    }
}
