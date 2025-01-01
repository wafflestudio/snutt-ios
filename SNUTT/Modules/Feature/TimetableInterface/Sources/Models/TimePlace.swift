//
//  TimePlace.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import Foundation
import MemberwiseInit
import FoundationUtility

public struct TimePlace: Sendable, Codable, Equatable, Identifiable, CustomStringConvertible {
    public let id: String
    public var day: Weekday
    public var startTime: Time
    public var endTime: Time
    public var place: String
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
