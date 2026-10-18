//
//  TimetableViewModel.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
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
        if case .loaded(let timetable) = timetableLoadState {
            return timetable
        }
        return nil
    }

    var isMenuPresented = false
    var isThemeSheetPresented = false
    var lectureCreateDraft: Lecture?

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
        case .loaded(let courseBooks):
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
        case .loaded(let currentTimetable):
            // Already loaded, refresh the current timetable
            do {
                try await selectTimetable(timetableID: currentTimetable.id)
            } catch {
                // Cached timetable may be stale (e.g. deleted on another device), fall back to recent timetable
                let timetable = try await timetableUseCase.fetchRecentTimetable()
                timetableLoadState = .loaded(timetable)
            }
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

    func refreshTimetableList() async throws {
        let metadataList = try await timetableRepository.fetchTimetableMetadataList()
        metadataLoadState = .loaded(metadataList)
    }

    func selectTimetable(timetableID: TimetableID) async throws {
        let timetable = try await timetableUseCase.selectTimetable(timetableID: timetableID)
        timetableLoadState = .loaded(timetable)
    }

    func copyTimetable(timetableID: TimetableID) async throws {
        let metadataList = try await timetableRepository.copyTimetable(timetableID: timetableID)
        metadataLoadState = .loaded(metadataList)
    }

    func deleteTimetable(timetableID: TimetableID) async throws {
        guard case .loaded(let metadataList) = metadataLoadState,
            let originalIndex = metadataList.firstIndex(where: { $0.id == timetableID })
        else { throw LocalizedErrorCode.timetableNotFound }
        let newMetadataList = try await timetableRepository.deleteTimetable(timetableID: timetableID)
        metadataLoadState = .loaded(newMetadataList)
        if timetableID == currentTimetable?.id {
            let nextIndex = min(originalIndex, newMetadataList.count - 1)
            try await selectTimetable(timetableID: newMetadataList[nextIndex].id)
        }
    }

    func setPrimaryTimetable(timetableID: TimetableID) async throws {
        try await timetableRepository.setPrimaryTimetable(timetableID: timetableID)
        updatePrimaryState(timetableID: timetableID, isPrimary: true)
    }

    func unsetPrimaryTimetable(timetableID: TimetableID) async throws {
        try await timetableRepository.unsetPrimaryTimetable(timetableID: timetableID)
        updatePrimaryState(timetableID: timetableID, isPrimary: false)
    }

    private func updatePrimaryState(timetableID: TimetableID, isPrimary: Bool) {
        guard case .loaded(let metadataList) = metadataLoadState else { return }
        metadataLoadState = .loaded(
            metadataList.map {
                var metadata = $0
                metadata.isPrimary = isPrimary && metadata.id == timetableID
                return metadata
            }
        )
    }

    func isLectureInCurrentTimetable(lecture: Lecture) -> Bool {
        currentTimetable?.lectures.contains(where: { $0.id == lecture.id }) ?? false
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
                .first(where: { $0.id == lecture.id })?.timetableLectureID
        else { return }
        let updatedTimetable = try await timetableUseCase.removeLecture(
            timetableID: currentTimetable.id,
            lectureID: timetableLectureID
        )
        timetableLoadState = .loaded(updatedTimetable)
    }

    func presentLectureCreateScene() {
        lectureCreateDraft = makeLectureCreatePlaceholder()
    }

    private func makeLectureCreatePlaceholder() -> Lecture {
        let mondayMorningTimePlace = TimePlace(
            id: UUID().uuidString,
            day: .mon,
            startTime: .init(hour: 9, minute: 0),
            endTime: .init(hour: 10, minute: 0),
            place: "",
            isCustom: true
        )

        return Lecture(
            id: LectureID(rawValue: UUID().uuidString),
            timetableLectureID: nil,
            courseTitle: "새로운 강의",
            timePlaces: [mondayMorningTimePlace],
            lectureNumber: nil,
            instructor: nil,
            credit: nil,
            courseNumber: nil,
            department: nil,
            academicYear: nil,
            remark: nil,
            evLecture: nil,
            colorIndex: 1,
            customColor: nil,
            classification: nil,
            category: nil,
            wasFull: false,
            registrationCount: 0,
            quota: nil,
            freshmenQuota: nil,
            categoryPre2025: nil
        )
    }

    func renameTimetable(timetableID: TimetableID, title: String) async throws {
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
    case vacancyList
    case notificationList
    case lectureDetail(Lecture, parentTimetable: Timetable)
    case lecturePreview(Lecture, quarter: Quarter)
    case lectureCreate(Lecture)
    case lectureColorSelection(LectureEditDetailViewModel)
    #if FEATURE_LECTURE_DIARY
    case lectureDiaryList
    #endif

    public static func == (lhs: TimetableDetailSceneTypes, rhs: TimetableDetailSceneTypes) -> Bool {
        switch (lhs, rhs) {
        case (.lectureList, .lectureList):
            true
        case (.vacancyList, .vacancyList):
            true
        case (.notificationList, .notificationList):
            true
        case (.lectureCreate(let lhs), .lectureCreate(let rhs)):
            lhs.id == rhs.id
        case (.lectureColorSelection(let lhs), .lectureColorSelection(let rhs)):
            lhs.lectureID == rhs.lectureID
        case (.lectureDetail(let lhs, _), .lectureDetail(let rhs, _)):
            lhs.id == rhs.id
        case (.lecturePreview(let lhs, _), .lecturePreview(let rhs, _)):
            lhs.id == rhs.id
        #if FEATURE_LECTURE_DIARY
        case (.lectureDiaryList, .lectureDiaryList):
            true
        #endif
        default:
            false
        }
    }

    public func hash(into hasher: inout Hasher) {
        switch self {
        case .lectureList:
            hasher.combine(0)
        case .vacancyList:
            hasher.combine(1)
        case .notificationList:
            hasher.combine(2)
        case .lectureDetail(let lecture, _):
            hasher.combine(3)
            hasher.combine(lecture.id)
        case .lecturePreview(let lecture, _):
            hasher.combine(4)
            hasher.combine(lecture.id)
        case .lectureCreate(let lecture):
            hasher.combine(5)
            hasher.combine(lecture.id)
        case .lectureColorSelection(let viewModel):
            hasher.combine(6)
            hasher.combine(viewModel.lectureID)
        #if FEATURE_LECTURE_DIARY
        case .lectureDiaryList:
            hasher.combine(7)
        #endif
        }
    }
}
