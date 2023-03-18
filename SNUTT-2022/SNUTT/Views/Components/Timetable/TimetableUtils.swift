//
//  Utils.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/23.
//

import UIKit

struct TimetablePainter {
    /// 시간표 맨 왼쪽, 시간들을 나타내는 열의 너비
    static let hourWidth: CGFloat = 20

    /// 시간표 맨 위쪽, 날짜를 나타내는 행의 높이
    static let weekdayHeight: CGFloat = 25

    /// 컨테이너의 사이즈가 주어졌을 때, 하루의 너비를 계산한다.
    static func getWeekWidth(in containerSize: CGSize, weekCount: Int) -> CGFloat {
        return max((containerSize.width - hourWidth) / CGFloat(weekCount), 0)
    }

    /// 컨테이너의 사이즈가 주어졌을 때, 한 시간의 높이를 계산한다.
    static func getHourHeight(in containerSize: CGSize, hourCount: Int) -> CGFloat {
        return max((containerSize.height - weekdayHeight) / CGFloat(hourCount), 0)
    }

    /// 주어진 `TimePlace` 블록의 좌표(오프셋)를 구한다.
    ///
    /// 주어진 `TimePlace`를 시간표에 표시할 수 없는 경우(e.g. 시간이나 요일 범위에서 벗어난 경우 등)에는 `nil`을 리턴한다.
    static func getOffset(of timePlace: TimePlace, in containerSize: CGSize, current: Timetable?, config: TimetableConfiguration) -> CGPoint? {
        if containerSize == .zero {
            return nil
        }

        let minHour = getStartingHour(current: current, config: config)
        let hourIndex = timePlace.startTimeDouble - Double(minHour)
        guard let weekdayIndex = getVisibleWeeks(current: current, config: config).firstIndex(of: timePlace.day) else { return nil }
        if hourIndex < 0 {
            return nil
        }

        let x = hourWidth + CGFloat(weekdayIndex) * getWeekWidth(in: containerSize, weekCount: getWeekCount(current: current, config: config))
        let y = weekdayHeight + CGFloat(hourIndex) * getHourHeight(in: containerSize, hourCount: getHourCount(current: current, config: config))

        return CGPoint(x: x, y: y)
    }

    /// 주어진 `TimePlace`블록의 높이를 구한다.
    static func getHeight(of timePlace: TimePlace, in containerSize: CGSize, hourCount: Int, config: TimetableConfiguration) -> CGFloat {
        return timePlace.duration(compactMode: config.compactMode) * getHourHeight(in: containerSize, hourCount: hourCount)
    }

    // MARK: Auto Fit

    /// `autoFit`을 고려한 시간표의 시작 시각. 빈 시간표일 때에는 기본 9시이다.
    static func getStartingHour(current: Timetable?, config: TimetableConfiguration) -> Int {
        if let _ = current?.lectures.isEmpty,
           current?.earliestStartTime == nil
        {
            return 9
        }

        if !config.autoFit {
            return config.minHour
        }

        guard let startTime = current?.earliestStartTime else {
            return config.minHour
        }

        return Int(min(startTime, 9))
    }

    /// `autoFit`을 고려한 시간표의 종료 시각. 빈 시간표일 때에는 기본 17시이다.
    static func getEndingHour(current: Timetable?, config: TimetableConfiguration) -> Int {
        if let _ = current?.lectures.isEmpty,
           current?.lastEndTime == nil
        {
            return 17
        }

        if !config.autoFit {
            return config.maxHour
        }

        guard let endTime = current?.lastEndTime else {
            return config.maxHour
        }

        let startTime = getStartingHour(current: current, config: config)
        return max(Int((endTime - 1).rounded(.up)), startTime + 8) // autofit을 사용한다면 최소 8시간의 간격은 유지한다.
    }

    /// `autoFit`을 고려한 시간표의 세로 칸 수
    static func getHourCount(current: Timetable?, config: TimetableConfiguration) -> Int {
        let start = getStartingHour(current: current, config: config)
        let end = getEndingHour(current: current, config: config)
        return end - start + 1
    }

    /// `autoFit`을 고려한 시간표 요일들
    static func getVisibleWeeks(current: Timetable?, config: TimetableConfiguration) -> [Weekday] {
        if !config.autoFit {
            return config.visibleWeeksSorted
        }

        guard let lastWeekDay = current?.lastWeekDay else {
            return config.visibleWeeksSorted
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
    static func getWeekCount(current: Timetable?, config: TimetableConfiguration) -> Int {
        getVisibleWeeks(current: current, config: config).count
    }
}
