//
//  SearchRepository.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/20.
//

import Alamofire
import Foundation

protocol SearchRepositoryProtocol {
    func fetchTags(quarter: Quarter) async throws -> SearchTagListDto
}

class SearchRepository: SearchRepositoryProtocol {
    private let session: Session

    init(session: Session) {
        self.session = session
    }

    func fetchTags(quarter: Quarter) async throws -> SearchTagListDto {
        return try await session
            .request(TagRouter.getTags(quarter: quarter))
            .serializingDecodable(SearchTagListDto.self)
            .handlingError()
    }
}
