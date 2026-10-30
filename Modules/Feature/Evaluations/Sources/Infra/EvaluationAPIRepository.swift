//
//  EvaluationAPIRepository.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import APIClientInterface
import AuthInterface
import Dependencies
import Foundation
import HTTPTypes
import OpenAPIRuntime
import OpenAPIURLSession
import SharedAppMetadata
import TimetableInterface

struct EvaluationAPIRepository: EvaluationRepository {
    @Dependency(\.appMetadata) private var appMetadata
    @Dependency(\.authState) private var authState
    @Dependency(\.authSecureRepository) private var secureRepository

    func fetchMainSorts() async throws -> [EvaluationSort] {
        try await client.getMainTags().ok.body.json.evaluationSorts
    }

    func fetchEvaluations(sort: EvaluationSort, cursor: String?) async throws -> CursorPage<EvaluationWithLecture> {
        let response = try await client.getMainTagEvaluations(
            path: .init(id: sort.id),
            query: .init(cursor: cursor)
        ).ok.body.json
        return response.evaluationPage()
    }

    func fetchTakenLectures() async throws -> [TakenLecture] {
        let response = try await client.getLecturesTakenByCurrentUser().ok.body.json
        return response.content.compactMap { try? $0.takenLecture() }
    }

    func fetchLectureSummary(lectureID: EvaluationLectureID) async throws -> LectureEvaluationSummary {
        try await client.getLectureEvaluationSummary(path: .init(id: lectureID.rawValue)).ok.body.json
            .lectureEvaluationSummary
    }

    func fetchLectureEvaluations(
        lectureID: EvaluationLectureID,
        cursor: String?
    ) async throws -> CursorPage<LectureEvaluation> {
        let response = try await client.getLectureEvaluations(
            path: .init(id: lectureID.rawValue),
            query: .init(cursor: cursor)
        ).ok.body.json
        return CursorPage(
            items: response.content.compactMap { try? $0.lectureEvaluation() },
            nextCursor: response.last ? nil : response.cursor
        )
    }

    func fetchMyLectureEvaluations(lectureID: EvaluationLectureID) async throws -> [LectureEvaluation] {
        try await client.getLectureEvaluationsOfMe(path: .init(id: lectureID.rawValue)).ok.body.json
            .evaluations.compactMap { try? $0.lectureEvaluation() }
    }

    func fetchMyEvaluations(cursor: String?) async throws -> CursorPage<EvaluationWithLecture> {
        try await client.getEvaluationsOfMe(query: .init(cursor: cursor)).ok.body.json.evaluationPage()
    }

    func fetchSearchTagGroups() async throws -> [SearchTagGroup] {
        try await client.getSearchTags().ok.body.json.tagGroups
            .sorted { $0.ordering < $1.ordering }
            .map(\.searchTagGroup)
    }

    func searchLectures(query: LectureSearchQuery, page: Int) async throws -> LectureSearchPage {
        let response = try await client.getLectures(
            query: .init(
                query: query.trimmedText,
                page: Int32(page),
                tags: query.tags.isEmpty ? nil : query.tags.map(\.id.rawValue)
            )
        ).ok.body.json
        return LectureSearchPage(
            results: response.content.map(\.lectureSearchResult),
            page: Int(response.page),
            isLast: response.last
        )
    }

    func fetchWriteTarget(lectureID: EvaluationLectureID) async throws -> EvaluationWriteTarget {
        try await client.getSemesterLectures(path: .init(id: lectureID.rawValue)).ok.body.json.writeTarget
    }

    func createEvaluation(_ submission: EvaluationSubmission) async throws -> EvaluationID {
        let response = try await client.createEvaluation(
            path: .init(id: submission.semesterLectureID.rawValue),
            body: .json(
                .init(
                    content: submission.content,
                    gains: submission.scores.gains,
                    gradeSatisfaction: submission.scores.gradeSatisfaction,
                    lifeBalance: submission.scores.lifeBalance,
                    rating: submission.rating,
                    teachingSkill: submission.scores.teachingSkill
                )
            )
        ).ok.body.json
        return EvaluationID(response.id)
    }

    func updateEvaluation(id: EvaluationID, _ submission: EvaluationSubmission) async throws {
        _ = try await client.updateLectureEvaluation(
            path: .init(id: id.rawValue),
            body: .json(
                .init(
                    content: submission.content,
                    gains: submission.scores.gains,
                    gradeSatisfaction: submission.scores.gradeSatisfaction,
                    lifeBalance: submission.scores.lifeBalance,
                    rating: submission.rating,
                    semesterLectureId: submission.semesterLectureID.rawValue,
                    teachingSkill: submission.scores.teachingSkill
                )
            )
        ).ok
    }

    func deleteEvaluation(id: EvaluationID) async throws {
        _ = try await client.deleteLectureEvaluation(path: .init(id: id.rawValue)).ok
    }

