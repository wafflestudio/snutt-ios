//
//  LectureSearchAPIRepository.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import APIClientInterface
import Dependencies
import Foundation
import RegexBuilder
import TimetableInterface

struct LectureSearchAPIRepository: LectureSearchRepository {
    @Dependency(\.apiClient) private var apiClient

    func fetchSearchResult(
        query: String,
        quarter: Quarter,
        predicates: [SearchPredicate],
        offset: Int,
        limit: Int
    ) async throws -> [Lecture] {
        var classification = [String]()
        var credit = [Int32]()
        var academicYear = [String]()
        var department = [String]()
        var category = [String]()
        var categoryPre2025 = [String]()
        var times = [Components.Schemas.SearchTimeDto]()
        var timesToExclude = [Components.Schemas.SearchTimeDto]()
        var sortCriteria: String?
        var etc = [String]()

        for predicate in predicates {
            switch predicate {
            case let .sortCriteria(string):
                sortCriteria = string
            case let .classification(string):
                classification.append(string)
            case let .department(string):
                department.append(string)
            case let .academicYear(string):
                academicYear.append(string)
            case let .credit(int):
                credit.append(Int32(int))
            case .instructor:
                continue // not supported
            case let .categoryPre2025(string):
                categoryPre2025.append(string)
            case let .category(string):
                category.append(string)
            case let .timeInclude(searchTimeRange):
                if let day = Components.Schemas.SearchTimeDto.dayPayload(rawValue: searchTimeRange.day) {
                    times.append(.init(
                        day: day,
                        endMinute: Int32(searchTimeRange.endMinute),
                        startMinute: Int32(searchTimeRange.startMinute)
                    ))
                }
            case let .timeExclude(searchTimeRange):
                if let day = Components.Schemas.SearchTimeDto.dayPayload(rawValue: searchTimeRange.day) {
                    timesToExclude.append(.init(
                        day: day,
                        endMinute: Int32(searchTimeRange.endMinute),
                        startMinute: Int32(searchTimeRange.startMinute)
                    ))
                }
            case let .etc(etcType):
                etc.append(etcType.code)
            }
        }

        let query = try Components.Schemas.SearchQueryLegacy(
            academic_year: academicYear,
            category: category,
            categoryPre2025: categoryPre2025,
            classification: classification,
            course_number: nil,
            credit: credit,
            department: department,
            etc: etc.nilIfEmpty(),
            limit: Int32(limit),
            offset: Int64(offset),
            page: 20,
            semester: require(.init(rawValue: quarter.semester.rawValue)),
            sortCriteria: sortCriteria,
            times: times,
            timesToExclude: timesToExclude,
            title: query,
            year: Int32(quarter.year)
        )
        let response = try await apiClient.searchLecture(body: .json(query))
        return try response.ok.body.json.map { try $0.toLecture() }
    }

    func fetchSearchPredicates(quarter: Quarter) async throws -> [SearchPredicate] {
        let response = try await apiClient.getTagList(path: .init(
            year: String(quarter.year),
            semester: String(quarter.semester.rawValue)
        ))
        let json = try response.ok.body.json
        var searchPredicates: [SearchPredicate] = json.sortCriteria.map { .sortCriteria($0) }
        searchPredicates.append(contentsOf: json.academic_year.map { .academicYear($0) })
        searchPredicates.append(contentsOf: json.category.map { .category($0) })
        searchPredicates.append(contentsOf: json.classification.map { .classification($0) })
        searchPredicates.append(contentsOf: json.categoryPre2025.map { .categoryPre2025($0) })
        searchPredicates.append(
            contentsOf: json.credit
                .compactMap {
                    let regex = Regex { OneOrMore(.digit) }
                    let output = $0.firstMatch(of: regex)?.output
                    return output.flatMap { Int($0) }.flatMap { .credit($0) }
                }
        )
        searchPredicates.append(contentsOf: json.department.map { .department($0) })
        searchPredicates.append(contentsOf: json.instructor.map { .instructor($0) })
        searchPredicates.append(.etc(.english))
        searchPredicates.append(.etc(.army))
        return searchPredicates
    }
}

extension Components.Schemas.LectureDto {
    fileprivate func toLecture() throws -> Lecture {
        let timePlaces = try class_time_json.enumerated().map { index, json in
            try json.toTimePlace(index: index, isCustom: false)
        }
        let evLecture = snuttEvLecture.flatMap {
            EvLecture(
                evLectureID: $0.evLectureId.asInt(),
                avgRating: $0.avgRating,
                evaluationCount: $0.evaluationCount.asInt()
            )
        }
        return try Lecture(
            id: require(_id),
            lectureID: nil,
            courseTitle: course_title,
            timePlaces: timePlaces,
            lectureNumber: lecture_number,
            instructor: instructor,
            credit: credit,
            courseNumber: course_number,
            department: department,
            academicYear: academic_year,
            remark: remark,
            evLecture: evLecture,
            colorIndex: 0,
            customColor: .temporary,
            classification: classification,
            category: category,
            wasFull: wasFull,
            registrationCount: registrationCount,
            quota: quota,
            freshmenQuota: freshmanQuota
        )
    }
}

extension Array {
    fileprivate func nilIfEmpty() -> Self? {
        isEmpty ? nil : self
    }
}
