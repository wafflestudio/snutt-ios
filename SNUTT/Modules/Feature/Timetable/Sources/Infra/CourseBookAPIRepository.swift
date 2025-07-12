//
//  CourseBookAPIRepository.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import APIClientInterface
import Dependencies
import Foundation
import FoundationUtility
import TimetableInterface

struct CourseBookAPIRepository: CourseBookRepository {
    @Dependency(\.apiClient) private var apiClient

    func fetchCourseBookList() async throws -> [CourseBook] {
        let response = try await apiClient.getAllCoursebooks()
        let courseBooks = try response.ok.body.json
        return courseBooks.map { CourseBook(from: $0) }
    }

    func fetchRecentCourseBook() async throws -> CourseBook {
        let response = try await apiClient.getMostRecentCoursebook()
        let courseBook = try response.ok.body.json
        return .init(from: courseBook)
    }

    func fetchSyllabusURL(year: Int, semester: Int, lecture: Lecture) async throws -> Syllabus {
        let response = try await apiClient.getSyllabusUrl(
            query: .init(
                year: String(year),
                semester: String(semester),
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
