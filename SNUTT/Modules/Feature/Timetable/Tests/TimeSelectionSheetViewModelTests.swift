//
//  TimeSelectionSheetViewModelTests.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Foundation
import SwiftUI
import Testing
import TimetableInterface
import TimetableUIComponents

@testable import Timetable

@MainActor
@Suite
struct TimeSelectionSheetViewModelTests {
    // MARK: - Coordinate Conversion Tests

    @Test func coordinateConversionReturnsValidRange() {
        let viewModel = TimeSelectionSheetViewModel()
        let painter = createTestPainter()
        let containerSize = CGSize(width: 400, height: 600)

        // Touch at first day, first hour
        let location = CGPoint(x: 50, y: 50)
        let range = viewModel.convertLocationToTimeRange(
            location: location,
            containerSize: containerSize,
            painter: painter
        )

        #expect(range != nil)
        #expect(range?.day == 0)  // Monday
    }

    @Test func coordinateConversionSnapsTo30Minutes() {
        let viewModel = TimeSelectionSheetViewModel()
        let painter = createTestPainter()
        let containerSize = CGSize(width: 400, height: 600)

        // Touch somewhere in the middle
        let location = CGPoint(x: 100, y: 100)
        let range = viewModel.convertLocationToTimeRange(
            location: location,
            containerSize: containerSize,
            painter: painter
        )

        #expect(range != nil)
        #expect(range!.startMinute % 30 == 0)
        #expect(range!.endMinute % 30 == 0)
        #expect(range!.endMinute - range!.startMinute == 30)
    }

    @Test func coordinateConversionReturnsNilForOutOfBounds() {
        let viewModel = TimeSelectionSheetViewModel()
        let painter = createTestPainter()
        let containerSize = CGSize(width: 400, height: 600)

        // Touch outside bounds (negative coordinates after adjustment)
        let location = CGPoint(x: 5, y: 5)
        let range = viewModel.convertLocationToTimeRange(
            location: location,
            containerSize: containerSize,
            painter: painter
        )

        #expect(range == nil)
    }

    // MARK: - Range Selection Tests

    @Test func isRangeSelectedReturnsTrueForSelectedRange() {
        let viewModel = TimeSelectionSheetViewModel()
        let range = SearchTimeRange(day: 0, startMinute: 540, endMinute: 570)  // Mon 9:00-9:30

        viewModel.addTimeRange(range)

        #expect(viewModel.isRangeSelected(range))
    }

    @Test func isRangeSelectedReturnsFalseForUnselectedRange() {
        let viewModel = TimeSelectionSheetViewModel()
        let range = SearchTimeRange(day: 0, startMinute: 540, endMinute: 570)

        #expect(!viewModel.isRangeSelected(range))
    }

    @Test func isRangeSelectedDetectsPartialOverlap() {
        let viewModel = TimeSelectionSheetViewModel()
        let largeRange = SearchTimeRange(day: 0, startMinute: 540, endMinute: 600)  // 9:00-10:00
        let smallRange = SearchTimeRange(day: 0, startMinute: 540, endMinute: 570)  // 9:00-9:30

        viewModel.addTimeRange(largeRange)

        #expect(viewModel.isRangeSelected(smallRange))
    }

    // MARK: - Gap Filling Tests

    @Test func fillBetweenRangesCreatesIntermediateRanges() {
        let viewModel = TimeSelectionSheetViewModel()
        let from = SearchTimeRange(day: 0, startMinute: 540, endMinute: 570)  // 9:00-9:30
        let to = SearchTimeRange(day: 0, startMinute: 600, endMinute: 630)  // 10:00-10:30

        let filled = viewModel.fillBetweenRanges(from: from, to: to)

        #expect(filled.count == 3)  // 9:00-9:30, 9:30-10:00, 10:00-10:30
        #expect(filled[0].startMinute == 540)
        #expect(filled[1].startMinute == 570)
        #expect(filled[2].startMinute == 600)
    }

    @Test func fillBetweenRangesReturnsEmptyForDifferentDays() {
        let viewModel = TimeSelectionSheetViewModel()
        let from = SearchTimeRange(day: 0, startMinute: 540, endMinute: 570)  // Mon 9:00-9:30
        let to = SearchTimeRange(day: 1, startMinute: 600, endMinute: 630)  // Tue 10:00-10:30

        let filled = viewModel.fillBetweenRanges(from: from, to: to)

        #expect(filled.isEmpty)
    }

    // MARK: - SearchTimeRange Formatting Tests

    @Test func searchTimeRangeFormattedShowsCorrectDay() {
        let mondayRange = SearchTimeRange(day: 0, startMinute: 540, endMinute: 600)
        let wednesdayRange = SearchTimeRange(day: 2, startMinute: 540, endMinute: 600)

        let mondayFormatted = mondayRange.formatted()
        let wednesdayFormatted = wednesdayRange.formatted()

        #expect(mondayFormatted.contains("Mon"))
        #expect(wednesdayFormatted.contains("Wed"))
    }

    @Test func searchTimeRangeFormattedUses24HourFormat() {
        let morningRange = SearchTimeRange(day: 0, startMinute: 540, endMinute: 600)  // 9:00-10:00
        let formatted = morningRange.formatted()

        // Should contain "9:00" not "9:00 AM"
        #expect(formatted.contains("9:00"))
        #expect(!formatted.contains("AM"))
        #expect(!formatted.contains("PM"))
    }

    // MARK: - Helper Methods

    private func createTestPainter() -> TimetablePainter {
        var config = TimetableConfiguration()
        config.visibleWeeks = [.mon, .tue, .wed, .thu, .fri]
        config.autoFit = false
        config.minHour = 8
        config.maxHour = 20

        return TimetablePainter(
            currentTimetable: nil,
            selectedLecture: nil,
            preferredTheme: nil,
            availableThemes: [],
            configuration: config
        )
    }
}
