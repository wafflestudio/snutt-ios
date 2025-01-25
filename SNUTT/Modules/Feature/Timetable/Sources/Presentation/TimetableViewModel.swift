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

    func loadTimetable() async {
        do {
            currentTimetable = try await timetableUseCase.loadRecentTimetable()
        } catch {
            print(error)
        }
    }

    func loadTimetableList() async throws {
        let metadataList = try await timetableRepository.fetchTimetableMetadataList()
        metadataLoadState = .loaded(metadataList)
    }

    func selectTimetable(timetableID: String) async throws {
        currentTimetable = try await timetableUseCase.selectTimetable(timetableID: timetableID)
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
