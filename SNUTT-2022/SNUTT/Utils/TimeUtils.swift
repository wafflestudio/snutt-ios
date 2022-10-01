//
//  TimeUtils.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/09/11.
//

import Foundation

struct TimeUtils {
    struct Time {
        let hour: Int
        let minute: Int
    }

    /// 월요일 7교시인 경우 `월7`을 반환한다.
    static func getStartDateTimeString(day: Weekday, classPeriod: Double) -> String {
        return "\(day.shortSymbol)\(String(format: "%g", classPeriod))"
    }

    /// `time: Double`을 분 단위로 정확하게 60진법 수로 환산한다.
    /// ex) 15.3 -> 15시 18분(`0.3 * 60 == 18`)
    static func getPreciseHourMinute(from time: Double) -> Time {
        let hour = Int(time)
        let minute = Int((time.truncatingRemainder(dividingBy: 1) * 60).rounded())
        return .init(hour: hour, minute: minute)
    }

    static func getPreciseHourMinuteString(from time: Double) -> String {
        let preciseTime = getPreciseHourMinute(from: time)
        return "\(preciseTime.hour):\(String(format: "%02d", preciseTime.minute))"
    }

    static func getDate(from time: Double) -> Date? {
        let time = getPreciseHourMinute(from: time)
        return getDate(from: time)
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

    static func getTimeInDouble(from time: Time) -> Double {
        return Double(time.hour) + Double(time.minute) / 60
    }

    static func getTimeInDouble(from date: Date) -> Double {
        return getTimeInDouble(from: getTime(from: date))
    }
}
