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

    var currentTimetable: (any Timetable)? {
        timetableViewModel.currentTimetable
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
}

extension TimetableMenuViewModel {
    struct TimetableGroup: Identifiable {
        var id: String { quarter.id }
        let quarter: Quarter
        let metadataList: [any TimetableMetadata]
    }
}
