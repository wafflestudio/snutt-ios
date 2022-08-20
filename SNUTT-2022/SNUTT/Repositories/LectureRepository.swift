//
//  LectureRepository.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/20.
//

import Alamofire
import Foundation

protocol LectureRepositoryProtocol {
    func updateLecture(timetableId: String, oldLecture: LectureDto, newLecture: LectureDto) async throws -> TimetableDto
}

class LectureRepository: LectureRepositoryProtocol {
    private let session: Session

    init(session: Session) {
        self.session = session
    }

    func updateLecture(timetableId: String, oldLecture: LectureDto, newLecture: LectureDto) async throws -> TimetableDto {
        return try await session
            .request(LectureRouter.updateLecture(timetableId: timetableId, oldLecture: oldLecture, newLecture: newLecture))
            .serializingDecodable(TimetableDto.self)
            .handlingError()
    }
}
