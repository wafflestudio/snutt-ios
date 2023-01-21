//
//  BookmarkRepository.swift
//  SNUTT
//
//  Created by 이채민 on 2023/01/21.
//

import Alamofire
import Foundation

protocol BookmarkRepositoryProtocol {
    func getBookmark(quarter: Quarter) async throws -> BookmarkDto
    func bookmarkLecture(lectureId: String) async throws
    func undoBookmarkLecture(lectureId: String) async throws
}

class BookmarkRepository: BookmarkRepositoryProtocol {
    private let session: Session

    init(session: Session) {
        self.session = session
    }

    func getBookmark(quarter: Quarter) async throws -> BookmarkDto {
        return try await session
            .request(BookmarkRouter.getBookmark(quarter: quarter))
            .serializingDecodable(BookmarkDto.self)
            .handlingError()
    }

    func bookmarkLecture(lectureId: String) async throws {
        let _ = try await session
            .request(BookmarkRouter.bookmarkLecture(lectureId: lectureId))
            .serializingDecodable(BookmarkDto.self)
            .handlingError()
    }

    func undoBookmarkLecture(lectureId: String) async throws {
        let _ = try await session
            .request(BookmarkRouter.undoBookmarkLecture(lectureId: lectureId))
            .serializingDecodable(BookmarkDto.self)
            .handlingError()
    }
}
