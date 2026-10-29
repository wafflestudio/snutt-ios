//
//  EvaluationAPIRepository.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import AuthInterface
import Dependencies
import Foundation
import HTTPTypes
import OpenAPIRuntime
import OpenAPIURLSession
import SharedAppMetadata
import SwiftUtility
import TimetableInterface

struct EvaluationAPIRepository: EvaluationRepository {
    @Dependency(\.appMetadata) private var appMetadata
    @Dependency(\.authState) private var authState

    func fetchMainSorts() async throws -> [EvaluationSort] {
        let output = try await client.getMainTags()
        let tagGroup = try output.ok.body.json
        return tagGroup.evaluationSorts
    }

    func fetchEvaluations(sort: EvaluationSort, cursor: String?) async throws -> EvaluationPage {
        let output = try await client.getMainTagEvaluations(
            path: .init(id: sort.id),
            query: .init(cursor: cursor)
        )
        let response = try output.ok.body.json
        return response.evaluationPage
    }

    func fetchTakenLectures() async throws -> [TakenLectureSummary] {
        let output = try await client.getLecturesTakenByCurrentUser()
        let response = try output.ok.body.json
        return try response.takenLectureSummaries()
    }

    private var client: Client {
        Client(
            serverURL: appMetadata.apiURL.appending(path: "v1/ev-service"),
            transport: URLSessionTransport(),
            middlewares: [
                EvaluationAuthenticationMiddleware(
                    appMetadata: appMetadata,
                    accessToken: authState.get(.accessToken)
                )
            ]
        )
    }
}

private struct EvaluationAuthenticationMiddleware: ClientMiddleware {
    private let appMetadata: AppMetadata
    private let accessToken: @Sendable () -> String?

    init(
        appMetadata: AppMetadata,
        accessToken: @autoclosure @escaping @Sendable () -> String?
    ) {
        self.appMetadata = appMetadata
        self.accessToken = accessToken
    }

    func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID _: String,
        next: @Sendable (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        var request = request
        if let accessToken = accessToken(),
            let accessTokenKey = HTTPField.Name("x-access-token")
        {
            request.headerFields[accessTokenKey] = accessToken
        }
        for item in AppMetadataKey.allCases {
            guard let key = item.keyForHeader,
                let headerKey = HTTPField.Name(key)
            else { continue }
            request.headerFields[headerKey] = appMetadata[item]
        }
        return try await next(request, body, baseURL)
    }
}

extension Components.Schemas.TagGroupDto {
    var evaluationSorts: [EvaluationSort] {
        tags
            .compactMap(\.evaluationSort)
            .sorted { lhs, rhs in
                let lhsTag = tags.first(where: { $0.id == lhs.id })
                let rhsTag = tags.first(where: { $0.id == rhs.id })
                let lhsOrdering = lhsTag?.ordering ?? .max
                let rhsOrdering = rhsTag?.ordering ?? .max
                if lhsOrdering != rhsOrdering {
                    return lhsOrdering < rhsOrdering
                }
                return lhs.kind.sortPriority < rhs.kind.sortPriority
            }
    }
}

extension EvaluationSort.Kind {
    fileprivate var sortPriority: Int {
        switch self {
        case .recommended: 0
        case .latest: 1
        }
    }
}

extension Components.Schemas.TagDto {
    var evaluationSort: EvaluationSort? {
        switch name {
        case "추천":
            EvaluationSort(id: id, kind: .recommended)
        case "최신":
            EvaluationSort(id: id, kind: .latest)
        default:
            nil
        }
    }
}

extension Components.Schemas.CursorPaginationResponseEvaluationWithLectureResponse {
    var evaluationPage: EvaluationPage {
        EvaluationPage(
            evaluations: content.map(\.lectureEvaluation),
            cursor: cursor,
            isLast: last
        )
    }
}

extension Components.Schemas.EvaluationWithLectureResponse {
    var lectureEvaluation: LectureEvaluation {
        LectureEvaluation(
            id: EvaluationID(id),
            lecture: lecture.evaluationLectureBrief,
            rating: rating,
            content: content,
            year: Int(year),
            semester: Int(semester),
            likeCount: Int(likeCount),
            isLiked: isLiked,
            isReportable: isReportable
        )
    }
}

extension Components.Schemas.SimpleLectureDto {
    var evaluationLectureBrief: EvaluationLectureBrief {
        EvaluationLectureBrief(
            id: EvaluationLectureID(id),
            title: title,
            instructor: instructor
        )
    }
}

extension Components.Schemas.ListResponseLectureTakenByUserResponse {
    func takenLectureSummaries() throws -> [TakenLectureSummary] {
        try content.map { try $0.takenLectureSummary() }
    }
}

extension Components.Schemas.LectureTakenByUserResponse {
    func takenLectureSummary() throws -> TakenLectureSummary {
        return TakenLectureSummary(
            lecture: EvaluationLectureBrief(
                id: EvaluationLectureID(id),
                title: try title.unwrapped(),
                instructor: instructor
            ),
            department: department,
            courseNumber: courseNumber,
            credit: credit.map(Int.init),
            academicYear: academicYear,
            classification: classification?.rawValue,
            takenQuarter: Quarter(
                year: Int(takenYear),
                semester: try Semester(rawValue: Int(takenSemester)).unwrapped()
            )
        )
    }
}
