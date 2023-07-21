//
//  VacancyRepository.swift
//  SNUTT
//
//  Created by user on 2023/07/22.
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
        return try await session
            .request(VacancyRouter.getLectures)
            .serializingDecodable([LectureDto].self)
            .handlingError()
    }

    func addLecture(lectureId: String) async throws {
        try await session
            .request(VacancyRouter.addLecture(lectureId: lectureId))
            .serializingString()
            .handlingError()
    }

    func deleteLecture(lectureId: String) async throws {
        try await session
            .request(VacancyRouter.deleteLecture(lectureId: lectureId))
            .serializingString()
            .handlingError()
    }
}
