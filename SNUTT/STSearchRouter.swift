//
//  STSearchRouter.swift
//  SNUTT
//
//  Created by Rajin on 2016. 1. 24..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Alamofire
import Foundation

enum STSearchRouter: STRouter {
    static let baseURLString = STConfig.sharedInstance.baseURL + "/search_query"
    static let shouldAddToken: Bool = true

    case search(query: String, tagList: [STTag], mask: [Int]?, offset: Int, limit: Int)

    var method: HTTPMethod {
        switch self {
        case .search:
            return .post
        }
    }

    var path: String {
        switch self {
        case .search:
            return ""
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case let .search(query, tagList, mask, offset, limit):
            // FIXME: is there better way?
            let year = STTimetableManager.sharedInstance.currentTimetable?.quarter.year ?? 0
            let semester = STTimetableManager.sharedInstance.currentTimetable?.quarter.semester ?? STSemester.first
            var credit: [Int] = []
            var instructor: [String] = []
            var department: [String] = []
            var academicYear: [String] = []
            var classification: [String] = []
            var category: [String] = []
            var etc: [String] = []

            for tag in tagList {
                switch tag.type {
                case .Credit:
                    credit.append(Int(tag.text.trimmingCharacters(in: CharacterSet.decimalDigits.inverted))!)
                case .Department:
                    department.append(tag.text)
                case .Instructor:
                    instructor.append(tag.text)
                case .AcademicYear:
                    academicYear.append(tag.text)
                case .Classification:
                    classification.append(tag.text)
                case .Category:
                    category.append(tag.text)
                case .Etc:
                    if let etcTag = EtcTag(rawValue: tag.text), etcTag != .empty {
                        etc.append(etcTag.convertToAbb())
                    }
                }
            }
            var parameters: [String: Any] = [
                "title": query,
                "year": year,
                "semester": semester.rawValue,
                "credit": credit,
                "instructor": instructor,
                "department": department,
                "academic_year": academicYear,
                "classification": classification,
                "category": category,
                "offset": offset,
                "limit": limit,
            ]

            if etc.count != 0 {
                parameters["etc"] = etc
            }

            if mask != nil {
                parameters["time_mask"] = mask
            }
            return parameters
        }
    }
}
