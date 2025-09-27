//
//  TimetableConfiguration.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import Foundation
import FoundationUtility
import MemberwiseInit

@MemberwiseInit(.public)
public struct TimetableConfiguration: Codable, Equatable, Sendable {
    @Init(.public) public var minHour: Int = 9
    @Init(.public) public var maxHour: Int = 18
    @Init(.public) public var autoFit: Bool = true
    @Init(.public) public var compactMode: Bool = false
    @Init(.public) public var visibilityOptions: VisibilityOptions = .default

    @Init(.public) public var visibleWeeks: [Weekday] = [.mon, .tue, .wed, .thu, .fri]
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

        public static var lectureTitle: Self {
            Self(rawValue: 1 << 0)
        }

        public static var place: Self {
            Self(rawValue: 1 << 1)
        }

        public static var lectureNumber: Self {
            Self(rawValue: 1 << 2)
        }

        public static var instructor: Self {
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
