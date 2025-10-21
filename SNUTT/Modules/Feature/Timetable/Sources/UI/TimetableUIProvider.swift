//
//  TimetableUIProvider.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SwiftUI
import ThemesInterface
import TimetableInterface
import TimetableUIComponents

public struct TimetableUIProvider: TimetableUIProvidable {
    public nonisolated init() {}
    public func lectureDetailRow(
        type: TimetableInterface.DetailLabelType,
        lecture: TimetableInterface.Lecture
    ) -> AnyView {
        AnyView(LectureDetailRow(type: type, lecture: lecture))
    }

    public func timetableView(
        timetable: TimetableInterface.Timetable,
        configuration: TimetableInterface.TimetableConfiguration,
        preferredTheme: Theme?,
        availableThemes: [Theme]
    ) -> AnyView {
        AnyView(
            TimetableZStack(
                painter: TimetablePainter(
                    currentTimetable: timetable,
                    selectedLecture: nil,
                    preferredTheme: preferredTheme,
                    availableThemes: availableThemes,
                    configuration: configuration
                )
            )
        )
    }
}
