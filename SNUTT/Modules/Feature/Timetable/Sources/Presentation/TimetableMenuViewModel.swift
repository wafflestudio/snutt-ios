//
//  TimetableMenuViewModel.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import Dependencies
import TimetableInterface

@MainActor
struct TimetableMenuViewModel {
    private let timetableViewModel: TimetableViewModel

    init(timetableViewModel: TimetableViewModel) {
        self.timetableViewModel = timetableViewModel
    }

    var metadataLoadingState: TimetableViewModel.MetadataLoadState {
        timetableViewModel.metadataLoadState
    }

    var currentTimetable: Timetable? {
        timetableViewModel.currentTimetable
    }

    func presentThemeSheet() {
        timetableViewModel.isThemeSheetPresented = true
    }

    var groupedTimetables: [TimetableGroup] {
        switch metadataLoadingState {
        case .loading:
            return []
        case let .loaded(metadataList):
            let dict = Dictionary(grouping: metadataList, by: { $0.quarter })
            var groups = [TimetableGroup]()
            for (quarter, items) in dict {
                groups.append(TimetableGroup(quarter: quarter, metadataList: items))
            }
            return groups.sorted { $0.quarter > $1.quarter }
        }
    }

    func selectTimetable(timetableID: String) async throws {
        try await timetableViewModel.selectTimetable(timetableID: timetableID)
    }

    func copyTimetable(timetableID: String) async throws {
        try await timetableViewModel.copyTimetable(timetableID: timetableID)
    }

    func deleteTimetable(timetableID: String) async throws {
        try await timetableViewModel.deleteTimetable(timetableID: timetableID)
    }

    func setPrimaryTimetable(timetableID: String) async throws {
        try await timetableViewModel.setPrimaryTimetable(timetableID: timetableID)
    }

    func unsetPrimaryTimetable(timetableID: String) async throws {
        try await timetableViewModel.unsetPrimaryTimetable(timetableID: timetableID)
    }

    func renameTimetable(timetableID: String, title: String) async throws {
        try await timetableViewModel.renameTimetable(timetableID: timetableID, title: title)
    }
}

extension TimetableMenuViewModel {
    struct TimetableGroup: Identifiable {
        var id: String { quarter.id }
        let quarter: Quarter
        let metadataList: [TimetableMetadata]
    }
}
