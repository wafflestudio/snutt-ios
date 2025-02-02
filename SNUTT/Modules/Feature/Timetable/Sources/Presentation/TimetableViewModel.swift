//
//  TimetableViewModel.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import APIClientInterface
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

    private(set) var currentTimetable: (any Timetable)?
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
        guard case let .loaded(metadataList) = metadataLoadState,
              let originalIndex = metadataList.firstIndex(where: { $0.id == timetableID })
        else { throw LocalizedErrorCode.timetableNotFound }
        let newMetadataList = try await timetableRepository.deleteTimetable(timetableID: timetableID)
        metadataLoadState = .loaded(newMetadataList)
        if timetableID == currentTimetable?.id {
            let nextIndex = min(originalIndex, newMetadataList.count - 1)
            try await selectTimetable(timetableID: newMetadataList[nextIndex].id)
        }
    }

    func setPrimaryTimetable(timetableID: String) async throws {
        try await timetableRepository.setPrimaryTimetable(timetableID: timetableID)
        try await loadTimetableList()
    }

    func unsetPrimaryTimetable(timetableID: String) async throws {
        try await timetableRepository.unsetPrimaryTimetable(timetableID: timetableID)
        try await loadTimetableList()
    }

    func isLectureInCurrentTimetable(lecture: any Lecture) -> Bool {
        if let timetableLectureID = lecture.lectureID {
            currentTimetable?.lectures.contains(where: { $0.lectureID == timetableLectureID }) ?? false
        } else {
            currentTimetable?.lectures.contains(where: { $0.lectureID == lecture.id }) ?? false
        }
    }

    func addLecture(lecture: any Lecture) async throws {
        guard let currentTimetable else { return }
        self.currentTimetable = try await timetableUseCase.addLecture(
            timetableID: currentTimetable.id,
            lectureID: lecture.id
        )
    }

    func removeLecture(lecture: any Lecture) async throws {
        guard let currentTimetable,
              let timetableLectureID = currentTimetable.lectures
              .first(where: { $0.lectureID == (lecture.lectureID ?? lecture.id) })?.id
        else { return }
        self.currentTimetable = try await timetableUseCase.removeLecture(
            timetableID: currentTimetable.id,
            lectureID: timetableLectureID
        )
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
