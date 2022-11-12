//
//  CourseBookRepository.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/08/19.
//

import Alamofire
import Foundation

protocol CourseBookRepositoryProtocol {
    func fetchAllCourseBookList() async throws -> [CourseBookDto]
    func fetchRecentCourseBook() async throws -> CourseBookDto
    func fetchSyllabusURL(year: Int, semester: Int, lecture: LectureDto) async throws -> SyllabusDto
}

class CourseBookRepository: CourseBookRepositoryProtocol {
    private let session: Session

    init(session: Session) {
        self.session = session
    }

    func fetchAllCourseBookList() async throws -> [CourseBookDto] {
        return try await session
            .request(CourseBookRouter.getCourseBookList)
            .serializingDecodable([CourseBookDto].self)
            .handlingError()
    }

    func fetchRecentCourseBook() async throws -> CourseBookDto {
        return try await session
            .request(CourseBookRouter.getRecentCourseBook)
            .serializingDecodable(CourseBookDto.self)
            .handlingError()
    }

    func fetchSyllabusURL(year: Int, semester: Int, lecture: LectureDto) async throws -> SyllabusDto {
        return try await session
            .request(CourseBookRouter.getSyllabusURL(year: year, semester: semester, lecture: lecture))
            .serializingDecodable(SyllabusDto.self)
            .handlingError()
    }
}
