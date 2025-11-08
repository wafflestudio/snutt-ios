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
import Foundation
import Observation
import SharedUIComponents
import SwiftUtility
import ThemesInterface
import TimetableInterface
import TimetableUIComponents

@Observable
@MainActor
public class TimetableViewModel: TimetableViewModelProtocol {
    @ObservationIgnored
    @Dependency(\.timetableUseCase) private var timetableUseCase

    @ObservationIgnored
    @Dependency(\.timetableRepository) var timetableRepository

    @ObservationIgnored
    @Dependency(\.timetableLocalRepository) private var timetableLocalRepository

    @ObservationIgnored
    @Dependency(\.courseBookRepository) private var courseBookRepository

    @ObservationIgnored
    @Dependency(\.lectureRepository) var lectureRepository

    @ObservationIgnored
    @Dependency(\.notificationCenter) var notificationCenter

    @ObservationIgnored
    @Dependency(\.analyticsLogger) var analyticsLogger

    var paths: [TimetableDetailSceneTypes] = []

    public init() {
        if let localTimetable = timetableUseCase.loadLocalRecentTimetable() {
            timetableLoadState = .loaded(localTimetable)
        } else {
            timetableLoadState = .loading
        }
        configuration = timetableLocalRepository.loadTimetableConfiguration()
        configurationObserver = Task { [weak self] in
            guard let stream = self?.timetableLocalRepository.configurationValues() else { return }
            for await configuration in stream {
                guard let self else { break }
                self.configuration = configuration
            }
        }
        subscribeToNotifications()
    }

    private(set) var timetableLoadState: TimetableLoadState = .loading
    private(set) var metadataLoadState: MetadataLoadState = .loading
    private(set) var courseBookState: CourseBookState = .loading

    public var currentTimetable: Timetable? {
        if case let .loaded(timetable) = timetableLoadState {
            return timetable
        }
        return nil
    }

    var isMenuPresented = false
    var isThemeSheetPresented = false

    private(set) var configuration: TimetableConfiguration = .init()
    private var configurationObserver: Task<Void, Never>?

    var totalCredit: Int {
        let credit = currentTimetable?.lectures.reduce(0) { $0 + ($1.credit ?? 0) } ?? 0
        return Int(credit)
    }

    var timetableTitle: String {
        currentTimetable?.title ?? ""
    }

    var availableQuarters: [Quarter] {
        switch courseBookState {
        case let .loaded(courseBooks):
            return courseBooks.map { $0.quarter }.sorted { $0 > $1 }
        default:
            return []
        }
    }

    func makePainter(
        selectedLecture: Lecture? = nil,
        selectedTheme: Theme? = nil,
        availableThemes: [Theme] = []
    ) -> TimetablePainter {
        return TimetablePainter(
            currentTimetable: currentTimetable,
            selectedLecture: selectedLecture,
            preferredTheme: selectedTheme,
            availableThemes: availableThemes,
            configuration: configuration
        )
    }

    func loadTimetable() async throws {
        switch timetableLoadState {
        case let .loaded(currentTimetable):
            // Already loaded, refresh the current timetable
            try await selectTimetable(timetableID: currentTimetable.id)
        case .loading, .failed:
            // Not loaded yet or failed, fetch recent timetable
            do {
                let timetable = try await timetableUseCase.fetchRecentTimetable()
                timetableLoadState = .loaded(timetable)
            } catch {
                timetableLoadState = .failed(error)
                throw error
            }
        }
    }

    public func setCurrentTimetable(_ timetable: Timetable) throws {
        try timetableLocalRepository.storeSelectedTimetable(timetable)
        timetableLoadState = .loaded(timetable)
    }

    func loadTimetableList() async throws {
        switch metadataLoadState {
        case .loaded:
            return
        case .loading, .failed:
            do {
                let metadataList = try await timetableRepository.fetchTimetableMetadataList()
                metadataLoadState = .loaded(metadataList)
            } catch {
                metadataLoadState = .failed(error)
                throw error
            }
        }
    }

    func selectTimetable(timetableID: String) async throws {
        let timetable = try await timetableUseCase.selectTimetable(timetableID: timetableID)
        timetableLoadState = .loaded(timetable)
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

    func isLectureInCurrentTimetable(lecture: Lecture) -> Bool {
        if let timetableLectureID = lecture.lectureID {
            currentTimetable?.lectures.contains(where: { $0.lectureID == timetableLectureID }) ?? false
        } else {
            currentTimetable?.lectures.contains(where: { $0.lectureID == lecture.id }) ?? false
        }
    }

    func addLecture(lecture: Lecture, overrideOnConflict: Bool = false) async throws {
        guard let currentTimetable else { return }
        let updatedTimetable = try await timetableUseCase.addLecture(
            timetableID: currentTimetable.id,
            lectureID: lecture.id,
            overrideOnConflict: overrideOnConflict
        )
        timetableLoadState = .loaded(updatedTimetable)
    }

    func removeLecture(lecture: Lecture) async throws {
        guard let currentTimetable,
            let timetableLectureID = currentTimetable.lectures
                .first(where: { $0.lectureID == (lecture.lectureID ?? lecture.id) })?.id
        else { return }
        let updatedTimetable = try await timetableUseCase.removeLecture(
            timetableID: currentTimetable.id,
            lectureID: timetableLectureID
        )
        timetableLoadState = .loaded(updatedTimetable)
    }

    func renameTimetable(timetableID: String, title: String) async throws {
        let metadataList = try await timetableRepository.updateTimetableTitle(timetableID: timetableID, title: title)
        metadataLoadState = .loaded(metadataList)
    }

    func createTimetable(title: String, quarter: Quarter) async throws {
        let metadataList = try await timetableRepository.createTimetable(title: title, quarter: quarter)
        metadataLoadState = .loaded(metadataList)
    }

    func loadCourseBooks() async throws {
        switch courseBookState {
        case .loading, .failed:
            do {
                let courseBooks = try await courseBookRepository.fetchCourseBookList()
                courseBookState = .loaded(courseBooks)
            } catch {
                courseBookState = .failed
                throw error
            }
        case .loaded:
            return
        }
    }
}

extension TimetableViewModel {
    enum MetadataLoadState {
        case loading
        case loaded([TimetableMetadata])
        case failed(any Error)
    }

    enum CourseBookState: Equatable {
        case loading
        case loaded([CourseBook])
        case failed
    }

    enum TimetableLoadState {
        case loading
        case loaded(Timetable)
        case failed(any Error)
    }
}

public enum TimetableDetailSceneTypes: Hashable {
    case lectureList
    case notificationList
    case lectureDetail(Lecture, parentTimetable: Timetable)
    case lecturePreview(Lecture, quarter: Quarter)
    case lectureCreate(Lecture)
    case lectureColorSelection(LectureEditDetailViewModel)

    public static func == (lhs: TimetableDetailSceneTypes, rhs: TimetableDetailSceneTypes) -> Bool {
        switch (lhs, rhs) {
        case (.lectureList, .lectureList):
            true
        case (.notificationList, .notificationList):
            true
        case let (.lectureCreate(lhs), .lectureCreate(rhs)):
            lhs.id == rhs.id
        case let (.lectureColorSelection(lhs), .lectureColorSelection(rhs)):
            lhs.lectureID == rhs.lectureID
        case let (.lectureDetail(lhs, _), .lectureDetail(rhs, _)):
            lhs.id == rhs.id
        case let (.lecturePreview(lhs, _), .lecturePreview(rhs, _)):
            lhs.id == rhs.id
        default:
            false
        }
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self)
    }
}
