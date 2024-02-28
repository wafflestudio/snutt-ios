//
//  TimetableUtils.swift
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

        if timePlace.startTime.hour >= getEndingHour(current: current, config: config) + 1 {
            return nil
        }

        let minHour = getStartingHour(current: current, config: config)

        if timePlace.endTime.hour < minHour {
            return nil
        }

        let hourIndex = max(Double(timePlace.startMinute - minHour * 60) / 60, 0)
        guard let weekdayIndex = getVisibleWeeks(current: current, config: config).firstIndex(of: timePlace.day) else { return nil }

        let x = hourWidth + CGFloat(weekdayIndex) * getWeekWidth(in: containerSize, weekCount: getWeekCount(current: current, config: config))
        let y = weekdayHeight + CGFloat(hourIndex) * getHourHeight(in: containerSize, hourCount: getHourCount(current: current, config: config))

        return CGPoint(x: x, y: y)
    }

    /// 주어진 `TimePlace`블록의 높이를 구한다.
    static func getHeight(of timePlace: TimePlace, in containerSize: CGSize, current: Timetable?, config: TimetableConfiguration) -> CGFloat {
        let hourCount = getHourCount(current: current, config: config)
        let minHour = getStartingHour(current: current, config: config)

        /// 시간표의 시작 시각보다 강의 시작이 이른 경우, 그만큼의 시간을 차감해서 높이를 계산한다.
        let timeBlockCropAdjustment = abs(min(CGFloat(timePlace.startMinute - minHour * 60) / 60, 0))
        return (timePlace.duration(compactMode: config.compactMode) - timeBlockCropAdjustment) * getHourHeight(in: containerSize, hourCount: hourCount)
    }

    // MARK: Auto Fit

    /// `autoFit`을 고려한 시간표의 시작 시각. 빈 시간표인 경우 기본 9시이다.
    static func getStartingHour(current: Timetable?, config: TimetableConfiguration) -> Int {
        if !config.autoFit {
            return config.minHour
        }

        if let current = current, current.selectedLecture == nil && current.lectures.isEmpty {
            return 9
        }

        guard let startTime = current?.earliestStartHour else {
            return config.minHour
        }

        return min(startTime, 9)
    }

    /// `autoFit`을 고려한 시간표의 종료 시각. 빈 시간표인 경우 기본 17시이다.
    static func getEndingHour(current: Timetable?, config: TimetableConfiguration) -> Int {
        if !config.autoFit {
            return config.maxHour
        }

        if let current = current, current.selectedLecture == nil && current.lectures.isEmpty {
            return 17
        }

        guard let endTime = current?.lastEndHour else {
            return config.maxHour
        }

        let startTime = getStartingHour(current: current, config: config)
        return max(endTime, startTime + 8) // autofit을 사용한다면 최소 8시간의 간격은 유지한다.
    }

    /// `autoFit`을 고려한 시간표의 세로 칸 수
    static func getHourCount(current: Timetable?, config: TimetableConfiguration) -> Int {
        let start = getStartingHour(current: current, config: config)
        let end = getEndingHour(current: current, config: config)
        return end - start + 1
    }

    /// `autoFit`을 고려한 시간표 요일들. 빈 시간표인 경우 기본 월~금이다.
    static func getVisibleWeeks(current: Timetable?, config: TimetableConfiguration) -> [Weekday] {
        if !config.autoFit {
            return config.visibleWeeksSorted
        }

        if current?.lectures.isEmpty ?? true {
            return [.mon, .tue, .wed, .thu, .fri]
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

    // MARK: TimeRange Selection

    /// 첫날, 첫 시간대를 시작으로 하여 30분 단위로 시간대가 선택되었는지를 나타내는 마스크
    typealias BlockMask = [Bool]

    /// `BlockMask` 배열의 크기 (`weekCount` \* `halfHourCount`)
    static let blockMaskSize = weekCount * halfHourCount

    /// 시간대 선택은 월~금까지 지원
    static let weekCount = 5

    /// 시간대 선택은 8시부터 22시 59분까지 지원
    static let halfHourCount = 30

    /// `BlockMask`를 `[SearchTimeMaskDto]`로 변환한다.
    static func getSelectedTimeRange(from blockMask: BlockMask) -> [SearchTimeMaskDto] {
        var result: [SearchTimeMaskDto] = []
        let strided = stride(from: 0, to: blockMaskSize, by: 30).map {
            Array(blockMask[$0 ..< min($0 + halfHourCount, blockMaskSize)])
        }
        var isCounting = false
        var (count, start) = (0, 0)
        for (day, dayBitMask) in strided.enumerated() {
            for (minute, selected) in dayBitMask.enumerated() {
                if selected {
                    count += 1
                    if !isCounting {
                        isCounting = true
                        start = minute
                    }
                } else {
                    if isCounting {
                        isCounting = false
                        result.append(.init(day: day, startMinute: start * halfHourCount + 480, endMinute: (start + count) * halfHourCount + 480))
                        count = 0
                    }
                }
            }
        }
        return result
    }

    /// 좌표(오프셋)에 해당하는 인덱스가 `true`로 설정된 `BlockMask`를 반환한다.
    static func toggleOnBlockMask(at point: CGPoint, in containerSize: CGSize) -> BlockMask {
        let (rowIndex, columnIndex) = getIndex(of: point, in: containerSize)

        var blockMask = Array(repeating: false, count: blockMaskSize)
        if columnIndex < 0 || columnIndex > (weekCount - 1) || rowIndex < 0 || rowIndex > (halfHourCount - 1) {
            return blockMask
        }

        blockMask[rowIndex + columnIndex * halfHourCount] = true
        return blockMask
    }

    /// 좌표(오프셋)가 선택된 시간대인지 확인한다.
    static func isSelected(point: CGPoint, blockMask: BlockMask, in containerSize: CGSize) -> Bool {
        let (rowIndex, columnIndex) = getIndex(of: point, in: containerSize)
        return blockMask[rowIndex + columnIndex * halfHourCount]
    }

    /// 주어진 `BlockMask`의 인덱스로 좌표(오프셋)를 구한다.
    static func getOffset(of blockMaskIndex: Int, in containerSize: CGSize) -> CGPoint? {
        if containerSize == .zero {
            return nil
        }

        let dayIndex = blockMaskIndex / halfHourCount
        let halfHourIndex = blockMaskIndex % halfHourCount

        let x = hourWidth + CGFloat(dayIndex) * getWeekWidth(in: containerSize, weekCount: weekCount)
        let y = weekdayHeight + CGFloat(halfHourIndex) * getSingleBlockHeight(in: containerSize)
        return CGPoint(x: x, y: y)
    }

    /// 시간대 `TimeMask`를 `BlockMask`로 변환한다.
    static func toBlockMask(from timeMask: [SearchTimeMaskDto]) -> BlockMask {
        var blockMask = Array(repeating: false, count: blockMaskSize)
        for time in timeMask {
            for minute in stride(from: time.startMinute, to: time.endMinute, by: 30) {
                let halfHourIndex = Int(floor(Double(minute - 480) / 30.0))
                blockMask[time.day * halfHourCount + halfHourIndex] = true
            }
        }
        return blockMask
    }

    /// 30분 단위 블록 하나의 높이를 구한다.
    static func getSingleBlockHeight(in containerSize: CGSize) -> CGFloat {
        (containerSize.height - weekdayHeight) / CGFloat(halfHourCount)
    }

    /// 좌표(오프셋)에 해당하는 `BlockMask`에서의 인덱스를 구한다.
    private static func getIndex(of point: CGPoint, in containerSize: CGSize) -> (Int, Int) {
        let weekWidth = getWeekWidth(in: containerSize, weekCount: weekCount)

        let rowIndex = Int(floor((point.y - weekdayHeight) / getSingleBlockHeight(in: containerSize)))
        let columnIndex = Int(floor((point.x - hourWidth) / weekWidth))

        return (rowIndex, columnIndex)
    }
}
