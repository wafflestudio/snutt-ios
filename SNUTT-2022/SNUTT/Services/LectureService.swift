//
//  LectureService.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/20.
//

import SwiftUI

@MainActor
protocol LectureServiceProtocol: Sendable {
    // Lecture
    func addLecture(lecture: Lecture, isForced: Bool) async throws
    func addCustomLecture(lecture: Lecture, isForced: Bool) async throws
    func updateLecture(oldLecture: Lecture, newLecture: Lecture, isForced: Bool) async throws
    func deleteLecture(lecture: Lecture) async throws
    func resetLecture(lecture: Lecture) async throws
    func getEvLecture(of lecture: Lecture) async throws -> EvLecture?
    func getBuildingList(of lecture: Lecture) async throws -> [Building]
    
    // Lecture Reminder
    func fetchLectureReminderList() async throws
    func getLectureReminderState(timetableId: String, lecture: Lecture) async throws -> LectureReminder
    func changeLectureReminderState(lectureId: String, to option: ReminderOption) async throws
    func getCurrentOrNextSemesterPrimaryTable() -> TimetableMetadata?

    // Bookmark
    func fetchBookmark(quarter: Quarter) async throws -> Bookmark
    func fetchIsFirstBookmark()
    func bookmarkLecture(lecture: Lecture) async throws
    func undoBookmarkLecture(lecture: Lecture) async throws

    // MapView
    func setIsMapViewExpanded(_ open: Bool)
    func shouldExpandLectureMapView() -> Bool
}

extension LectureServiceProtocol {
    func addLecture(lecture: Lecture, isForced: Bool = false) async throws {
        try await addLecture(lecture: lecture, isForced: isForced)
    }

    func addCustomLecture(lecture: Lecture, isForced: Bool = false) async throws {
        try await addCustomLecture(lecture: lecture, isForced: isForced)
    }

    func updateLecture(oldLecture: Lecture, newLecture: Lecture, isForced: Bool = false) async throws {
        try await updateLecture(oldLecture: oldLecture, newLecture: newLecture, isForced: isForced)
    }
}

struct LectureService: LectureServiceProtocol {
    var appState: AppState
    var webRepositories: AppEnvironment.WebRepositories
    var localRepositories: AppEnvironment.LocalRepositories
    
    // MARK: Lecture

    func addLecture(lecture: Lecture, isForced: Bool = false) async throws {
        guard let currentTimetable = appState.timetable.current else { return }
        let dto = try await lectureRepository.addLecture(
            timetableId: currentTimetable.id,
            lectureId: lecture.id,
            isForced: isForced
        )
        let timetable = Timetable(from: dto)
        appState.timetable.current = timetable
        appState.search.selectedLecture = nil
        userDefaultsRepository.set(TimetableDto.self, key: .currentTimetable, value: dto)
    }

    func addCustomLecture(lecture: Lecture, isForced: Bool = false) async throws {
        try checkIfTimeplaceOverlapped(lecture)

        guard let currentTimetable = appState.timetable.current else { return }
        var lectureDto = LectureDto(from: lecture)
        lectureDto.class_time_mask = nil
        let dto = try await lectureRepository.addCustomLecture(
            timetableId: currentTimetable.id,
            lecture: lectureDto,
            isForced: isForced
        )
        let timetable = Timetable(from: dto)
        appState.timetable.current = timetable
        userDefaultsRepository.set(TimetableDto.self, key: .currentTimetable, value: dto)
    }

    func updateLecture(oldLecture: Lecture, newLecture: Lecture, isForced: Bool = false) async throws {
        try checkIfTimeplaceOverlapped(newLecture)

        guard let currentTimetable = appState.timetable.current else { return }
        let dto = try await lectureRepository.updateLecture(
            timetableId: currentTimetable.id,
            oldLecture: .init(from: oldLecture),
            newLecture: .init(from: newLecture),
            isForced: isForced
        )
        let timetable = Timetable(from: dto)
        appState.timetable.current = timetable
        userDefaultsRepository.set(TimetableDto.self, key: .currentTimetable, value: dto)
    }

