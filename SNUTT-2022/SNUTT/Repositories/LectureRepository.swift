//
//  LectureRepository.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/20.
//

import Alamofire
import Foundation

protocol LectureRepositoryProtocol {
    func addLecture(timetableId: String, lectureId: String) async throws -> TimetableDto
    func updateLecture(timetableId: String, oldLecture: LectureDto, newLecture: LectureDto) async throws -> TimetableDto
    func deleteLecture(timetableId: String, lectureId: String) async throws -> TimetableDto
    func cache(timetable: TimetableDto)
}

class LectureRepository: LectureRepositoryProtocol, LocalCachable {
    private let session: Session

    var local = SNUTTDefaultsContainer()

    init(session: Session) {
        self.session = session
    }

    func cache(timetable: TimetableDto) {
        local.currentTimetable = timetable
    }

    func addLecture(timetableId: String, lectureId: String) async throws -> TimetableDto {
        return try await session
            .request(LectureRouter.addLecture(timetableId: timetableId, lectureId: lectureId))
            .serializingDecodable(TimetableDto.self)
            .handlingError()
    }

    func deleteLecture(timetableId: String, lectureId: String) async throws -> TimetableDto {
        return try await session
            .request(LectureRouter.deleteLecture(timetableId: timetableId, lectureId: lectureId))
            .serializingDecodable(TimetableDto.self)
            .handlingError()
    }

    func updateLecture(timetableId: String, oldLecture: LectureDto, newLecture: LectureDto) async throws -> TimetableDto {
        return try await session
            .request(LectureRouter.updateLecture(timetableId: timetableId, oldLecture: oldLecture, newLecture: newLecture))
            .serializingDecodable(TimetableDto.self)
            .handlingError()
    }
}
