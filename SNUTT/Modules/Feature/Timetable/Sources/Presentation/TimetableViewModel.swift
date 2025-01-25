//
//  TimetableViewModel.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import Combine
import Dependencies
import DependenciesAdditions
import Observation
import SharedUIComponents
import TimetableInterface
import TimetableUIComponents

@Observable
@MainActor
class TimetableViewModel {
    @ObservationIgnored
    @Dependency(\.timetableUseCase) private var timetableUseCase

    @ObservationIgnored
    @Dependency(\.timetableRepository) private var timetableRepository

    var currentTimetable: (any Timetable)?
    var selectedLecture: (any Lecture)?
    private(set) var metadataLoadState: MetadataLoadState = .loading

    var paths = [TimetableDetailSceneTypes]()
    var isMenuPresented = false

    private(set) var configuration: TimetableConfiguration = .init()

    var totalCredit: Int {
        let credit = currentTimetable?.lectures.reduce(0) { $0 + ($1.credit ?? 0) } ?? 0
        return Int(credit)
    }

    var timetableTitle: String {
        currentTimetable?.title ?? ""
    }

    func makePainter(selectedLecture: (any Lecture)? = nil) -> TimetablePainter {
        TimetablePainter(
            currentTimetable: currentTimetable,
            selectedLecture: selectedLecture,
            selectedTheme: currentTimetable?.defaultTheme ?? .snutt,
            configuration: configuration
        )
    }

    func loadTimetable() async throws {
        currentTimetable = try await timetableUseCase.loadRecentTimetable()
    }

    func loadTimetableList() async throws {
        let metadataList = try await timetableRepository.fetchTimetableMetadataList()
        metadataLoadState = .loaded(metadataList)
    }

    func selectTimetable(timetableID: String) async throws {
        currentTimetable = try await timetableUseCase.selectTimetable(timetableID: timetableID)
    }

    func copyTimetable(timetableID: String) async throws {
        let metadataList = try await timetableRepository.copyTimetable(timetableID: timetableID)
        metadataLoadState = .loaded(metadataList)
    }

    func deleteTimetable(timetableID: String) async throws {
        let metadataList = try await timetableRepository.deleteTimetable(timetableID: timetableID)
        metadataLoadState = .loaded(metadataList)
    }

    func setPrimaryTimetable(timetableID: String) async throws {
        try await timetableRepository.setPrimaryTimetable(timetableID: timetableID)
        try await loadTimetableList()
    }

    func unsetPrimaryTimetable(timetableID: String) async throws {
        try await timetableRepository.unsetPrimaryTimetable(timetableID: timetableID)
        try await loadTimetableList()
    }

    func renameTimetable(timetableID: String, title: String) async throws {
        let metadataList = try await timetableRepository.updateTimetableTitle(timetableID: timetableID, title: title)
        metadataLoadState = .loaded(metadataList)
    }
}

extension TimetableViewModel {
    enum MetadataLoadState {
        case loading
        case loaded([any TimetableMetadata])
    }
}

enum TimetableDetailSceneTypes: Hashable, Equatable {
    case lectureList
    case notificationList
    case lectureDetail(any Lecture)

    static func == (lhs: TimetableDetailSceneTypes, rhs: TimetableDetailSceneTypes) -> Bool {
        switch (lhs, rhs) {
        case (.lectureList, .lectureList):
            true
        case (.notificationList, .notificationList):
            true
        case let (.lectureDetail(lhs), .lectureDetail(rhs)):
            lhs.id == rhs.id
        default:
            false
        }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self)
    }
}
