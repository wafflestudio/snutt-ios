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
    func cache(timetable: TimetableDto)
}

struct LectureService: LectureServiceProtocol {
    var appState: AppState
    var webRepositories: AppEnvironment.WebRepositories

    var lectureRepository: LectureRepositoryProtocol {
        webRepositories.lectureRepository
    }

    init(appState: AppState, webRepositories: AppEnvironment.WebRepositories) {
        self.appState = appState
        self.webRepositories = webRepositories
    }

    func cache(timetable: TimetableDto) {
        lectureRepository.cache(timetable: timetable)
    }

    func addLecture(lecture: Lecture) async throws {
        guard let currentTimetable = appState.timetable.current else { return }
        let dto = try await lectureRepository.addLecture(timetableId: currentTimetable.id, lectureId: lecture.id)
        cache(timetable: dto)
        let timetable = Timetable(from: dto)
        DispatchQueue.main.async {
            withAnimation(.customSpring) {
                appState.search.selectedLecture = nil
            }
            appState.timetable.current = timetable
        }
    }

    func updateLecture(oldLecture: Lecture, newLecture: Lecture) async throws {
        guard let currentTimetable = appState.timetable.current else { return }
        let dto = try await lectureRepository.updateLecture(timetableId: currentTimetable.id, oldLecture: .init(from: oldLecture), newLecture: .init(from: newLecture))
        cache(timetable: dto)
        let timetable = Timetable(from: dto)
        DispatchQueue.main.async {
            appState.timetable.current = timetable
        }
    }

    func deleteLecture(lecture: Lecture) async throws {
        guard let currentTimetable = appState.timetable.current else { return }
        let dto = try await lectureRepository.deleteLecture(timetableId: currentTimetable.id, lectureId: lecture.id)
        cache(timetable: dto)
        let timetable = Timetable(from: dto)
        DispatchQueue.main.async {
            appState.timetable.current = timetable
        }
    }
}

class FakeLectureService: LectureServiceProtocol {
    func cache(timetable _: TimetableDto) {}
    func updateLecture(oldLecture _: Lecture, newLecture _: Lecture) async throws {}
    func addLecture(lecture _: Lecture) async throws {}
    func deleteLecture(lecture _: Lecture) async throws {}
}
