//
//  TimeSelectionSheetViewModel.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Foundation
import Observation
import SwiftUI
import TimetableInterface
import TimetableUIComponents

@Observable
@MainActor
class TimeSelectionSheetViewModel {
    var selectedTimeRanges: [SearchTimeRange]

    init(initialRanges: [SearchTimeRange] = []) {
        self.selectedTimeRanges = initialRanges
    }

    func addTimeRange(_ range: SearchTimeRange) {
        if !selectedTimeRanges.contains(range) {
            selectedTimeRanges.append(range)
            mergeAdjacentRanges()
        }
    }

    func removeTimeRange(_ range: SearchTimeRange) {
        // Find ranges that overlap with the range to remove
        var newRanges: [SearchTimeRange] = []

        for existingRange in selectedTimeRanges {
            // Same day check
            if existingRange.day != range.day {
                newRanges.append(existingRange)
                continue
            }

            // No overlap
            if existingRange.endMinute <= range.startMinute || existingRange.startMinute >= range.endMinute {
                newRanges.append(existingRange)
                continue
            }

            // Complete overlap - remove entirely
            if existingRange.startMinute >= range.startMinute && existingRange.endMinute <= range.endMinute {
                continue
            }

            // Partial overlap - split if needed
            if existingRange.startMinute < range.startMinute {
                // Keep the part before
                newRanges.append(
                    SearchTimeRange(
                        day: existingRange.day,
                        startMinute: existingRange.startMinute,
                        endMinute: range.startMinute
                    )
                )
            }

            if existingRange.endMinute > range.endMinute {
                // Keep the part after
                newRanges.append(
                    SearchTimeRange(
                        day: existingRange.day,
                        startMinute: range.endMinute,
                        endMinute: existingRange.endMinute
                    )
                )
            }
        }

        selectedTimeRanges = newRanges
    }

    func confirmSelection() -> [SearchTimeRange] {
        selectedTimeRanges
    }

    func clear() {
        selectedTimeRanges = []
    }

    func selectEmptyTimeSlots(from timetable: Timetable?) {
        // Generate all possible 30-minute time slots
        let allSlots = generateAllTimeSlots()

        // Get occupied time slots from the timetable
        let occupiedSlots = timetable?.occupiedTimeRanges ?? []

        // Calculate empty slots: all slots - occupied slots
        let emptySlots = allSlots.filter { slot in
            !occupiedSlots.contains { occupied in
                slot.day == occupied.day
                    && slot.startMinute < occupied.endMinute
                    && slot.endMinute > occupied.startMinute
            }
        }

        // Replace current selections with empty slots
        selectedTimeRanges = emptySlots
        mergeAdjacentRanges()
    }

    // MARK: - Coordinate Conversion

    func convertLocationToTimeRange(
        location: CGPoint,
        containerSize: CGSize,
        painter: TimetablePainter
    ) -> SearchTimeRange? {
        // Constants matching TimetablePainter
        let hourWidth: CGFloat = 20
        let weekdayHeight: CGFloat = 25

        // Adjust for margins
        let adjustedX = location.x - hourWidth
        let adjustedY = location.y - weekdayHeight

        // Validate bounds
        guard adjustedX >= 0, adjustedY >= 0 else { return nil }

        // Get configuration values
        let config = painter.configuration
        let visibleWeeks = config.visibleWeeks
        let weekCount = visibleWeeks.count
        let startingHour = config.minHour
        let endingHour = config.maxHour
        let hourCount = endingHour - startingHour + 1

        // Calculate day index
        let weekWidth = max((containerSize.width - hourWidth) / CGFloat(weekCount), 0)
        guard weekWidth > 0 else { return nil }

        let weekIndex = Int(adjustedX / weekWidth)
        guard weekIndex >= 0, weekIndex < visibleWeeks.count else { return nil }
        let weekday = visibleWeeks[weekIndex]

        // Calculate time
        let hourHeight = max((containerSize.height - weekdayHeight) / CGFloat(hourCount), 0)
        guard hourHeight > 0 else { return nil }

        let hourOffset = adjustedY / hourHeight
        let absoluteMinute = Int((hourOffset + Double(startingHour)) * 60)

        // Snap to 30-minute intervals
        let snappedMinute = (absoluteMinute / 30) * 30

        // Validate time bounds
        let minMinute = startingHour * 60
        let maxMinute = (endingHour + 1) * 60
        guard snappedMinute >= minMinute, snappedMinute < maxMinute else { return nil }

        let endMinute = min(snappedMinute + 30, maxMinute)

        return SearchTimeRange(
            day: weekday.rawValue,
            startMinute: snappedMinute,
            endMinute: endMinute
        )
    }

