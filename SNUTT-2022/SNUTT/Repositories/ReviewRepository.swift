//
//  ReviewRepository.swift
//  SNUTT
//
//  Created by 최유림 on 2022/08/30.
//

import Alamofire
import Foundation

protocol ReviewRepositoryProtocol: Sendable {
    func fetchEvLectureInfo(lectureId: String) async throws -> EvLectureDto
}

final class ReviewRepository: ReviewRepositoryProtocol {
    private let session: Session

    init(session: Session) {
        self.session = session
    }

    func fetchEvLectureInfo(lectureId: String) async throws -> EvLectureDto {
        return try await session.request(ReviewRouter.getEvLectureInfo(lectureId: lectureId))
            .serializingDecodable(EvLectureDto.self)
            .handlingError()
    }
}
