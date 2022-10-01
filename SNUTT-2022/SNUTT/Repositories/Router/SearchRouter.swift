//
//  SearchRouter.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/20.
//

import Alamofire
import Foundation

enum SearchRouter: Router {
    var baseURL: URL { return URL(string: NetworkConfiguration.serverBaseURL + "/search_query")! }
    static let shouldAddToken: Bool = true

    case search(query: String, quarter: Quarter, tagList: [SearchTag], mask: [Int]?, offset: Int, limit: Int)

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

    var parameters: Parameters? {
        switch self {
        case let .search(query, quarter, tagList, mask, offset, limit):
            let defaultParams: [String: Any] = [
                "title": query,
                "year": quarter.year,
                "semester": quarter.semester.rawValue,
                "offset": offset,
                "limit": limit,
                "classification": [],
                "category": [],
                "credit": [],
                "etc": [],
                "department": [],
                "instructor": [],
                "academic_year": [],
            ]

            let tagParams: [String: Any] = Dictionary(grouping: tagList, by: { $0.type.rawValue })
                .mapValues { tags in
                    switch tags[0].type {
                    case .credit:
                        return tags.map { Int($0.text.trimmingCharacters(in: CharacterSet.decimalDigits.inverted)) }.compactMap { $0 }
                    case .etc:
                        return tags.map { EtcType(rawValue: $0.text)?.code }.compactMap { $0 }
                    default:
                        return tags.map { $0.text }
                    }
                }

            var parameters = defaultParams.merging(tagParams, uniquingKeysWith: { $1 })

            if mask != nil {
                parameters["time_mask"] = mask
            }

            // the server refuses empty list of `etc`.
            if let etc = parameters["etc"] as? [String], etc.isEmpty {
                parameters.removeValue(forKey: "etc")
            }

            return parameters
        }
    }
}
