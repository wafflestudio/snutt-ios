//
//  CourseBookService.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/08/19.
//

import Foundation

protocol CourseBookServiceProtocol {
    func fetchCourseBookList() async throws
    func fetchRecentCourseBook() async throws
    func fetchSyllabusUrl(quarter: Quarter, lecture: Lecture) async throws -> String
}

struct CourseBookService: CourseBookServiceProtocol {
    let appState: AppState
    let webRepositories: AppEnvironment.WebRepositories

    var courseBookRepository: CourseBookRepositoryProtocol {
        webRepositories.courseBookRepository
    }

    func fetchCourseBookList() async throws {
        let dtos = try await courseBookRepository.fetchAllCourseBookList()
        let quarters = dtos.map { Quarter(from: $0) }
        DispatchQueue.main.async {
            appState.timetable.courseBookList = quarters
        }
    }

    func fetchRecentCourseBook() async throws {
        let dto = try await courseBookRepository.fetchRecentCourseBook()
        let _ = Quarter(from: dto)
    }

    func fetchSyllabusUrl(quarter: Quarter, lecture: Lecture) async throws -> String {
        let dto = try await courseBookRepository.fetchSyllabusUrl(year: quarter.year,
                                                                  semester: quarter.semester.rawValue,
                                                                  lecture: LectureDto(from: lecture))
        return dto.url
    }
}

struct FakeCourseBookService: CourseBookServiceProtocol {
    func fetchCourseBookList() async throws {}

    func fetchRecentCourseBook() async throws {}

    func fetchSyllabusUrl(quarter _: Quarter, lecture _: Lecture) async throws -> String {
        return "http://sugang.snu.ac.kr/sugang/cc/cc103.action?openSchyy=2017&openShtmFg=U000200001&openDetaShtmFg=U000300001&sbjtCd=4190.210&ltNo=001&sbjtSubhCd=000"
    }
}
