//
//  LectureSearchAPIRepository.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import APIClientInterface
import Dependencies
import Foundation
import TimetableInterface

struct LectureSearchAPIRepository: LectureSearchRepository {
    @Dependency(\.apiClient) private var apiClient

    func fetchSearchResult(
        query: String,
        quarter: Quarter,
        filters _: [SearchFilter],
        offset: Int,
        limit: Int
    ) async throws -> [any Lecture] {
        let query = Components.Schemas.SearchQueryLegacy(
            year: Int32(quarter.year),
            semester: .init(rawValue: quarter.semester.rawValue)!,
            title: query,
            classification: [],
            credit: [],
            academic_year: [],
            department: [],
            category: [],
            times: [],
            timesToExclude: [],
            etc: [],
            page: 20,
            offset: Int64(offset),
            limit: Int32(limit),
            sortCriteria: nil
        )
        let response = try await apiClient.searchLecture(body: .json(query))
        return try response.ok.body.json
    }

    func fetchTags(quarter: Quarter) async throws {
        let response = try await apiClient.getTagList(path: .init(year: String(quarter.year), semester: String(quarter.semester.rawValue)))
        let json = try response.ok.body.json
//        guard let dict = toDictionary(json) else { throw ParsingError() }
//        var searchTags: [SearchTag] = []
//        for (key, value) in dict {
//            guard let tagStrings = value as? [String],
//                  let tagType = SearchTagType(rawValue: key) else { continue }
//            searchTags.append(contentsOf: tagStrings.map { SearchTag(type: tagType, text: $0) })
//        }
//
//        // 시간
//        searchTags.append(.init(type: .time, text: TimeType.empty.rawValue))
//        searchTags.append(.init(type: .time, text: TimeType.range.rawValue))
//
//        // 기타
//        searchTags.append(.init(type: .etc, text: EtcType.english.rawValue))
//        searchTags.append(.init(type: .etc, text: EtcType.army.rawValue))
    }
}

extension Components.Schemas.LectureDto: @retroactive Lecture {
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
        []
    }

    public var lectureNumber: String? {
        lecture_number
    }
}

private func toDictionary<T: Codable>(_ object: T) -> [String: Any]? {
    guard let data = try? JSONEncoder().encode(object),
          let dictionary = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
    else {
        return nil
    }
    return dictionary
}
