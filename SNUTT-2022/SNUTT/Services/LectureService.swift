//
//  LectureService.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/20.
//

import SwiftUI

@MainActor
protocol LectureServiceProtocol: Sendable {
    func addLecture(lecture: Lecture, isForced: Bool) async throws
    func addCustomLecture(lecture: Lecture, isForced: Bool) async throws
    func updateLecture(oldLecture: Lecture, newLecture: Lecture, isForced: Bool) async throws
    func deleteLecture(lecture: Lecture) async throws
    func resetLecture(lecture: Lecture) async throws
    func getEvLecture(of lecture: Lecture) async throws -> EvLecture?
    func getBuildingList(of lecture: Lecture) async throws -> [Building]

    // MARK: Bookmark

    func fetchIsFirstBookmark()
    func bookmarkLecture(lecture: Lecture) async throws
    func undoBookmarkLecture(lecture: Lecture) async throws

    // MARK: Map

    func setIsMapViewExpanded(_ open: Bool)
    func shouldExpandLectureMapView() -> Bool
    func fetchBookmark(quarter: Quarter) async throws -> Bookmark
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

    func fetchBookmark(quarter: Quarter) async throws -> Bookmark {
        let bookmarkDto = try await lectureRepository.getBookmark(quarter: quarter)
        return .init(from: bookmarkDto)
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
}
