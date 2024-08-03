//
//  TimetableConfiguration.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/23.
//

import Foundation

struct TimetableConfiguration: Codable, Equatable {
    var minHour: Int = 9
    var maxHour: Int = 18
    var autoFit: Bool = true
    var compactMode: Bool = false
    var visibilityOptions: VisibilityOptions = .default

    var visibleWeeks: [Weekday] = [.mon, .tue, .wed, .thu, .fri]

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
        #if WIDGET
            true
        #else
            false
        #endif
    }
}


extension TimetableConfiguration {
    struct VisibilityOptions: Codable, OptionSet {
        var rawValue: Int8
        init(rawValue: Int8) {
            self.rawValue = rawValue
        }

        static var `default`: Self {
            [.lectureTitle, .place]
        }

        static let lectureTitle = Self(rawValue: 1 << 0)
        static let place = Self(rawValue: 1 << 1)
        static let lectureNumber = Self(rawValue: 1 << 2)
        static let instructor = Self(rawValue: 1 << 3)

        var isLectureTitleEnabled: Bool {
                get { contains(.lectureTitle) }
                set {
                    if newValue {
                        insert(.lectureTitle)
                    } else {
                        remove(.lectureTitle)
                    }
                }
            }

            var isPlaceEnabled: Bool {
                get { contains(.place) }
                set {
                    if newValue {
                        insert(.place)
                    } else {
                        remove(.place)
                    }
                }
            }

            var isLectureNumberEnabled: Bool {
                get { contains(.lectureNumber) }
                set {
                    if newValue {
                        insert(.lectureNumber)
                    } else {
                        remove(.lectureNumber)
                    }
                }
            }

            var isInstructorEnabled: Bool {
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
