//
//  LectureDiaryAPIRepository.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import APIClientInterface
import Dependencies
import Foundation
import TimetableInterface

struct LectureDiaryAPIRepository: LectureDiaryRepository {
    @Dependency(\.apiClient) private var apiClient

    init() {}

    public func fetchDiaryList(quarter: Quarter) async throws -> [DiarySummary] {
        // TODO: Implement with OpenAPI client
        // Example: let response = try await apiClient.getDiaryList(year: quarter.year, semester: quarter.semester.rawValue)
        // Convert OpenAPI DTO to DiarySummary here
        return []
    }

    public func fetchQuestionnaire() async throws -> [QuestionItem] {
        // TODO: Implement with OpenAPI client
        // Example: let response = try await apiClient.getQuestionnaire(...)
        // Convert OpenAPI DTO to QuestionItem here
        return []
    }

    public func submitDiary(_ submission: DiarySubmission) async throws {
        // TODO: Implement with OpenAPI client
        // Convert DiarySubmission to OpenAPI DTO here
        // Example: let dto = convertToDTO(submission)
        // _ = try await apiClient.submitDiary(dto)
    }

    public func deleteDiary(diaryID: String) async throws {
        // TODO: Implement with OpenAPI client
        // Example: _ = try await apiClient.deleteDiary(id: diaryID)
    }
}

// MARK: - DTO Conversion (Infra layer only)

// TODO: Add conversion functions when OpenAPI spec is available
// Example:
// private extension DiarySummary {
//     init(dto: Components.Schemas.DiaryDto) {
//         self.init(
//             id: dto.id,
//             lectureTitle: dto.lectureTitle,
//             ...
//         )
//     }
// }