    func setLiked(_ isLiked: Bool, evaluationID: EvaluationID) async throws {
        if isLiked {
            _ = try await client.likeEvaluation(path: .init(id: evaluationID.rawValue)).ok
        } else {
            _ = try await client.cancelLikeEvaluation(path: .init(id: evaluationID.rawValue)).ok
        }
    }

    func reportEvaluation(id: EvaluationID, reason: String) async throws {
        _ = try await client.reportLectureEvaluation(
            path: .init(id: id.rawValue),
            body: .json(.init(content: reason))
        ).ok
    }

    private var client: Client {
        Client(
            serverURL: appMetadata.apiURL.appending(path: "v1/ev-service"),
            transport: URLSessionTransport(),
            middlewares: [
                AuthenticationMiddleware(
                    appMetadata: appMetadata,
                    accessToken: authState.get(.accessToken),
                    handleUnauthenticated: { [authState, secureRepository] in
                        authState.clear()
                        try? secureRepository.clear()
                    }
                ),
                EvaluationErrorDecodingMiddleware(),
            ]
        )
    }
}

/// Converts EV error payloads (`errcode`, `displayMessage`) into the app's shared error types.
private struct EvaluationErrorDecodingMiddleware: ClientMiddleware {
    func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID _: String,
        next: @Sendable (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        let (response, body) = try await next(request, body, baseURL)
        if response.status.code >= 500 {
            throw LocalizedErrorCode.serverFault
        }
        guard response.status.kind != .successful, let body else {
            return (response, body)
        }
        let data = try await Data(collecting: body, upTo: .max)
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let errorCode = json["errcode"] as? Int
        {
            throw LocalizedErrorCode(rawValue: errorCode)
                ?? ClientUnknownServerError(
                    errorCode: errorCode,
                    errorDescription: EvaluationsStrings.errorRequestFailed,
                    failureReason: json["displayMessage"] as? String ?? json["message"] as? String,
                    recoverySuggestion: nil
                )
        }
        return (response, HTTPBody(data))
    }
}

// MARK: - DTO Mapping

extension Components.Schemas.TagGroupDto {
    var evaluationSorts: [EvaluationSort] {
        tags
            .sorted { lhs, rhs in
                lhs.ordering != rhs.ordering ? lhs.ordering < rhs.ordering : lhs.id < rhs.id
            }
            .compactMap(\.evaluationSort)
    }

    var searchTagGroup: SearchTagGroup {
        SearchTagGroup(
            id: id,
            name: name,
            tags:
                tags
                .sorted { $0.ordering < $1.ordering }
                .map { SearchTag(id: SearchTagID($0.id), name: $0.name) }
        )
    }
}

extension Components.Schemas.TagDto {
    /// The server identifies main tags only by their Korean names.
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
    /// Skips malformed items so one bad record doesn't fail the whole page, as ``writeTarget`` does.
    func evaluationPage() -> CursorPage<EvaluationWithLecture> {
        CursorPage(
            items: content.compactMap { try? $0.evaluationWithLecture() },
            nextCursor: last ? nil : cursor
        )
    }
}

extension Components.Schemas.EvaluationWithLectureResponse {
    func evaluationWithLecture() throws -> EvaluationWithLecture {
        EvaluationWithLecture(
            evaluation: LectureEvaluation(
                id: EvaluationID(id),
                lectureID: EvaluationLectureID(lecture.id),
                rating: rating,
                scores: EvaluationScores(
                    gradeSatisfaction: gradeSatisfaction,
                    teachingSkill: teachingSkill,
                    gains: gains,
                    lifeBalance: lifeBalance
                ),
                content: content.trimmingCharacters(in: .whitespacesAndNewlines),
                quarter: try Quarter(year: year, semester: semester),
                like: EvaluationLike(count: Int(likeCount), isLiked: isLiked),
                permissions: .init(isModifiable: isModifiable, isReportable: isReportable)
            ),
            lecture: lecture.evaluationLectureBrief
        )
    }
}

extension Components.Schemas.EvaluationWithSemesterResponse {
    func lectureEvaluation() throws -> LectureEvaluation {
        LectureEvaluation(
            id: EvaluationID(id),
            lectureID: EvaluationLectureID(lectureId),
            rating: rating,
            scores: EvaluationScores(
                gradeSatisfaction: gradeSatisfaction,
                teachingSkill: teachingSkill,
                gains: gains,
                lifeBalance: lifeBalance
            ),
            content: content.trimmingCharacters(in: .whitespacesAndNewlines),
            quarter: try Quarter(year: year, semester: semester),
            like: EvaluationLike(count: Int(likeCount), isLiked: isLiked),
            permissions: .init(isModifiable: isModifiable, isReportable: isReportable)
        )
    }
}

