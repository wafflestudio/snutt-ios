//
//  TimetablePainterThemeTests.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Foundation
import Testing
import ThemesInterface
import TimetableInterface

@testable import TimetableUIComponents

@MainActor
@Suite
struct TimetablePainterThemeTests {
    @Test("시간표가 없으면 SNUTT 기본 테마의 첫 번째 색상을 반환한다")
    func noTimetable() {
        let lecture = Lecture.stub(colorIndex: 999)
        let painter = TimetablePainter.stub(timetable: nil)
        let color = painter.resolveColor(for: lecture)
        #expect(color == Theme.snutt.colors.first ?? .temporary)
    }

    @Test("lectureID가 일치하지 않으면 SNUTT 기본 테마의 첫 번째 색상을 반환한다")
    func lectureIDNotFound() {
        let lecture = Lecture.stub(lectureID: "999", colorIndex: 999)
        let timetable = Timetable.stub(lectures: [Lecture.stub(lectureID: "1")])
        let painter = TimetablePainter.stub(timetable: timetable)
        let color = painter.resolveColor(for: lecture)
        #expect(color == Theme.snutt.colors.first ?? .temporary)
    }

    @Test("preferredTheme이 설정되면 시간표 내 강의 순서로 색상을 할당한다")
    func preferredTheme() {
        let lecture1 = Lecture.stub(lectureID: "1", colorIndex: 1)
        let lecture2 = Lecture.stub(lectureID: "2", colorIndex: 5)
        let timetable = Timetable.stub(lectures: [lecture1, lecture2])
        let painter = TimetablePainter.stub(timetable: timetable, preferredTheme: .fall)
        let color = painter.resolveColor(for: lecture2)
        #expect(color == Theme.fall.colors[1])
    }

    @Test("내장 테마에서 colorIndex가 0이고 customColor가 있으면 customColor를 사용한다")
    func builtInThemeCustomColor() {
        let customColor = LectureColor(fgHex: "#000000", bgHex: "#FF0000")
        let lecture = Lecture.stub(lectureID: "1", colorIndex: 0, customColor: customColor)
        let timetable = Timetable.stub(lectures: [lecture], theme: .builtInTheme(.modern))
        let painter = TimetablePainter.stub(timetable: timetable)
        let color = painter.resolveColor(for: lecture)
        #expect(color == customColor)
    }

    @Test("내장 테마에서 colorIndex가 1 이상이면 테마의 (colorIndex - 1) 색상을 사용한다")
    func builtInThemeColorIndex() {
        let lecture = Lecture.stub(lectureID: "1", colorIndex: 3)
        let timetable = Timetable.stub(lectures: [lecture], theme: .builtInTheme(.fall))
        let painter = TimetablePainter.stub(timetable: timetable)
        let color = painter.resolveColor(for: lecture)
        #expect(color == Theme.fall.colors[2])
    }

    @Test("내장 테마에서 colorIndex가 0이지만 customColor가 없으면 temporary 색상을 반환한다")
    func builtInThemeColorIndexZeroNoCustom() {
        let lecture = Lecture.stub(lectureID: "1", colorIndex: 0, customColor: nil)
        let timetable = Timetable.stub(lectures: [lecture], theme: .builtInTheme(.ice))
        let painter = TimetablePainter.stub(timetable: timetable)
        let color = painter.resolveColor(for: lecture)
        #expect(color == .temporary)
    }

    @Test("커스텀 테마에서 강의에 customColor가 있으면 customColor를 우선 사용한다")
    func customThemeLectureCustomColor() {
        let customColor = LectureColor(fgHex: "#FFFFFF", bgHex: "#00FF00")
        let lecture = Lecture.stub(lectureID: "1", colorIndex: 2, customColor: customColor)
        let timetable = Timetable.stub(lectures: [lecture], theme: .customTheme(themeID: "custom1"))
        let painter = TimetablePainter.stub(timetable: timetable, availableThemes: [.preview1])
        let color = painter.resolveColor(for: lecture)
        #expect(color == customColor)
    }

    @Test("커스텀 테마에서 customColor가 없으면 availableThemes에서 찾아 강의 순서로 색상을 할당한다")
    func customThemeFromAvailable() {
        let lecture1 = Lecture.stub(lectureID: "1", colorIndex: 1)
        let lecture2 = Lecture.stub(lectureID: "2", colorIndex: 3)
        let timetable = Timetable.stub(lectures: [lecture1, lecture2], theme: .customTheme(themeID: "preview2"))
        let painter = TimetablePainter.stub(timetable: timetable, availableThemes: [.preview1, .preview2, .preview3])
        let color = painter.resolveColor(for: lecture2)
        #expect(color == Theme.preview2.colors[1])
    }

    @Test("커스텀 테마 ID가 availableThemes에 없으면 SNUTT 테마로 폴백한다")
    func customThemeNotFoundFallback() {
        let lecture1 = Lecture.stub(lectureID: "1", colorIndex: 1)
        let lecture2 = Lecture.stub(lectureID: "2", colorIndex: 2)
        let timetable = Timetable.stub(lectures: [lecture1, lecture2], theme: .customTheme(themeID: "nonexistent"))
        let painter = TimetablePainter.stub(timetable: timetable, availableThemes: [.preview1])
        let color = painter.resolveColor(for: lecture2)
        #expect(color == Theme.snutt.colors[1])
    }
}
