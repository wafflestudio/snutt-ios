//
//  LectureService.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/20.
//

import Foundation
import SwiftUI

protocol LectureServiceProtocol {
    func addLecture(lecture: Lecture) async throws
    func addCustomLecture(lecture: Lecture) async throws
    func overwriteLecture(lecture: Lecture) async throws
    func overwriteCustomLecture(lecture: Lecture) async throws
    func updateLecture(oldLecture: Lecture, newLecture: Lecture) async throws
    func forceUpdateLecture(oldLecture: Lecture, newLecture: Lecture) async throws
    func deleteLecture(lecture: Lecture) async throws
    func resetLecture(lecture: Lecture) async throws
    func fetchReviewId(courseNumber: String, instructor: String, bind: Binding<String>) async throws
}

struct LectureService: LectureServiceProtocol {
    var appState: AppState
    var webRepositories: AppEnvironment.WebRepositories
    var localRepositories: AppEnvironment.LocalRepositories

    func addLecture(lecture: Lecture) async throws {
        guard let currentTimetable = appState.timetable.current else { return }
        let dto = try await lectureRepository.addLecture(timetableId: currentTimetable.id, lectureId: lecture.id, isForced: false)
        let timetable = Timetable(from: dto)
        DispatchQueue.main.async {
            appState.timetable.current = timetable
            appState.search.selectedLecture = nil
        }
        saveToUserDefaults(timetableDto: dto)
    }

    func addCustomLecture(lecture: Lecture) async throws {
        guard let currentTimetable = appState.timetable.current else { return }
        var lectureDto = LectureDto(from: lecture)
        lectureDto.class_time_mask = nil
        let dto = try await lectureRepository.addCustomLecture(timetableId: currentTimetable.id, lecture: lectureDto, isForced: false)
        let timetable = Timetable(from: dto)
        updateTimetableState(to: timetable)
        saveToUserDefaults(timetableDto: dto)
    }
    
    func overwriteLecture(lecture: Lecture) async throws {
        guard let currentTimetable = appState.timetable.current else { return }
        let dto = try await lectureRepository.addLecture(timetableId: currentTimetable.id, lectureId: lecture.id, isForced: true)
        let timetable = Timetable(from: dto)
        updateTimetableState(to: timetable)
        saveToUserDefaults(timetableDto: dto)
    }
    
    func overwriteCustomLecture(lecture: Lecture) async throws {
        guard let currentTimetable = appState.timetable.current else { return }
        var lectureDto = LectureDto(from: lecture)
        lectureDto.class_time_mask = nil
        let dto = try await lectureRepository.addCustomLecture(timetableId: currentTimetable.id, lecture: lectureDto, isForced: true)
        let timetable = Timetable(from: dto)
        updateTimetableState(to: timetable)
        saveToUserDefaults(timetableDto: dto)
    }

    func updateLecture(oldLecture: Lecture, newLecture: Lecture) async throws {
        guard let currentTimetable = appState.timetable.current else { return }
        let dto = try await lectureRepository.updateLecture(timetableId: currentTimetable.id, oldLecture: .init(from: oldLecture), newLecture: .init(from: newLecture), isForced: false)
        let timetable = Timetable(from: dto)
        updateTimetableState(to: timetable)
        saveToUserDefaults(timetableDto: dto)
    }
    
    func forceUpdateLecture(oldLecture: Lecture, newLecture: Lecture) async throws {
        guard let currentTimetable = appState.timetable.current else { return }
        let dto = try await lectureRepository.updateLecture(timetableId: currentTimetable.id, oldLecture: .init(from: oldLecture), newLecture: .init(from: newLecture), isForced: true)
        let timetable = Timetable(from: dto)
        updateTimetableState(to: timetable)
        saveToUserDefaults(timetableDto: dto)
    }

    func deleteLecture(lecture: Lecture) async throws {
        guard let currentTimetable = appState.timetable.current else { return }
        let dto = try await lectureRepository.deleteLecture(timetableId: currentTimetable.id, lectureId: lecture.id)
        let timetable = Timetable(from: dto)
        updateTimetableState(to: timetable)
        saveToUserDefaults(timetableDto: dto)
    }

    func resetLecture(lecture: Lecture) async throws {
        guard let currentTimetable = appState.timetable.current else { return }
        let dto = try await lectureRepository.resetLecture(timetableId: currentTimetable.id, lectureId: lecture.id)
        let timetable = Timetable(from: dto)
        updateTimetableState(to: timetable)
        saveToUserDefaults(timetableDto: dto)
    }

    func fetchReviewId(courseNumber: String, instructor: String, bind: Binding<String>) async throws {
        let id = try await reviewRepository.fetchReviewId(courseNumber: courseNumber, instructor: instructor)
        bind.wrappedValue = "\(id)"
    }
    
    private func updateTimetableState(to timetable: Timetable) {
        DispatchQueue.main.async {
            appState.timetable.current = timetable
        }
    }
    
    private func saveToUserDefaults(timetableDto: TimetableDto) {
        userDefaultsRepository.set(TimetableDto.self, key: .currentTimetable, value: timetableDto)
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
    func addCustomLecture(lecture _: Lecture) async throws {}
    func updateLecture(oldLecture _: Lecture, newLecture _: Lecture) async throws {}
    func forceUpdateLecture(oldLecture _: Lecture, newLecture _: Lecture) async throws {}
    func addLecture(lecture _: Lecture) async throws {}
    func overwriteLecture(lecture _: Lecture) async throws {}
    func overwriteCustomLecture(lecture _: Lecture) async throws {}
    func deleteLecture(lecture _: Lecture) async throws {}
    func resetLecture(lecture _: Lecture) async throws {}
    func fetchReviewId(courseNumber _: String, instructor _: String, bind _: Binding<String>) async throws {}
}