    func isRangeSelected(_ range: SearchTimeRange) -> Bool {
        // Check if this range is contained within any selected range
        for selectedRange in selectedTimeRanges {
            if selectedRange.day == range.day,
                selectedRange.startMinute <= range.startMinute,
                selectedRange.endMinute >= range.endMinute
            {
                return true
            }
        }
        return false
    }

    func fillBetweenRanges(from: SearchTimeRange, to: SearchTimeRange) -> [SearchTimeRange] {
        // Same day - fill time range
        guard from.day == to.day else { return [] }

        let minMinute = min(from.startMinute, to.startMinute)
        let maxMinute = max(from.startMinute, to.startMinute)

        var ranges: [SearchTimeRange] = []
        for minute in stride(from: minMinute, through: maxMinute, by: 30) {
            let range = SearchTimeRange(
                day: from.day,
                startMinute: minute,
                endMinute: minute + 30
            )
            ranges.append(range)
        }
        return ranges
    }

    // MARK: - Private Methods

    private func mergeAdjacentRanges() {
        // Group by day
        let grouped = Dictionary(grouping: selectedTimeRanges, by: { $0.day })

        var merged: [SearchTimeRange] = []

        for (day, ranges) in grouped {
            // Sort by start time
            let sorted = ranges.sorted { $0.startMinute < $1.startMinute }

            guard !sorted.isEmpty else { continue }

            var current = sorted[0]

            for i in 1..<sorted.count {
                let next = sorted[i]

                // Check if ranges are adjacent or overlapping
                if current.endMinute >= next.startMinute {
                    // Merge
                    current = SearchTimeRange(
                        day: day,
                        startMinute: current.startMinute,
                        endMinute: max(current.endMinute, next.endMinute)
                    )
                } else {
                    // Save current and move to next
                    merged.append(current)
                    current = next
                }
            }

            // Don't forget the last one
            merged.append(current)
        }

        // Sort by day, then by start time
        selectedTimeRanges = merged.sorted { lhs, rhs in
            if lhs.day != rhs.day {
                return lhs.day < rhs.day
            }
            return lhs.startMinute < rhs.startMinute
        }
    }

    private func generateAllTimeSlots() -> [SearchTimeRange] {
        let minHour = 8
        let maxHour = 21
        let weekdays = [0, 1, 2, 3, 4]  // Mon-Fri

        var slots: [SearchTimeRange] = []

        for day in weekdays {
            // Generate 30-minute slots from 8 AM to 9 PM
            for minute in stride(from: minHour * 60, to: maxHour * 60, by: 30) {
                slots.append(
                    SearchTimeRange(
                        day: day,
                        startMinute: minute,
                        endMinute: minute + 30
                    )
                )
            }
        }

        return slots
    }
}

extension Timetable {
    /// Extracts all occupied time ranges from lectures in the timetable
    var occupiedTimeRanges: [SearchTimeRange] {
        lectures
            .flatMap { $0.timePlaces }
            .map {
                SearchTimeRange(
                    day: $0.day.rawValue,
                    startMinute: $0.startTime.absoluteMinutes,
                    endMinute: $0.endTime.absoluteMinutes
                )
            }
    }
}
