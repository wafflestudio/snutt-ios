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
    @Dependency(\.timetableRepository) private var timetableRepository

    @ObservationIgnored
    @Dependency(\.timetableLocalRepository) private var timetableLocalRepository

    @ObservationIgnored
    @Dependency(\.courseBookRepository) private var courseBookRepository

    @ObservationIgnored
    @Dependency(\.notificationCenter) private var notificationCenter

    @ObservationIgnored
    @Dependency(\.analyticsLogger) private var analyticsLogger

    private let router: TimetableRouter = .init()
    var paths: [TimetableDetailSceneTypes] {
        get { router.navigationPaths }
        set { router.navigationPaths = newValue }
    }

    public init() {
        currentTimetable = timetableUseCase.loadLocalRecentTimetable()
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

    private func subscribeToNotifications() {
        Task.scoped(
            to: self,
            subscribing: notificationCenter.messages(of: NavigateToNotificationsMessage.self)
        ) { @MainActor viewModel, _ in
            viewModel.router.navigationPaths = [.notificationList]
        }
        Task.scoped(
            to: self,
            subscribing: notificationCenter.messages(of: NavigateToLectureMessage.self)
        ) { @MainActor viewModel, message in
            await viewModel.handleLectureNavigation(
                timetableID: message.timetableID,
                lectureID: message.lectureID
            )
        }
        Task.scoped(
            to: self,
            subscribing: notificationCenter.messages(of: NavigateToTimetableMessage.self)
        ) { @MainActor viewModel, message in
            do {
                try await viewModel.selectTimetable(timetableID: message.timetableID)
                viewModel.router.navigationPaths = []
            } catch {
                // Handle error silently or log
            }
        }
    }

    private func handleLectureNavigation(timetableID: String, lectureID: String) async {
        do {
            let timetable = try await timetableRepository.fetchTimetable(timetableID: timetableID)
            guard let lecture = timetable.lectures.first(where: { $0.lectureID == lectureID })
            else { return }
            let belongsToOtherTimetable = (timetable.id != currentTimetable?.id)
            self.router.navigationPaths = [
                .notificationList,
                .lectureDetail(lecture, parentTimetable: timetable, belongsToOtherTimetable: belongsToOtherTimetable),
            ]
            self.analyticsLogger.logScreen(
                AnalyticsScreen.lectureDetail(.init(lectureID: lecture.referenceID, referrer: .notification))
            )
        } catch {
            // Handle error silently or log
        }
    }

    public private(set) var currentTimetable: Timetable?
    private(set) var metadataLoadState: MetadataLoadState = .loading
    private(set) var courseBookState: CourseBookState = .loading

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
        currentTimetable = try await timetableUseCase.fetchRecentTimetable()
    }

    public func setCurrentTimetable(_ timetable: Timetable) throws {
        try timetableLocalRepository.storeSelectedTimetable(timetable)
        currentTimetable = timetable
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

    func isLectureInCurrentTimetable(lecture: Lecture) -> Bool {
        if let timetableLectureID = lecture.lectureID {
            currentTimetable?.lectures.contains(where: { $0.lectureID == timetableLectureID }) ?? false
        } else {
            currentTimetable?.lectures.contains(where: { $0.lectureID == lecture.id }) ?? false
        }
    }

    func addLecture(lecture: Lecture, overrideOnConflict: Bool = false) async throws {
        guard let currentTimetable else { return }
        self.currentTimetable = try await timetableUseCase.addLecture(
            timetableID: currentTimetable.id,
            lectureID: lecture.id,
            overrideOnConflict: overrideOnConflict
        )
    }

    func removeLecture(lecture: Lecture) async throws {
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

    func createTimetable(title: String, quarter: Quarter) async throws {
        let metadataList = try await timetableRepository.createTimetable(title: title, quarter: quarter)
        metadataLoadState = .loaded(metadataList)
    }

    func loadCourseBooks() async throws {
        switch courseBookState {
        case .loading:
            let courseBooks = try await courseBookRepository.fetchCourseBookList()
            courseBookState = .loaded(courseBooks)
        case .loaded:
            return
        }
    }
}

extension TimetableViewModel {
    enum MetadataLoadState {
        case loading
        case loaded([TimetableMetadata])
    }

    enum CourseBookState: Equatable {
        case loading
        case loaded([CourseBook])
    }
}

@Observable
@MainActor
public final class TimetableRouter {
    public var navigationPaths: [TimetableDetailSceneTypes] = []
    public nonisolated init() {}
}

public enum TimetableDetailSceneTypes: Hashable {
    case lectureList
    case notificationList
    case lectureDetail(Lecture, parentTimetable: Timetable?, belongsToOtherTimetable: Bool = false)
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
        case let (.lectureDetail(lhs, _, _), .lectureDetail(rhs, _, _)):
            lhs.id == rhs.id
        default:
            false
        }
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self)
    }
}
