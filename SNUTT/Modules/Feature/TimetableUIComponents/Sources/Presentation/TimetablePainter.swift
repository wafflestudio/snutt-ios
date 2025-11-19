//
//  TimetablePainter.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import CoreGraphics
import FoundationUtility
import MemberwiseInit
import ThemesInterface
import TimetableInterface

@MemberwiseInit(.public)
public struct TimetablePainter: Sendable {
    public let currentTimetable: Timetable?
    public let selectedLecture: Lecture?
    /// If `nil`, the theme of the current timetable is used.
    /// If not, this theme will override it.
    public let preferredTheme: Theme?
    /// An array of available themes, including the custom themes downloaded from the server.
    public let availableThemes: [Theme]
    public let configuration: TimetableConfiguration
}

extension TimetablePainter {
    /// 시간표 맨 왼쪽, 시간들을 나타내는 열의 너비
    var hourWidth: CGFloat { 20 }

    /// 시간표 맨 위쪽, 날짜를 나타내는 행의 높이
    var weekdayHeight: CGFloat { 25 }

    /// 컨테이너의 사이즈가 주어졌을 때, 하루의 너비를 계산한다.
    func getWeekWidth(in containerSize: CGSize, weekCount: Int) -> CGFloat {
        return max((containerSize.width - hourWidth) / CGFloat(weekCount), 0)
    }

    /// 컨테이너의 사이즈가 주어졌을 때, 한 시간의 높이를 계산한다.
    func getHourHeight(in containerSize: CGSize, hourCount: Int) -> CGFloat {
        return max((containerSize.height - weekdayHeight) / CGFloat(hourCount), 0)
    }

    /// 주어진 `TimePlace` 블록의 좌표(오프셋)를 구한다.
    ///
    /// 주어진 `TimePlace`를 시간표에 표시할 수 없는 경우(e.g. 시간이나 요일 범위에서 벗어난 경우 등)에는 `nil`을 리턴한다.
    func getOffset(of timePlace: TimePlace, in containerSize: CGSize) -> CGPoint? {
        if containerSize == .zero {
            return nil
        }

        if timePlace.startTime.hour >= endingHour + 1 {
            return nil
        }

        let minHour = startingHour

        if timePlace.endTime.hour < minHour {
            return nil
        }

        let hourIndex = max(Double(timePlace.startTime.absoluteMinutes - minHour * 60) / 60, 0)
        guard let weekdayIndex = visibleWeeks.firstIndex(of: timePlace.day) else { return nil }

        let x = hourWidth + CGFloat(weekdayIndex) * getWeekWidth(in: containerSize, weekCount: weekCount)
        let y = weekdayHeight + CGFloat(hourIndex) * getHourHeight(in: containerSize, hourCount: hourCount)

        return CGPoint(x: x, y: y)
    }

    /// 주어진 `TimePlace`블록의 높이를 구한다.
    func getHeight(of timePlace: TimePlace, in containerSize: CGSize) -> CGFloat {
        let hourCount = hourCount
        let minHour = startingHour

        /// 시간표의 시작 시각보다 강의 시작이 이른 경우, 그만큼의 시간을 차감해서 높이를 계산한다.
        let timeBlockCropAdjustment = abs(min(CGFloat(timePlace.startTime.absoluteMinutes - minHour * 60) / 60, 0))
        return (timePlace.duration(compactMode: configuration.compactMode) - timeBlockCropAdjustment)
            * getHourHeight(
                in: containerSize,
                hourCount: hourCount
            )
    }

    // MARK: Auto Fit

    /// `autoFit`을 고려한 시간표의 시작 시각. 빈 시간표인 경우 기본 9시이다.
    var startingHour: Int {
        if !configuration.autoFit {
            return configuration.minHour
        }

        if aggregatedTimePlaces.isEmpty {
            return 9
        }

        guard let earliestStartHour else {
            return configuration.minHour
        }

        return min(earliestStartHour, 9)
    }

    /// `autoFit`을 고려한 시간표의 종료 시각. 빈 시간표인 경우 기본 17시이다.
    var endingHour: Int {
        if !configuration.autoFit {
            return configuration.maxHour
        }

        if aggregatedTimePlaces.isEmpty {
            return 17
        }

        guard let lastEndHour else {
            return configuration.maxHour
        }

        let startTime = startingHour
        return max(lastEndHour, startTime + 8)  // autofit을 사용한다면 최소 8시간의 간격은 유지한다.
    }

    /// `autoFit`을 고려한 시간표의 세로 칸 수
    var hourCount: Int {
        let start = startingHour
        let end = endingHour
        return end - start + 1
    }

    /// `autoFit`을 고려한 시간표 요일들. 빈 시간표인 경우 기본 월~금이다.
    var visibleWeeks: [Weekday] {
        if !configuration.autoFit {
            return configuration.visibleWeeksSorted
        }

        if aggregatedTimePlaces.isEmpty {
            return [.mon, .tue, .wed, .thu, .fri]
        }

        guard let lastWeekDay else {
            return configuration.visibleWeeksSorted
        }

        if lastWeekDay == .sun {
            return [.mon, .tue, .wed, .thu, .fri, .sat, .sun]
        }
        if lastWeekDay == .sat {
            return [.mon, .tue, .wed, .thu, .fri, .sat]
        }
        return [.mon, .tue, .wed, .thu, .fri]
    }

    /// `autoFit`을 고려한 시간표 요일 수
    var weekCount: Int {
        visibleWeeks.count
    }

    private var aggregatedTimePlaces: [TimePlace] {
        let aggregatedLectures =
            if let currentTimetable {
                currentTimetable.lectures + [selectedLecture]
            } else {
                [selectedLecture]
            }
        return
            aggregatedLectures
            .compactMap { $0 }
            .reduce(into: []) { partialResult, lecture in
                partialResult.append(contentsOf: lecture.timePlaces)
            }
    }

    private var lastEndHour: Int? {
        aggregatedTimePlaces.max(by: { $0.endTime.absoluteMinutes < $1.endTime.absoluteMinutes })?.endTime.hour
    }

    private var lastWeekDay: Weekday? {
        aggregatedTimePlaces.max(by: { $0.day.rawValue < $1.day.rawValue })?.day
    }

    private var earliestStartHour: Int? {
        aggregatedTimePlaces.min(by: { $0.startTime.absoluteMinutes < $1.startTime.absoluteMinutes })?.startTime.hour
    }
}

extension TimetableInterface.Time {
    public var absoluteMinutes: Int { hour * 60 + minute }
    func roundUpForCompactMode() -> Self {
        var hour = self.hour
        var minute = self.minute
        if (1...30).contains(minute) {
            minute = 30
        } else if minute > 30 {
            hour += 1
            minute = 0
        }
        return .init(hour: hour, minute: minute)
    }
}

extension [Lecture] {
    fileprivate var aggregatedTimePlaces: [TimePlace] {
        compactMap { $0 }
            .reduce(into: []) { partialResult, lecture in
                partialResult.append(contentsOf: lecture.timePlaces)
            }
    }
}

extension TimePlace {
    fileprivate func duration(compactMode: Bool) -> CGFloat {
        return CGFloat(roundedEndMinute(compactMode: compactMode) - startTime.absoluteMinutes) / 60
    }

    private func roundedEndMinute(compactMode: Bool) -> Int {
        if compactMode, !isCustom {
            let rounded = endTime.roundUpForCompactMode()
            return rounded.hour * 60 + rounded.minute
        } else {
            return endTime.absoluteMinutes
        }
    }
}
