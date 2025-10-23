//
//  TimetableMenuViewModel.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import Dependencies
import Foundation
import Observation
import SwiftUI
import ThemesInterface
import TimetableInterface

@Observable
@MainActor
final class TimetableMenuViewModel {
    @ObservationIgnored
    @Dependency(\.timetableImageRenderer) private var imageRenderer

    @ObservationIgnored
    @Dependency(\.timetableRepository) private var timetableRepository

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

    var availableQuarters: [Quarter] {
        timetableViewModel.availableQuarters
    }

    var configuration: TimetableConfiguration {
        timetableViewModel.configuration
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

            if let latestQuarter = timetableViewModel.availableQuarters.first,
                !groups.contains(where: { $0.quarter == latestQuarter })
            {
                groups.append(TimetableGroup(quarter: latestQuarter, metadataList: []))
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

    func createTimetable(title: String, quarter: Quarter) async throws {
        try await timetableViewModel.createTimetable(title: title, quarter: quarter)
    }

    func createTimetableImage(
        timetable: TimetableMetadata,
        colorScheme: ColorScheme,
        availableThemes: [Theme],
    ) async throws -> TimetableImage {
        let timetable = try await timetableRepository.fetchTimetable(timetableID: timetable.id)
        let data = try await imageRenderer.render(
            timetable: timetable,
            configuration: configuration,
            availableThemes: availableThemes,
            colorScheme: colorScheme
        )
        return TimetableImage(data: data)
    }
}

extension TimetableMenuViewModel {
    struct TimetableGroup: Identifiable {
        var id: String { quarter.id }
        let quarter: Quarter
        let metadataList: [TimetableMetadata]
    }
}

struct TimetableImage: Identifiable, Sendable {
    let id = UUID()
    let data: Data
}
