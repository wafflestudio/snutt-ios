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
    func fetchSearchResult(query: String, quarter: Quarter, tagList: [SearchTag], timeList: [SearchTimeMaskDto]?, excludedTimeList: [SearchTimeMaskDto]?, offset: Int, limit: Int) async throws -> [LectureDto]
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

    func fetchSearchResult(query: String, quarter: Quarter, tagList: [SearchTag], timeList: [SearchTimeMaskDto]?, excludedTimeList: [SearchTimeMaskDto]?, offset: Int, limit: Int) async throws -> [LectureDto] {
        return try await session
            .request(SearchRouter.search(query: query, quarter: quarter, tagList: tagList, timeList: timeList, excludedTimeList: excludedTimeList, offset: offset, limit: limit))
            .serializingDecodable([LectureDto].self)
            .handlingError()
    }
}
