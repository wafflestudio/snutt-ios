//
//  TimetablePainterTests.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import CoreGraphics
import Foundation
import FoundationUtility
import Testing
import ThemesInterface
import TimetableInterface

@testable import TimetableUIComponents

@Suite
struct TimetablePainterTests {
    @Test("컨테이너에서 요일 너비를 올바르게 계산해야 한다")
    func weekWidth() {
        let painter = TimetablePainter.stub()
        let containerSize = CGSize(width: 320, height: 600)
        let weekWidth = painter.getWeekWidth(in: containerSize)
        #expect(weekWidth == CGFloat(320 - 20) / 5)
    }

    @Test("컨테이너에서 시간 높이를 올바르게 계산해야 한다")
    func hourHeight() {
        let configuration = TimetableConfiguration(minHour: 9, maxHour: 18, autoFit: false)
        let painter = TimetablePainter.stub(configuration: configuration)
        let containerSize = CGSize(width: 320, height: 600)
        let hourHeight = painter.getHourHeight(in: containerSize)
        #expect(hourHeight == CGFloat(600 - 25) / 10)
    }

    @Test("TimePlace의 좌표를 올바르게 계산해야 한다")
    func offset() {
        let painter = TimetablePainter.stub()
        let containerSize = CGSize(width: 320, height: 600)
        let timePlace = TimePlace.stub(day: .mon, startHour: 9, endHour: 10)
        let offset = painter.getOffset(of: timePlace, in: containerSize)
        #expect(offset != nil)
        #expect(offset?.x == 20)
        #expect(offset?.y == 25)
    }

    @Test("TimePlace의 높이를 올바르게 계산해야 한다")
    func height() {
        let lecture = Lecture.stub(timePlaces: [TimePlace.stub(day: .mon, startHour: 9, endHour: 11)])
        let timetable = Timetable.stub(lectures: [lecture])
        let painter = TimetablePainter.stub(timetable: timetable)
        let containerSize = CGSize(width: 320, height: 600)
        let timePlace = TimePlace.stub(day: .mon, startHour: 9, endHour: 11)
        let height = painter.getHeight(of: timePlace, in: containerSize)
        let expectedHeight = 2.0 * painter.getHourHeight(in: containerSize)
        #expect(height == expectedHeight)
    }

    @Test("시간표 범위 밖 TimePlace는 nil을 반환해야 한다")
    func offsetOutOfRange() {
        let painter = TimetablePainter.stub()
        let containerSize = CGSize(width: 320, height: 600)
        let timePlace = TimePlace.stub(day: .mon, startHour: 22, endHour: 23)
        let offset = painter.getOffset(of: timePlace, in: containerSize)
        #expect(offset == nil)
    }

    // MARK: - AutoFit Tests

    @Test("빈 시간표는 9시에 시작해야 한다")
    func emptyStartingHour() {
        let timetable = Timetable.stub(lectures: [])
        let painter = TimetablePainter.stub(timetable: timetable)
        #expect(painter.startingHour == 9)
    }

    @Test("빈 시간표는 17시에 끝나야 한다")
    func emptyEndingHour() {
        let timetable = Timetable.stub(lectures: [])
        let painter = TimetablePainter.stub(timetable: timetable)
        #expect(painter.endingHour == 17)
    }

    @Test("AutoFit 활성화 시 가장 이른 강의 시각을 반영해야 한다")
    func autoFitStartingHour() {
        let lecture = Lecture.stub(timePlaces: [.stub(day: .mon, startHour: 8, endHour: 9)])
        let timetable = Timetable.stub(lectures: [lecture])
        let painter = TimetablePainter.stub(timetable: timetable)
        #expect(painter.startingHour == 8)
    }

    @Test("AutoFit 활성화 시 가장 늦은 강의 시각을 반영해야 한다")
    func autoFitEndingHour() {
        let lecture = Lecture.stub(timePlaces: [.stub(day: .mon, startHour: 10, endHour: 20)])
        let timetable = Timetable.stub(lectures: [lecture])
        let painter = TimetablePainter.stub(timetable: timetable)
        #expect(painter.endingHour == 20)
    }

    @Test("AutoFit으로 계산된 시간 범위는 최소 8시간이어야 한다")
    func minimumHourCount() {
        let lecture = Lecture.stub(timePlaces: [.stub(day: .mon, startHour: 10, endHour: 11)])
        let timetable = Timetable.stub(lectures: [lecture])
        let painter = TimetablePainter.stub(timetable: timetable)
        #expect(painter.hourCount >= 9)
    }

    @Test("빈 시간표는 월~금을 표시해야 한다")
    func emptyVisibleWeeks() {
        let timetable = Timetable.stub(lectures: [])
        let painter = TimetablePainter.stub(timetable: timetable)
        #expect(painter.visibleWeeks == [.mon, .tue, .wed, .thu, .fri])
    }

    @Test("토요일 강의가 있으면 월~토를 표시해야 한다")
    func visibleWeeksWithSaturday() {
        let lecture = Lecture.stub(timePlaces: [.stub(day: .sat, startHour: 10, endHour: 12)])
        let timetable = Timetable.stub(lectures: [lecture])
        let painter = TimetablePainter.stub(timetable: timetable)
        #expect(painter.visibleWeeks == [.mon, .tue, .wed, .thu, .fri, .sat])
    }

    @Test("일요일 강의가 있으면 월~일을 표시해야 한다")
    func visibleWeeksWithSunday() {
        let lecture = Lecture.stub(timePlaces: [.stub(day: .sun, startHour: 10, endHour: 12)])
        let timetable = Timetable.stub(lectures: [lecture])
        let painter = TimetablePainter.stub(timetable: timetable)
        #expect(painter.visibleWeeks == [.mon, .tue, .wed, .thu, .fri, .sat, .sun])
    }

