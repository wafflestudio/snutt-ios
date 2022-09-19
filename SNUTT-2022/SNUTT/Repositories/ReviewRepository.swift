//
//  ReviewRepository.swift
//  SNUTT
//
//  Created by 최유림 on 2022/08/30.
//

import Alamofire
import Foundation

protocol ReviewRepositoryProtocol {
    func fetchReviewId(courseNumber: String, instructor: String) async throws -> Int
}

class ReviewRepository: ReviewRepositoryProtocol {
    private let session: Session

    init(session: Session) {
        self.session = session
    }

    func fetchReviewId(courseNumber: String, instructor: String) async throws -> Int {
        return try await session.request(ReviewRouter.getReviewId(courseNumber: courseNumber, instructor: instructor))
            .serializingDecodable([String: Int].self)
            .handlingError()
            .compactMap { $0.value }
            .first!
    }
}