    func deleteLecture(lecture: Lecture) async throws {
        guard let currentTimetable = appState.timetable.current,
              let timetableLecture = currentTimetable.lectures.first(where: { $0.isEquivalent(with: lecture) })
        else { return }
        let dto = try await lectureRepository.deleteLecture(
            timetableId: currentTimetable.id,
            lectureId: timetableLecture.id
        )
        let timetable = Timetable(from: dto)
        appState.timetable.current = timetable
        userDefaultsRepository.set(TimetableDto.self, key: .currentTimetable, value: dto)
    }

    func resetLecture(lecture: Lecture) async throws {
        guard let currentTimetable = appState.timetable.current else { return }
        let dto = try await lectureRepository.resetLecture(timetableId: currentTimetable.id, lectureId: lecture.id)
        let timetable = Timetable(from: dto)
        appState.timetable.current = timetable
        userDefaultsRepository.set(TimetableDto.self, key: .currentTimetable, value: dto)
    }

    func getEvLecture(of lecture: Lecture) async throws -> EvLecture? {
        let lectureId = lecture.lectureId ?? lecture.id
        let dto = try await reviewRepository.fetchEvLectureInfo(lectureId: lectureId)
        return .init(from: dto)
    }

    func getBuildingList(of lecture: Lecture) async throws -> [Building] {
        let joinedPlaces = lecture.timePlaces.map { $0.place }.joined(separator: ",")
        let dto = try await lectureRepository.getBuildingList(places: joinedPlaces)
        return dto.content.compactMap { Building(from: $0) }
    }
    
    // MARK: Lecture Reminder
    
    func fetchLectureReminderList() async throws {
        guard let targetTable = getCurrentOrNextSemesterPrimaryTable() else { return }
        let dto = try await lectureRepository.fetchLectureReminderList(timetableId: targetTable.id)
        appState.reminder.reminderList = dto.map { LectureReminder(from: $0) }
    }
    
    func getLectureReminderState(timetableId: String, lecture: Lecture) async throws -> LectureReminder {
        let dto = try await lectureRepository.getLectureReminderState(timetableId: timetableId, lectureId: lecture.id)
        return .init(from: dto)
    }
    
    func changeLectureReminderState(lectureId: String, to option: ReminderOption) async throws {
        guard let targetTable = getCurrentOrNextSemesterPrimaryTable() else { return }
        let dto = try await lectureRepository.changeLectureReminderState(timetableId: targetTable.id, lectureId: lectureId, to: option.rawValue)
        appState.reminder.reminderList.removeAll(where: { $0.timetableLectureId == lectureId })
        appState.reminder.reminderList.append(.init(from: dto))
    }
    
    func getCurrentOrNextSemesterPrimaryTable() -> TimetableMetadata? {
        guard let semesterStatus = appState.system.semesterStatus else {
            return nil
        }
        let targetSemester = semesterStatus.current ?? semesterStatus.next
        guard let targetTable = appState.timetable.metadataList?.first(where: {
            $0.isPrimary && $0.year == targetSemester.year && $0.semester == targetSemester.semester
        }) else {
            return nil
        }
        return targetTable
    }
    
    // MARK: Bookmark
    
    func fetchBookmark(quarter: Quarter) async throws -> Bookmark {
        let bookmarkDto = try await lectureRepository.getBookmark(quarter: quarter)
        return .init(from: bookmarkDto)
    }

    func fetchIsFirstBookmark() {
        appState.timetable.isFirstBookmark = userDefaultsRepository.get(
            Bool.self,
            key: .isFirstBookmark,
            defaultValue: true
        )
    }

