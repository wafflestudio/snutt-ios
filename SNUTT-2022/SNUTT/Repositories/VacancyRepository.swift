//
//  VacancyRepository.swift
//  SNUTT
//
//  Created by 박신홍 on 2023/07/22.
//

import Alamofire
import Foundation

protocol VacancyRepositoryProtocol {
    func fetchLectures() async throws -> [LectureDto]
    func addLecture(lectureId: String) async throws
    func deleteLecture(lectureId: String) async throws
}

class VacancyRepository: VacancyRepositoryProtocol {
    private let session: Session

    init(session: Session) {
        self.session = session
    }

    func fetchLectures() async throws -> [LectureDto] {
        let dto = try await session
            .request(VacancyRouter.getLectures)
            .serializingDecodable(VacancyResponseDto.self)
            .handlingError()
        return dto.lectures
    }

    func addLecture(lectureId: String) async throws {
        try await session
            .request(VacancyRouter.addLecture(lectureId: lectureId))
            .serializingDecodable(Empty.self, emptyResponseCodes: [200])
            .handlingError()
    }

    func deleteLecture(lectureId: String) async throws {
        try await session
            .request(VacancyRouter.deleteLecture(lectureId: lectureId))
            .serializingDecodable(Empty.self, emptyResponseCodes: [200])
            .handlingError()
    }
}
