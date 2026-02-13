//
//  LectureEditDetailViewModel.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Dependencies
import Foundation
import FoundationUtility
import Observation
import SharedUIComponents
import SwiftUI
import TimetableInterface
import VacancyInterface

@MainActor
@Observable
public final class LectureEditDetailViewModel {
    @ObservationIgnored
    @Dependency(\.lectureRepository) private var lectureRepository

    @ObservationIgnored
    @Dependency(\.timetableRepository) private var timetableRepository

    @ObservationIgnored
    @Dependency(\.vacancyRepository) private var vacancyRepository

    @ObservationIgnored
    @Dependency(\.courseBookRepository) private var courseBookRepository

    @ObservationIgnored
    @Dependency(\.lectureReminderRepository) private var lectureReminderRepository

    @ObservationIgnored
    @Dependency(\.semesterRepository) private var semesterRepository

    @ObservationIgnored
    @Dependency(\.analyticsLogger) private var analyticsLogger

    let displayMode: DisplayMode
    private let parentTimetable: Timetable?
    private let quarter: Quarter

    var entryLecture: Lecture
    var editableLecture: Lecture

    var buildings: [Building] = []

    private(set) var isBookmarked = false
    private(set) var isVacancyNotificationEnabled = false
    private(set) var reminderViewModel: LectureReminderViewModel?
    nonisolated let lectureID: String

    var showMapView: Bool {
        !buildings.isEmpty && isGwanak
    }

    var showMapMismatchWarning: Bool {
        !entryLecture.timePlaces.map { $0.place }.allSatisfy { place in
            buildings.contains { place.hasPrefix($0.number) }
        }
    }

    private var isGwanak: Bool {
        buildings.allSatisfy { $0.campus == .GWANAK }
    }

    init(displayMode: DisplayMode, entryLecture: Lecture) {
        self.displayMode = displayMode

        // Extract timetable and quarter from displayMode
        switch displayMode {
        case .normal(let timetable), .create(let timetable):
            self.parentTimetable = timetable
            self.quarter = timetable.quarter
        case .preview(_, let quarter):
            self.parentTimetable = nil
            self.quarter = quarter
        }

        self.entryLecture = entryLecture
        editableLecture = entryLecture
        lectureID = entryLecture.id
    }

    func initialLoad() async throws {
        async let bookmarkTask: Void = fetchBookmarkStatus()
        async let vacancyTask: Void = fetchVacancyNotificationStatus()
        async let reminderTask: Void = initializeReminderViewModelIfNeeded()
        _ = try await (bookmarkTask, vacancyTask, reminderTask)
    }

    func fetchBuildingList() async {
        let lecturePlaces = entryLecture.timePlaces.map { $0.place }
        buildings = (try? await lectureRepository.fetchBuildingList(places: lecturePlaces)) ?? []
    }

    func saveEditableLecture(overrideOnConflict: Bool = false) async throws {
        guard let timetableID = parentTimetable?.id else { return }
        let lectureID = editableLecture.id
        do {
            let timetable = try await lectureRepository.updateLecture(
                timetableID: timetableID,
                lecture: editableLecture,
                overrideOnConflict: overrideOnConflict
            )
            guard let updatedLecture = timetable.lectures.first(where: { $0.id == lectureID }) else { return }
            entryLecture = updatedLecture
        } catch {
            throw error
        }
    }

    func addCustomLecture(overrideOnConflict: Bool = false) async throws {
        guard let timetableID = parentTimetable?.id else { return }
        do {
            _ = try await lectureRepository.addCustomLecture(
                timetableID: timetableID,
                lecture: editableLecture,
                overrideOnConflict: overrideOnConflict
            )
        } catch {
            throw error
        }
    }

    func addTimePlace() {
        let newTimePlace = TimePlace(
            id: UUID().uuidString,
            day: .mon,
            startTime: Time(hour: 9, minute: 0),
            endTime: Time(hour: 10, minute: 0),
            place: "",
            isCustom: editableLecture.isCustom
        )
        editableLecture.timePlaces.append(newTimePlace)
    }

    func removeTimePlace(at index: Int) {
        guard index < editableLecture.timePlaces.count else { return }
        editableLecture.timePlaces.remove(at: index)
    }

    var canRemoveTimePlace: Bool {
        !editableLecture.timePlaces.isEmpty
    }

    var hasUnsavedChanges: Bool {
        editableLecture != entryLecture
    }

    func cancelEdit() {
        editableLecture = entryLecture
    }

    func deleteLecture() async throws {
        guard let timetableID = parentTimetable?.id else { return }
        _ = try await timetableRepository.removeLecture(
            timetableID: timetableID,
            lectureID: entryLecture.id
        )
    }

    func resetLecture() async throws {
        guard let timetableID = parentTimetable?.id,
            !entryLecture.isCustom
        else { return }

        let timetable = try await lectureRepository.resetLecture(
            timetableID: timetableID,
            lectureID: entryLecture.id
        )

        guard let resetLecture = timetable.lectures.first(where: { $0.id == entryLecture.id }) else { return }
        entryLecture = resetLecture
        editableLecture = resetLecture
    }

