//
//  STTime.swift
//  SNUTT
//
//  Created by Rajin on 2015. 9. 6..
//  Copyright (c) 2015년 WaffleStudio. All rights reserved.
//

import Foundation

struct STTime {
    var day: STDay
    var startPeriod: Double
    var duration: Double
    var endPeriod: Double {
        return startPeriod + duration
    }

    /// 수업이 실제로 끝나는 시각(교시). `duration`이 `0.5`로 끝나는지에 따라 적절한 시간(10분 또는 15분)을 빼준다.
    var endPeriodPrecise: Double {
        let isHalfPeriod = duration.truncatingRemainder(dividingBy: 1) == 0.5
        return startPeriod + duration - (isHalfPeriod ? 15 / 60 : 10 / 60)
    }

    init(day: Int, startPeriod: Double, duration: Double) {
        self.day = STDay(rawValue: day)!
        self.startPeriod = startPeriod
        self.duration = duration
    }

    func longString() -> String {
        return day.longString() + " " + startPeriod.periodString() + "~" + endPeriodPrecise.periodStringPrecise()
    }

    func shortString() -> String {
        return day.shortString() + " " + startPeriod.periodString() + "~" + endPeriodPrecise.periodStringPrecise()
    }

    func startString() -> String {
        return day.shortString() + String(format: "%g", startPeriod)
    }

    func isOverlappingWith(_ tmp: STTime) -> Bool {
        if day != tmp.day {
            return false
        }
        if tmp.startPeriod < startPeriod {
            if tmp.startPeriod + tmp.duration > startPeriod {
                return true
            }
            return false
        } else {
            if startPeriod + duration > tmp.startPeriod {
                return true
            }
            return false
        }
    }
}

extension STTime: Equatable {}

func == (lhs: STTime, rhs: STTime) -> Bool {
    return lhs.day == rhs.day && lhs.startPeriod == rhs.startPeriod && lhs.duration == rhs.duration
}
