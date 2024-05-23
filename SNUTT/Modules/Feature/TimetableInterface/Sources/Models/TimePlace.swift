//
//  TimePlace.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import Foundation
import MemberwiseInit

public struct TimePlace: Sendable, Codable, Equatable, Identifiable, CustomStringConvertible {
    public let id: String
    public let day: Weekday
    public let startTime: Time
    public let endTime: Time
    public let place: String
    public let isCustom: Bool
    public var description: String {
        "\(day.veryShortSymbol)(\(startTime.description)~\(endTime.description))"
    }

    public init(
        id: String,
        day: Weekday,
        startTime: Time,
        endTime: Time,
        place: String,
        isCustom: Bool = false
    ) {
        self.id = id
        self.day = day
        self.startTime = startTime
        self.endTime = endTime
        self.place = place
        self.isCustom = isCustom
    }
}

@MemberwiseInit(.public)
public struct Time: Sendable, Codable, Equatable, CustomStringConvertible {
    public let hour: Int
    public let minute: Int
    public var description: String {
        "\(String(format: "%02d", hour)):\(String(format: "%02d", minute))"
    }
}

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