    private func fetchBookmarkStatus() async {
        guard !entryLecture.isCustom else { return }
        isBookmarked = (try? await lectureRepository.isBookmarked(lectureID: entryLecture.referenceID)) ?? false
    }

    private func fetchVacancyNotificationStatus() async {
        guard !entryLecture.isCustom else { return }
        isVacancyNotificationEnabled =
            (try? await vacancyRepository
                .isVacancyNotificationEnabled(lectureID: entryLecture.referenceID)) ?? false
    }

    func toggleBookmark() async throws {
        guard !entryLecture.isCustom else { return }
        if isBookmarked {
            try await lectureRepository.removeBookmark(lectureID: entryLecture.referenceID)
        } else {
            analyticsLogger.logEvent(
                AnalyticsAction.addToBookmark(
                    .init(
                        lectureID: entryLecture.referenceID,
                        referrer: .lectureDetail
                    )
                )
            )
            try await lectureRepository.addBookmark(lectureID: entryLecture.referenceID)
        }
        isBookmarked.toggle()
    }

    func toggleVacancyNotification() async throws {
        guard !entryLecture.isCustom else { return }
        if isVacancyNotificationEnabled {
            try await vacancyRepository.deleteVacancyLecture(lectureID: entryLecture.referenceID)
        } else {
            analyticsLogger.logEvent(
                AnalyticsAction.addToVacancy(
                    .init(
                        lectureID: entryLecture.referenceID,
                        referrer: .lectureDetail
                    )
                )
            )
            try await vacancyRepository.addVacancyLecture(lectureID: entryLecture.referenceID)
        }
        isVacancyNotificationEnabled.toggle()
    }

    func fetchSyllabusURL() async -> URL? {
        guard !entryLecture.isCustom else { return nil }

        let year = quarter.year
        let semester = quarter.semester.rawValue

        do {
            let syllabus = try await courseBookRepository.fetchSyllabusURL(
                year: year,
                semester: semester,
                lecture: entryLecture
            )
            return URL(string: syllabus.url)
        } catch {
            return nil
        }
    }

    // MARK: - Lecture Reminder

    private func initializeReminderViewModelIfNeeded() async throws {
        let semesterStatus = try await semesterRepository.fetchSemesterStatus()
        guard let timetableID = parentTimetable?.id, shouldShowReminderPicker(semesterStatus: semesterStatus)
        else { return }
        let reminderOption = try await lectureReminderRepository.getReminder(
            timetableID: timetableID,
            lectureID: entryLecture.id
        )
        let lectureReminder = LectureReminder(
            timetableLectureID: entryLecture.id,
            lectureTitle: entryLecture.courseTitle,
            option: reminderOption
        )
        reminderViewModel = LectureReminderViewModel(
            lectureReminder: lectureReminder,
            timetableID: timetableID
        )
    }

    private func shouldShowReminderPicker(semesterStatus: SemesterStatus) -> Bool {
        // Must be in normal display mode (not preview or create)
        guard displayMode.isNormal else { return false }

        // Must have time information
        guard !entryLecture.timePlaces.isEmpty else { return false }

        // Must be the current or next semester's primary timetable
        guard let timetable = parentTimetable,
            timetable.isPrimary
        else { return false }

        let targetSemester = semesterStatus.currentOrNext
        return timetable.quarter.year == targetSemester.year
            && timetable.quarter.semester == targetSemester.semester
    }
}

extension LectureEditDetailViewModel {
    public enum DisplayMode {
        /// 내가 추가한 강의 상세
        case normal(timetable: Timetable)
        /// 새로운 강의 추가
        case create(timetable: Timetable)
        /// 내가 추가하지 않은 강의 상세 (검색 결과, 북마크 등)
        case preview(LectureDetailPreviewOptions, quarter: Quarter)

        public var isPreview: Bool {
            if case .preview = self {
                return true
            }
            return false
        }

        public var isCreate: Bool {
            if case .create = self {
                return true
            }
            return false
        }

        public var isNormal: Bool {
            if case .normal = self {
                return true
            }
            return false
        }

        public var previewOptions: LectureDetailPreviewOptions? {
            if case let .preview(options, _) = self {
                return options
            }
            return nil
        }

        public var timetable: Timetable? {
            switch self {
            case .normal(let timetable), .create(let timetable):
                return timetable
            case .preview:
                return nil
            }
        }

        public var quarter: Quarter {
            switch self {
            case .normal(let timetable), .create(let timetable):
                return timetable.quarter
            case .preview(_, let quarter):
                return quarter
            }
        }
    }
}

extension Lecture {
    var quotaDescription: String? {
        get {
            if let quota, let freshmenQuota {
                return "\(quota)(\(freshmenQuota))"
            }
            return nil
        }
        set {}
    }
}
