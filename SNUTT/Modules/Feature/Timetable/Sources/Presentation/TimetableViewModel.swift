//
//  TimetableViewModel.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import Combine
import Dependencies
import DependenciesAdditions
import SharedUIComponents
import TimetableInterface
import Observation
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

enum TimetableDetailSceneTypes {
    case lectureList
}

extension TimetableViewModel: TimetablePainter {}
