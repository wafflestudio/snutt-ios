//
//  TimetablePainter+Theme.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import TimetableInterface

extension TimetablePainter {
    func getColor(for lecture: any Lecture) -> LectureColor {
        if let customColor = lecture.customColor {
            return customColor
        }
        guard let lectureIndex = currentTimetable?.lectures.firstIndex(where: { $0.id == lecture.id })
        else { return .temporary }
        return selectedTheme.color(at: lectureIndex)
    }
}

extension Theme {
    fileprivate func color(at index: Int) -> LectureColor {
        colors[index % colors.count]
    }
}
