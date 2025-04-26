//
//  TimetablePainter+Theme.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import TimetableInterface
import ThemesInterface

extension TimetablePainter {
    @MainActor
    func resolveColor(for lecture: Lecture) -> LectureColor {
        guard let lectures = currentTimetable?.lectures,
              let lectureIndex = lectures.firstIndex(where: { $0.lectureID == lecture.lectureID })
        else { return Theme.snutt.colors.first ?? .temporary }
        if let preferredTheme {
            return preferredTheme.color(at: lectureIndex)
        }
        let theme = currentTimetable?.theme ?? .builtInTheme(.snutt)
        switch theme {
        case .builtInTheme(let theme):
            let lecture = lectures[lectureIndex]
            if lecture.colorIndex == 0, let customColor = lecture.customColor {
                return customColor
            }
            return theme.color(at: lectureIndex)
        case .customTheme(let themeID):
            if let lectureColor = lecture.customColor {
                return lectureColor
            }
            let theme = availableThemes.first { $0.id == themeID } ?? .snutt
            return theme.color(at: lectureIndex)
        }
    }
}


extension Theme {
    fileprivate func color(at index: Int) -> LectureColor {
        colors[index % colors.count]
    }
}
