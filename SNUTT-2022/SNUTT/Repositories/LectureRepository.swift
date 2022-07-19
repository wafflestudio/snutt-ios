//
//  LectureRepository.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/20.
//

import Alamofire

protocol LectureRepositoryProtocol {
    func updateLecture(timetableId: String, oldLecture: LectureDto, newLecture: LectureDto) async throws -> TimetableDto
}

class LectureRepository: LectureRepositoryProtocol {
    private let session: Session

    init(session: Session) {
        self.session = session
    }
    
    func updateLecture(timetableId: String, oldLecture: LectureDto, newLecture: LectureDto) async throws -> TimetableDto {
        let data = try await session
            .request(LectureRouter.updateLecture(timetableId: timetableId, oldLecture: oldLecture, newLecture: newLecture))
            .validate()
            .serializingDecodable(TimetableDto.self)
            .value
        return data
    }
}
