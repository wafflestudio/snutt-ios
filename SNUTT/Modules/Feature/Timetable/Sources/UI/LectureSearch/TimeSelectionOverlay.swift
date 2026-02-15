//
//  TimeSelectionOverlay.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import FoundationUtility
import SharedUIComponents
import SwiftUI
import TimetableInterface
import TimetableUIComponents

struct TimeSelectionOverlay: View {
    let painter: TimetablePainter
    @Bindable var viewModel: TimeSelectionSheetViewModel

    @State private var feedbackGenerator = UISelectionFeedbackGenerator()
    @State private var currentDragRange: SearchTimeRange?
    @State private var previousDragRange: SearchTimeRange?
    @State private var dragMode: DragMode = .adding

    private enum DragMode {
        case adding
        case removing
    }

    // Constants matching TimetablePainter
    private let hourWidth: CGFloat = 20
    private let weekdayHeight: CGFloat = 25

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Selection rectangles
                ForEach(viewModel.selectedTimeRanges, id: \.self) { range in
                    if let rect = getRectForTimeRange(range, in: geometry.size) {
                        Rectangle()
                            .fill(SharedUIComponentsAsset.cyan.swiftUIColor.opacity(0.4))
                            .frame(width: rect.width, height: rect.height)
                            .position(x: rect.midX, y: rect.midY)
                    }
                }

                // Invisible touch area
                Color.clear
                    .contentShape(Rectangle())
                    .gesture(dragGesture(in: geometry.size))
            }
        }
    }

    private func dragGesture(in containerSize: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                handleDragChanged(location: value.location, containerSize: containerSize)
            }
            .onEnded { _ in
                currentDragRange = nil
                previousDragRange = nil
            }
    }

    private func handleDragChanged(location: CGPoint, containerSize: CGSize) {
        guard
            let range = viewModel.convertLocationToTimeRange(
                location: location,
                containerSize: containerSize,
                painter: painter
            )
        else {
            return
        }

        // If this is a new drag, determine mode
        if currentDragRange == nil {
            dragMode = viewModel.isRangeSelected(range) ? .removing : .adding
            currentDragRange = range
            previousDragRange = range
            applyDragMode(to: range)
            feedbackGenerator.selectionChanged()
        } else if currentDragRange != range {
            // Fill gaps between previous and current position
            if let previous = previousDragRange {
                let fillRanges = viewModel.fillBetweenRanges(from: previous, to: range)
                for fillRange in fillRanges {
                    applyDragMode(to: fillRange)
                }
            }

            // Update state
            previousDragRange = currentDragRange
            currentDragRange = range
            applyDragMode(to: range)
            feedbackGenerator.selectionChanged()
        }
    }

    private func applyDragMode(to range: SearchTimeRange) {
        switch dragMode {
        case .adding:
            if !viewModel.isRangeSelected(range) {
                viewModel.addTimeRange(range)
            }
        case .removing:
            if viewModel.isRangeSelected(range) {
                viewModel.removeTimeRange(range)
            }
        }
    }

    private func getRectForTimeRange(_ range: SearchTimeRange, in containerSize: CGSize) -> CGRect? {
        // Find the weekday index in visible weeks
        let config = painter.configuration
        let visibleWeeks = config.visibleWeeks
        guard let weekday = Weekday(rawValue: range.day),
            let weekIndex = visibleWeeks.firstIndex(of: weekday)
        else {
            return nil
        }

        // Calculate x position and width
        let weekCount = visibleWeeks.count
        let weekWidth = max((containerSize.width - hourWidth) / CGFloat(weekCount), 0)
        let x = hourWidth + CGFloat(weekIndex) * weekWidth

        // Calculate y position and height
        let startingHour = config.minHour
        let endingHour = config.maxHour
        let hourCount = endingHour - startingHour + 1
        let hourHeight = max((containerSize.height - weekdayHeight) / CGFloat(hourCount), 0)
        let startHourOffset = Double(range.startMinute - startingHour * 60) / 60.0
        let y = weekdayHeight + CGFloat(startHourOffset) * hourHeight

        let durationMinutes = range.endMinute - range.startMinute
        let durationHours = Double(durationMinutes) / 60.0
        let height = CGFloat(durationHours) * hourHeight

        return CGRect(x: x, y: y, width: weekWidth, height: height)
    }
}
