//
//  CourseBookService.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/08/19.
//

import Foundation
import SwiftUI

protocol CourseBookServiceProtocol {
    func fetchCourseBookList() async throws
    func fetchRecentCourseBook() async throws
    func fetchSyllabusURL(quarter: Quarter, lecture: Lecture) async throws -> String
    /// 새로운 학기의 수강편람이 나와 있지만 유저가 해당 학기 시간표를 아직 만들지 않았다면 `true`를 리턴한다.
    func isNewCourseBookAvailable() -> Bool
    func getLatestEmptyQuarter() -> Quarter?
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
        await MainActor.run {
            appState.timetable.courseBookList = quarters
        }
    }

    func fetchRecentCourseBook() async throws {
        let dto = try await courseBookRepository.fetchRecentCourseBook()
        let _ = Quarter(from: dto)
    }

    func fetchSyllabusURL(quarter: Quarter, lecture: Lecture) async throws -> String {
        let dto = try await courseBookRepository.fetchSyllabusURL(year: quarter.year,
                                                                  semester: quarter.semester.rawValue,
                                                                  lecture: LectureDto(from: lecture))
        return dto.url
    }

    func getLatestEmptyQuarter() -> Quarter? {
        let myLatestQuarter = appState.timetable.metadataList?.map { $0.quarter }.sorted().last
        let latestCourseBook = appState.timetable.courseBookList?.sorted().last

        if myLatestQuarter != latestCourseBook {
            return latestCourseBook
        }

        return nil
    }

    func isNewCourseBookAvailable() -> Bool {
        getLatestEmptyQuarter() != nil
    }
}

struct FakeCourseBookService: CourseBookServiceProtocol {
    func fetchCourseBookList() async throws {}
    func fetchRecentCourseBook() async throws {}
    func fetchSyllabusURL(quarter _: Quarter, lecture _: Lecture) async throws -> String { return "" }
    func isNewCourseBookAvailable() -> Bool { return true }
    func getLatestEmptyQuarter() -> Quarter? { return nil }
}