    // MARK: - Manual Configuration Tests

    @Test("AutoFit 비활성화 시 설정값을 사용해야 한다")
    func manualConfiguration() {
        let configuration = TimetableConfiguration(minHour: 8, maxHour: 22, autoFit: false)
        let lecture = Lecture.stub(timePlaces: [.stub(day: .mon, startHour: 10, endHour: 11)])
        let timetable = Timetable.stub(lectures: [lecture])
        let painter = TimetablePainter.stub(timetable: timetable, configuration: configuration)
        #expect(painter.startingHour == 8)
        #expect(painter.endingHour == 22)
    }

    @Test("시간표 시작 전에 시작하는 강의는 잘린 높이를 반환해야 한다")
    func heightCroppedAtStart() {
        let configuration = TimetableConfiguration(minHour: 9, maxHour: 18, autoFit: false)
        let painter = TimetablePainter.stub(configuration: configuration)
        let containerSize = CGSize(width: 320, height: 600)
        let timePlace = TimePlace.stub(day: .mon, startHour: 8, endHour: 11)
        let height = painter.getHeight(of: timePlace, in: containerSize)
        /// 3시간짜리 강의이지만 잘려서 2시간치 높이를 반환해야 한다.
        let expectedHeight = 2.0 * painter.getHourHeight(in: containerSize)
        #expect(height == expectedHeight)
    }

    @Test("TimePlace가 없는 강의만 있으면 빈 시간표처럼 동작해야 한다")
    func lectureWithoutTimePlaces() {
        let lecture = Lecture.stub(timePlaces: [])
        let timetable = Timetable.stub(lectures: [lecture])
        let painter = TimetablePainter.stub(timetable: timetable)
        #expect(painter.startingHour == 9)
        #expect(painter.endingHour == 17)
        #expect(painter.visibleWeeks == [.mon, .tue, .wed, .thu, .fri])
    }

    @Test("selectedLecture에 TimePlace가 없으면 빈 시간표처럼 동작해야 한다")
    func selectedLectureWithoutTimePlaces() {
        let selectedLecture = Lecture.stub(timePlaces: [])
        let painter = TimetablePainter.stub(selectedLecture: selectedLecture)
        #expect(painter.startingHour == 9)
        #expect(painter.endingHour == 17)
        #expect(painter.visibleWeeks == [.mon, .tue, .wed, .thu, .fri])
    }

    // MARK: - Display Grid Metrics Tests

    @Test("geometry.size 기준으로 hourHeight를 계산하고, extendedContainerSize 기준으로 displayHourCount를 계산해야 한다")
    func displayGridMetricsWithSafeAreaInsets() {
        // 9-18시 (10시간)
        let configuration = TimetableConfiguration(minHour: 9, maxHour: 18, autoFit: false)
        let painter = TimetablePainter.stub(configuration: configuration)
        let geometry = TimetableGeometry(
            size: CGSize(width: 320, height: 500),
            safeAreaInsets: .init(top: 0, leading: 0, bottom: 50, trailing: 0)
        )

        let metrics = painter.getDisplayGridMetrics(in: geometry)

        // hourHeight는 geometry.size 기준: (500 - 25) / 10 = 47.5
        #expect(metrics.hourHeight == 47.5)
        // displayHourCount는 extendedContainerSize 기준: (550 - 25) / 47.5 = 11
        #expect(metrics.displayHourCount == 11)
    }

    @Test("18시간 이상 범위에서 weekdayHeight를 제외하고 계산하여 헤더가 잘리지 않아야 한다")
    func displayGridMetrics18PlusHours() {
        // 2-20시 (19시간), 원래 이슈 재현
        let configuration = TimetableConfiguration(minHour: 2, maxHour: 20, autoFit: false)
        let painter = TimetablePainter.stub(configuration: configuration)
        let geometry = TimetableGeometry(
            size: CGSize(width: 320, height: 500),
            safeAreaInsets: .init(top: 0, leading: 0, bottom: 50, trailing: 0)
        )

        let metrics = painter.getDisplayGridMetrics(in: geometry)

        // hourHeight는 geometry.size 기준: (500 - 25) / 19 = 25
        #expect(metrics.hourHeight == 25)
        // displayHourCount는 extendedContainerSize 기준: (550 - 25) / 25 = 21
        #expect(metrics.displayHourCount == 21)
        // weekdayHeight + displayHourCount * hourHeight <= extendedContainerSize.height
        let totalHeight = painter.weekdayHeight + CGFloat(metrics.displayHourCount) * metrics.hourHeight
        #expect(totalHeight <= geometry.extendedContainerSize.height)
    }

    @Test("hourHeight가 10pt 미만인 경우 최소값 10pt로 제한해야 한다")
    func displayGridMetricsMinimumHourHeight() {
        let configuration = TimetableConfiguration(minHour: 0, maxHour: 23, autoFit: false)
        let painter = TimetablePainter.stub(configuration: configuration)
        let geometry = TimetableGeometry(
            size: CGSize(width: 320, height: 200),
            safeAreaInsets: .init(top: 0, leading: 0, bottom: 20, trailing: 0)
        )

        let metrics = painter.getDisplayGridMetrics(in: geometry)

        // hourHeight = (200 - 25) / 24 = 7.29... → 10pt로 제한
        #expect(metrics.hourHeight == 10)
        // displayHourCount = (220 - 25) / 10 = 19
        #expect(metrics.displayHourCount == 19)
    }
}
