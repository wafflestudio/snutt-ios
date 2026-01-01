//
//  TimeSelectionSheet.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SwiftUI
import SwiftUIUtility
import ThemesInterface
import TimetableInterface
import TimetableUIComponents

struct TimeSelectionSheet: View {
    @State private var sheetViewModel: TimeSelectionSheetViewModel
    let currentTimetable: Timetable?
    let onConfirm: ([SearchTimeRange]) -> Void

    @Environment(\.dismiss) private var dismiss

    private var painter: TimetablePainter {
        var config = TimetableConfiguration()
        config.visibleWeeks = [.mon, .tue, .wed, .thu, .fri]
        config.autoFit = false
        config.compactMode = true
        config.visibilityOptions = []
        config.minHour = 8
        config.maxHour = 20
        return TimetablePainter(
            currentTimetable: currentTimetable,
            selectedLecture: nil,
            preferredTheme: .timetablePreview,
            availableThemes: [],
            configuration: config
        )
    }

    init(
        currentTimetable: Timetable?,
        initialRanges: [SearchTimeRange] = [],
        onConfirm: @escaping ([SearchTimeRange]) -> Void
    ) {
        self.currentTimetable = currentTimetable
        self._sheetViewModel = State(initialValue: TimeSelectionSheetViewModel(initialRanges: initialRanges))
        self.onConfirm = onConfirm
    }

    var body: some View {
        NavigationStack {
            interactiveTimetableView
                .padding()
                .navigationTitle(TimetableStrings.searchTimeSelectionTitle)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(TimetableStrings.searchTimeSelectionCancel) {
                            dismiss()
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button(TimetableStrings.searchTimeSelectionDone) {
                            onConfirm(sheetViewModel.confirmSelection())
                            dismiss()
                        }
                    }
                    ToolbarItemGroup(placement: .bottomBar) {
                        Button(TimetableStrings.searchTimeSelectionSelectEmptySlots) {
                            sheetViewModel.selectEmptyTimeSlots(from: currentTimetable)
                        }
                        Button(TimetableStrings.searchTimeSelectionReset, role: .destructive) {
                            sheetViewModel.clear()
                        }
                        .disabled(sheetViewModel.selectedTimeRanges.isEmpty)
                        .tint(Color(.systemRed))
                    }
                }
                .interactiveDismissDisabled()
        }
    }

    private var interactiveTimetableView: some View {
        ZStack {
            GeometryReader { reader in
                let geometry = TimetableGeometry(reader)
                TimetableGridLayer(painter: painter, geometry: geometry)
                TimetableBlocksLayer(painter: painter, geometry: geometry).opacity(0.1)
                TimeSelectionOverlay(painter: painter, viewModel: sheetViewModel)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color(UIColor.quaternaryLabel), lineWidth: 1)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 3)
        )
    }
}

extension Theme {
    fileprivate static let timetablePreview = Theme(
        id: "preview",
        name: "preview",
        colors: [LectureColor(fgHex: "#FFFFFF", bgHex: "#000000")],
        status: .builtIn
    )
}

#Preview("Empty State") {
    TimeSelectionSheet(
        currentTimetable: PreviewHelpers.preview,
        initialRanges: []
    ) { _ in }
}