    func bookmarkLecture(lecture: Lecture) async throws {
        let lectureReferenceId = lecture.lectureId ?? lecture.id
        try await lectureRepository.bookmarkLecture(lectureId: lectureReferenceId)
        guard let currentTimetable = appState.timetable.current else { return }
        let dto = try await lectureRepository.getBookmark(quarter: currentTimetable.quarter)
        let bookmark = Bookmark(from: dto)
        appState.timetable.bookmark = bookmark
        userDefaultsRepository.set(Bool.self, key: .isFirstBookmark, value: false)
        appState.timetable.isFirstBookmark = false
    }

    func undoBookmarkLecture(lecture: Lecture) async throws {
        try await lectureRepository.undoBookmarkLecture(lectureId: lecture.lectureId ?? lecture.id)
        guard let currentTimetable = appState.timetable.current else { return }
        let dto = try await lectureRepository.getBookmark(quarter: currentTimetable.quarter)
        let bookmark = Bookmark(from: dto)
        appState.timetable.bookmark = bookmark
        appState.search.selectedLecture = nil
    }
    
    // MARK: Expand MapView

    func setIsMapViewExpanded(_ expand: Bool) {
        appState.system.isMapViewExpanded = expand
        userDefaultsRepository.set(Bool.self, key: .expandLectureMapView, value: expand)
    }

    func shouldExpandLectureMapView() -> Bool {
        if let isMapViewExpanded = appState.system.isMapViewExpanded {
            return isMapViewExpanded
        } else {
            let isMapViewExpanded = userDefaultsRepository.get(
                Bool.self,
                key: .expandLectureMapView,
                defaultValue: false
            )
            appState.system.isMapViewExpanded = isMapViewExpanded
            return isMapViewExpanded
        }
    }

    private var lectureRepository: LectureRepositoryProtocol {
        webRepositories.lectureRepository
    }

    private var userDefaultsRepository: UserDefaultsRepositoryProtocol {
        localRepositories.userDefaultsRepository
    }

    private var reviewRepository: ReviewRepositoryProtocol {
        webRepositories.reviewRepository
    }

    /// Check if `Lecture` itself has overlapping `TimePlace`
    private func checkIfTimeplaceOverlapped(_ lecture: Lecture) throws {
        for lhs in lecture.timePlaces {
            for rhs in lecture.timePlaces {
                if lhs.isOverlapped(with: rhs) {
                    throw STError(.INVALID_LECTURE_TIME)
                }
            }
        }
    }
}

class FakeLectureService: LectureServiceProtocol {
    func addCustomLecture(lecture _: Lecture, isForced _: Bool) async throws {}
    func updateLecture(oldLecture _: Lecture, newLecture _: Lecture, isForced _: Bool) async throws {}
    func addLecture(lecture _: Lecture, isForced _: Bool) async throws {}
    func deleteLecture(lecture _: Lecture) async throws {}
    func resetLecture(lecture _: Lecture) async throws {}
    func getBookmark(quarter _: Quarter) async throws {}
    func bookmarkLecture(lecture _: Lecture) async throws {}
    func undoBookmarkLecture(lecture _: Lecture) async throws {}
    func fetchIsFirstBookmark() {}
    func getEvLecture(of _: Lecture) async throws -> EvLecture? { return nil }
    func getBuildingList(of _: Lecture) async throws -> [Building] { return [] }
    func setIsMapViewExpanded(_: Bool) {}
    func shouldExpandLectureMapView() -> Bool { return false }
    func fetchBookmark(quarter _: Quarter) async throws -> Bookmark {
        throw STError(.UNKNOWN_APP)
    }
    func fetchLectureReminderList() async throws { return }
    func getLectureReminderState(timetableId: String, lecture: Lecture) async throws -> LectureReminder { return .preview }
    func changeLectureReminderState(lectureId: String, to option: ReminderOption) async throws {}
    func getCurrentOrNextSemesterPrimaryTable() -> TimetableMetadata? { nil }
}
