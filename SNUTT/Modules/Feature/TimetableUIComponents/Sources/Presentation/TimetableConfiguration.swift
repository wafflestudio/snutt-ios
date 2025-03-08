//
//  TimetableConfiguration.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import Foundation
import FoundationUtility
import MemberwiseInit
import TimetableInterface

@MemberwiseInit(.public)
public struct TimetableConfiguration: Codable, Equatable, Sendable {
    @Init(.public) var minHour: Int = 9
    @Init(.public) var maxHour: Int = 18
    @Init(.public) public var autoFit: Bool = true
    @Init(.public) public var compactMode: Bool = false
    @Init(.public) public var visibilityOptions: VisibilityOptions = .default

    @Init(.public) public var visibleWeeks: [Weekday] = [.mon, .tue, .wed, .thu, .fri]

    var visibleWeeksSorted: [Weekday] {
        var weekdayOrder: [Weekday: Int] = [:]
        for (offset, element) in Weekday.allCases.enumerated() {
            weekdayOrder[element] = offset
        }
        return visibleWeeks
            .sorted { weekdayOrder[$0]! < weekdayOrder[$1]! }
    }

    var weekCount: Int {
        visibleWeeks.count
    }

    func withAutoFitEnabled() -> Self {
        var this = self
        this.autoFit = true
        return this
    }

    func withTimeRangeSelectionMode() -> Self {
        var this = self
        this.visibleWeeks = [.mon, .tue, .wed, .thu, .fri]
        this.autoFit = false
        this.compactMode = true
        this.minHour = 8
        this.maxHour = 22
        return this
    }

    var isWidget: Bool {
        false
    }
}

extension TimetableConfiguration {
    public struct VisibilityOptions: Codable, OptionSet, Sendable {
        public var rawValue: Int8
        public init(rawValue: Int8) {
            self.rawValue = rawValue
        }

        public static var `default`: Self {
            [.lectureTitle, .place]
        }

        static var lectureTitle: Self {
            Self(rawValue: 1 << 0)
        }

        static var place: Self {
            Self(rawValue: 1 << 1)
        }

        static var lectureNumber: Self {
            Self(rawValue: 1 << 2)
        }

        static var instructor: Self {
            Self(rawValue: 1 << 3)
        }

        public var isLectureTitleEnabled: Bool {
            get { contains(.lectureTitle) }
            set {
                if newValue {
                    insert(.lectureTitle)
                } else {
                    remove(.lectureTitle)
                }
            }
        }

        public var isPlaceEnabled: Bool {
            get { contains(.place) }
            set {
                if newValue {
                    insert(.place)
                } else {
                    remove(.place)
                }
            }
        }

        public var isLectureNumberEnabled: Bool {
            get { contains(.lectureNumber) }
            set {
                if newValue {
                    insert(.lectureNumber)
                } else {
                    remove(.lectureNumber)
                }
            }
        }

        public var isInstructorEnabled: Bool {
            get { contains(.instructor) }
            set {
                if newValue {
                    insert(.instructor)
                } else {
                    remove(.instructor)
                }
            }
        }
    }
}
