//
//  LectureService.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/20.
//

import Foundation
import SwiftUI

protocol LectureServiceProtocol {
    func addLecture(lecture: Lecture, isForced: Bool) async throws
    func addCustomLecture(lecture: Lecture, isForced: Bool) async throws
    func updateLecture(oldLecture: Lecture, newLecture: Lecture, isForced: Bool) async throws
    func deleteLecture(lecture: Lecture) async throws
    func resetLecture(lecture: Lecture) async throws
    func fetchReviewId(courseNumber: String, instructor: String) async throws -> String
    func getBookmark(quarter: Quarter) async throws
    func bookmarkLecture(lecture: Lecture) async throws
    func undoBookmarkLecture(lecture: Lecture) async throws
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
        let dto = try await lectureRepository.addLecture(timetableId: currentTimetable.id, lectureId: lecture.id, isForced: isForced)
        let timetable = Timetable(from: dto)
        await MainActor.run {
            appState.timetable.current = timetable
            appState.search.selectedLecture = nil
        }
        userDefaultsRepository.set(TimetableDto.self, key: .currentTimetable, value: dto)
    }
    
    func addCustomLecture(lecture: Lecture, isForced: Bool = false) async throws {
        guard let currentTimetable = appState.timetable.current else { return }
        var lectureDto = LectureDto(from: lecture)
        lectureDto.class_time_mask = nil
        let dto = try await lectureRepository.addCustomLecture(timetableId: currentTimetable.id, lecture: lectureDto, isForced: isForced)
        let timetable = Timetable(from: dto)
        await MainActor.run {
            appState.timetable.current = timetable
        }
        userDefaultsRepository.set(TimetableDto.self, key: .currentTimetable, value: dto)
    }
    
    func updateLecture(oldLecture: Lecture, newLecture: Lecture, isForced: Bool = false) async throws {
        guard let currentTimetable = appState.timetable.current else { return }
        
        // Check if `Lecture` itself has overlapping `TimePlace`
        try newLecture.timePlaces.forEach { lhs in
            try newLecture.timePlaces.forEach { rhs in
                if lhs.day == rhs.day, lhs.endTime > rhs.startTime, lhs.startTime < rhs.endTime, lhs.id != rhs.id {
                    throw STError(.INVALID_LECTURE_TIME)
                }
            }
        }
        
        let dto = try await lectureRepository.updateLecture(timetableId: currentTimetable.id, oldLecture: .init(from: oldLecture), newLecture: .init(from: newLecture), isForced: isForced)
        let timetable = Timetable(from: dto)
        await MainActor.run {
            appState.timetable.current = timetable
        }
        userDefaultsRepository.set(TimetableDto.self, key: .currentTimetable, value: dto)
    }
    
    func deleteLecture(lecture: Lecture) async throws {
        guard let currentTimetable = appState.timetable.current else { return }
        let dto = try await lectureRepository.deleteLecture(timetableId: currentTimetable.id, lectureId: lecture.id)
        let timetable = Timetable(from: dto)
        await MainActor.run {
            appState.timetable.current = timetable
        }
        userDefaultsRepository.set(TimetableDto.self, key: .currentTimetable, value: dto)
    }
    
    func resetLecture(lecture: Lecture) async throws {
        guard let currentTimetable = appState.timetable.current else { return }
        let dto = try await lectureRepository.resetLecture(timetableId: currentTimetable.id, lectureId: lecture.id)
        let timetable = Timetable(from: dto)
        await MainActor.run {
            appState.timetable.current = timetable
        }
        userDefaultsRepository.set(TimetableDto.self, key: .currentTimetable, value: dto)
    }
    
    func fetchReviewId(courseNumber: String, instructor: String) async throws -> String {
        return try await reviewRepository.fetchReviewId(courseNumber: courseNumber, instructor: instructor)
    }
    
    func getBookmark(quarter: Quarter) async throws {
        guard let currentTimetable = appState.timetable.current else { return }
        let dto = try await bookmarkRepository.getBookmark(quarter: currentTimetable.quarter)
        let bookmark = Bookmark(from: dto)
        await MainActor.run {
            appState.timetable.bookmark = bookmark
        }
        userDefaultsRepository.set(BookmarkDto.self, key: .bookmark, value: dto)
    }
    
    func bookmarkLecture(lecture: Lecture) async throws {
        try await bookmarkRepository.bookmarkLecture(lectureId: lecture.id)
//        guard let currentTimetable = appState.timetable.current else { return }
//        try await getBookmark(quarter: currentTimetable.quarter)
    }
    
    func undoBookmarkLecture(lecture: Lecture) async throws {
        try await bookmarkRepository.undoBookmarkLecture(lectureId: lecture.id)
//        guard let currentTimetable = appState.timetable.current else { return }
//        try await getBookmark(quarter: currentTimetable.quarter)
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
    
    private var bookmarkRepository: BookmarkRepositoryProtocol {
        webRepositories.bookmarkRepository
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
    func fetchReviewId(courseNumber _: String, instructor _: String) async throws -> String { return "" }
}
