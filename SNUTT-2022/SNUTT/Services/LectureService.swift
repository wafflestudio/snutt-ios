//
//  LectureService.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/20.
//

import Foundation
import SwiftUI

protocol LectureServiceProtocol {
    func updateLecture(oldLecture: Lecture, newLecture: Lecture) async throws
    func addLecture(lecture: Lecture) async throws
    func deleteLecture(lecture: Lecture) async throws
    func fetchReviewId(courseNumber: String, instructor: String, bind: Binding<String>) async throws
}

struct LectureService: LectureServiceProtocol {
    var appState: AppState
    var webRepositories: AppEnvironment.WebRepositories
    var localRepositories: AppEnvironment.LocalRepositories

    func addLecture(lecture: Lecture) async throws {
        guard let currentTimetable = appState.timetable.current else { return }
        let dto = try await lectureRepository.addLecture(timetableId: currentTimetable.id, lectureId: lecture.id)
        let timetable = Timetable(from: dto)
        DispatchQueue.main.async {
            appState.timetable.current = timetable
            appState.search.selectedLecture = nil
        }
        userDefaultsRepository.set(TimetableDto.self, key: .currentTimetable, value: dto)
    }

    func updateLecture(oldLecture: Lecture, newLecture: Lecture) async throws {
        guard let currentTimetable = appState.timetable.current else { return }
        let dto = try await lectureRepository.updateLecture(timetableId: currentTimetable.id, oldLecture: .init(from: oldLecture), newLecture: .init(from: newLecture))
        let timetable = Timetable(from: dto)
        DispatchQueue.main.async {
            appState.timetable.current = timetable
        }
        userDefaultsRepository.set(TimetableDto.self, key: .currentTimetable, value: dto)
    }

    func deleteLecture(lecture: Lecture) async throws {
        guard let currentTimetable = appState.timetable.current else { return }
        let dto = try await lectureRepository.deleteLecture(timetableId: currentTimetable.id, lectureId: lecture.id)
        let timetable = Timetable(from: dto)
        DispatchQueue.main.async {
            appState.timetable.current = timetable
        }
        userDefaultsRepository.set(TimetableDto.self, key: .currentTimetable, value: dto)
    }

    func fetchReviewId(courseNumber: String, instructor: String, bind: Binding<String>) async throws {
        let id = try await reviewRepository.fetchReviewId(courseNumber: courseNumber, instructor: instructor)
        bind.wrappedValue = "\(id)"
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
}

class FakeLectureService: LectureServiceProtocol {
    func updateLecture(oldLecture _: Lecture, newLecture _: Lecture) async throws {}
    func addLecture(lecture _: Lecture) async throws {}
    func deleteLecture(lecture _: Lecture) async throws {}
    func fetchReviewId(courseNumber _: String, instructor _: String, bind: Binding<String>) async throws {}
}
