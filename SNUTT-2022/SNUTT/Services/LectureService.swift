//
//  LectureService.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/20.
//

import Foundation

protocol LectureServiceProtocol {
    func updateLecture(timetableId: String, oldLecture: Lecture, newLecture: Lecture) async throws
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
    
    func updateLecture(timetableId: String, oldLecture: Lecture, newLecture: Lecture) async throws {
        let dto = try await lectureRepository.updateLecture(timetableId: timetableId, oldLecture: .init(from: oldLecture), newLecture: .init(from: newLecture))
        let timetable = Timetable(from: dto)
        DispatchQueue.main.async {
            appState.setting.timetableSetting.current = timetable
        }
    }
}

class FakeLectureService: LectureServiceProtocol {
    func updateLecture(timetableId: String, oldLecture: Lecture, newLecture: Lecture) async throws {}
}
