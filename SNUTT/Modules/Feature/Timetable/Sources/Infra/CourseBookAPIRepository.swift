//
//  CourseBookAPIRepository.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import APIClientInterface
import Dependencies
import Foundation
import FoundationUtility
import TimetableInterface

struct CourseBookAPIRepository: CourseBookRepository {
    @Dependency(\.apiClient) private var apiClient

    func fetchCourseBookList() async throws -> [CourseBook] {
        let response = try await apiClient.getCoursebooks_1()
        let courseBooks = try response.ok.body.json
        return courseBooks.map { CourseBook(from: $0) }
    }

    func fetchRecentCourseBook() async throws -> CourseBook {
        let response = try await apiClient.getLatestCoursebook()
        let courseBook = try response.ok.body.json
        return .init(from: courseBook)
    }

    func fetchSyllabusURL(year: Int, semester: Int, lecture: Lecture) async throws -> Syllabus {
        let response = try await apiClient.getCoursebookOfficial(
            query: .init(
                year: Int32(year),
                semester: try require(.init(rawValue: semester)),
                course_number: try require(lecture.courseNumber),
                lecture_number: try require(lecture.lectureNumber)
            )
        )
        let syllabus = try response.ok.body.json
        return .init(from: syllabus)
    }
}

extension CourseBook {
    init(from dto: Components.Schemas.CoursebookResponse) {
        self.init(
            quarter: Quarter(year: Int(dto.year), semester: Semester(from: dto.semester)),
            updatedAt: dto.updated_at
        )
    }
}

extension Semester {
    init(from dto: Components.Schemas.CoursebookResponse.semesterPayload) {
        switch dto {
        case ._1: self = .first
        case ._2: self = .second
        case ._3: self = .summer
        case ._4: self = .winter
        }
    }
}

extension Syllabus {
    init(from dto: Components.Schemas.CoursebookOfficialResponse) {
        self.init(url: dto.noProxyUrl)
    }
}