extension Components.Schemas.SimpleLectureDto {
    var evaluationLectureBrief: EvaluationLectureBrief {
        EvaluationLectureBrief(
            id: EvaluationLectureID(id),
            title: title.trimmingCharacters(in: .whitespaces),
            instructor: instructor.nilIfBlank
        )
    }
}

extension Components.Schemas.LectureTakenByUserResponse {
    func takenLecture() throws -> TakenLecture {
        guard let title else { throw EvaluationError.invalidResponse }
        return TakenLecture(
            info: EvaluationLectureInfo(
                brief: EvaluationLectureBrief(
                    id: EvaluationLectureID(id),
                    title: title.trimmingCharacters(in: .whitespaces),
                    instructor: instructor?.nilIfBlank
                ),
                department: department?.nilIfBlank,
                academicYear: academicYear?.nilIfBlank,
                classification: classification?.nilIfBlank,
                credit: credit.map(Int.init)
            ),
            takenQuarter: try Quarter(year: takenYear, semester: takenSemester),
            averageRating: nil,
            myEvaluations: []
        )
    }
}

extension Components.Schemas.LectureEvaluationSummaryResponse {
    var lectureEvaluationSummary: LectureEvaluationSummary {
        LectureEvaluationSummary(
            info: EvaluationLectureInfo(
                brief: EvaluationLectureBrief(
                    id: EvaluationLectureID(id),
                    title: title?.trimmingCharacters(in: .whitespaces) ?? "",
                    instructor: instructor?.nilIfBlank
                ),
                department: department?.nilIfBlank,
                academicYear: academicYear?.nilIfBlank,
                classification: classification?.nilIfBlank,
                credit: credit.map(Int.init)
            ),
            averageRating: evaluation.avgRating,
            averageScores: EvaluationScores(
                gradeSatisfaction: evaluation.avgGradeSatisfaction,
                teachingSkill: evaluation.avgTeachingSkill,
                gains: evaluation.avgGains,
                lifeBalance: evaluation.avgLifeBalance
            ),
            evaluationCount: Int(evaluation.evaluationCount ?? 0)
        )
    }
}

extension Components.Schemas.LectureDto {
    var lectureSearchResult: LectureSearchResult {
        LectureSearchResult(
            info: EvaluationLectureInfo(
                brief: EvaluationLectureBrief(
                    id: EvaluationLectureID(id),
                    title: title?.trimmingCharacters(in: .whitespaces) ?? "",
                    instructor: instructor?.nilIfBlank
                ),
                department: department?.nilIfBlank,
                academicYear: academicYear?.nilIfBlank,
                classification: classification?.nilIfBlank,
                credit: credit.map(Int.init)
            ),
            averageRating: evaluation.avgRating,
            evaluationCount: Int(evaluation.evaluationCount ?? 0)
        )
    }
}

extension Components.Schemas.LectureAndSemesterLecturesResponse {
    var writeTarget: EvaluationWriteTarget {
        EvaluationWriteTarget(
            lecture: EvaluationLectureBrief(
                id: EvaluationLectureID(id),
                title: title?.trimmingCharacters(in: .whitespaces) ?? "",
                instructor: instructor?.nilIfBlank
            ),
            semesterLectures:
                semesterLectures
                .compactMap { dto in
                    (try? Quarter(year: dto.year, semester: dto.semester)).map {
                        SemesterLecture(
                            id: SemesterLectureID(dto.id),
                            quarter: $0,
                            hasMyEvaluation: dto.myEvaluationExists
                        )
                    }
                }
                .sorted { $0.quarter > $1.quarter }
        )
    }
}

extension EvaluationScores {
    /// Returns `nil` unless all four criteria are present, as with evaluations migrated from the legacy service.
    fileprivate init?(gradeSatisfaction: Double?, teachingSkill: Double?, gains: Double?, lifeBalance: Double?) {
        guard let gradeSatisfaction, let teachingSkill, let gains, let lifeBalance else { return nil }
        self.init(
            gradeSatisfaction: gradeSatisfaction,
            teachingSkill: teachingSkill,
            gains: gains,
            lifeBalance: lifeBalance
        )
    }
}

extension LectureEvaluation.Permissions {
    fileprivate init(isModifiable: Bool, isReportable: Bool) {
        self = []
        if isModifiable { insert(.modify) }
        if isReportable { insert(.report) }
    }
}

extension Quarter {
    fileprivate init(year: some BinaryInteger, semester: some BinaryInteger) throws {
        guard let semester = Semester(rawValue: Int(semester)) else { throw EvaluationError.invalidResponse }
        self.init(year: Int(year), semester: semester)
    }
}

extension String {
    fileprivate var nilIfBlank: String? {
        trimmingCharacters(in: .whitespaces).isEmpty ? nil : self
    }
}
