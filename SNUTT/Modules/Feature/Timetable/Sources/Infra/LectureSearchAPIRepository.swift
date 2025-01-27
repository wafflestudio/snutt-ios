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
    ) async throws -> [any Lecture] {
        var classification = [String]()
        var credit = [Int32]()
        var academicYear = [String]()
        var department = [String]()
        var category = [String]()
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
            case let .instructor(string):
                continue // not supported
            case let .category(string):
                category.append(string)
            case let .timeInclude(searchTimeRange):
                if let day = Components.Schemas.SearchTimeDto.dayPayload(rawValue: searchTimeRange.day) {
                    times.append(.init(day: day, startMinute: Int32(searchTimeRange.startMinute), endMinute: Int32(searchTimeRange.endMinute)))
                }
            case let .timeExclude(searchTimeRange):
                if let day = Components.Schemas.SearchTimeDto.dayPayload(rawValue: searchTimeRange.day) {
                    timesToExclude.append(.init(day: day, startMinute: Int32(searchTimeRange.startMinute), endMinute: Int32(searchTimeRange.endMinute)))
                }
            case let .etc(etcType):
                etc.append(etcType.code)
            }
        }

        let query = Components.Schemas.SearchQueryLegacy(
            year: Int32(quarter.year),
            semester: .init(rawValue: quarter.semester.rawValue)!,
            title: query,
            classification: classification,
            credit: credit,
            academic_year: academicYear,
            department: department,
            category: category,
            times: times,
            timesToExclude: timesToExclude,
            etc: etc.nilIfEmpty(),
            page: 20,
            offset: Int64(offset),
            limit: Int32(limit),
            sortCriteria: sortCriteria
        )
        let response = try await apiClient.searchLecture(body: .json(query))
        return try response.ok.body.json
    }

    func fetchSearchPredicates(quarter: Quarter) async throws -> [SearchPredicate] {
        let response = try await apiClient.getTagList(path: .init(year: String(quarter.year), semester: String(quarter.semester.rawValue)))
        let json = try response.ok.body.json
        var searchFilters: [SearchPredicate] = json.sortCriteria.map { .sortCriteria($0) }
        searchFilters.append(contentsOf: json.academic_year.map { .academicYear($0) })
        searchFilters.append(contentsOf: json.category.map { .category($0) })
        searchFilters.append(contentsOf: json.classification.map { .classification($0) })
        searchFilters.append(
            contentsOf: json.credit
                .compactMap {
                    let regex = Regex { OneOrMore(.digit) }
                    let output = $0.firstMatch(of: regex)?.output
                    return output.flatMap { Int($0) }.flatMap { .credit($0) }
                }
        )
        searchFilters.append(contentsOf: json.department.map { .department($0) })
        searchFilters.append(contentsOf: json.instructor.map { .instructor($0) })
        searchFilters.append(.etc(.english))
        searchFilters.append(.etc(.army))
        return searchFilters
    }
}

extension Components.Schemas.LectureDto: @retroactive Lecture {
    public var freshmenQuota: Int32? {
        freshmanQuota
    }

    public var customColor: TimetableInterface.LectureColor? {
        .temporary
    }

    public var evLecture: EvLecture? {
        guard let snuttEvLecture else { return nil }
        return .init(evLectureID: snuttEvLecture.evLectureId.asInt(), avgRating: snuttEvLecture.avgRating, evaluationCount: snuttEvLecture.evaluationCount.asInt())
    }

    public var academicYear: String? {
        academic_year
    }

    public var courseNumber: String? {
        course_number
    }

    public var id: String {
        guard let _id else {
            assertionFailure("id shouldn't be nil.")
            return UUID().uuidString
        }
        return _id
    }

    public var lectureID: String? {
        nil
    }

    public var courseTitle: String {
        course_title
    }

    public var timePlaces: [TimetableInterface.TimePlace] {
        class_time_json
            .enumerated()
            .compactMap { index, json in
                TimePlace(dto: json, index: index, isCustom: isCustom)
            }
    }

    public var lectureNumber: String? {
        lecture_number
    }
}

extension Array {
    fileprivate func nilIfEmpty() -> Self? {
        isEmpty ? nil : self
    }
}
