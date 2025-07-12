//
//  CourseBookRepository.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import Foundation
import Spyable
import TimetableInterface

@Spyable
protocol CourseBookRepository: Sendable {
    func fetchCourseBookList() async throws -> [CourseBook]
    func fetchRecentCourseBook() async throws -> CourseBook
    func fetchSyllabusURL(year: Int, semester: Int, lecture: Lecture) async throws -> Syllabus
}
