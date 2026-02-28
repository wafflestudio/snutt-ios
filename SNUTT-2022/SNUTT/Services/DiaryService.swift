//
//  DiaryService.swift
//  SNUTT
//
//  Created by 최유림 on 10/24/25.
//

import SwiftUI

@MainActor
protocol DiaryServiceProtocol: Sendable {
    func fetchDiaryList() async throws -> [DiaryListPerSemester]
    func submitDiary(_ diary: DiaryDto) async throws
    func fetchDailyClassTypeList() async throws -> [AnswerOption]
    func fetchQuestionnaire(for lectureId: String, from dailyClassTypes: [AnswerOption]) async throws -> DiaryQuestionnaire
    func deleteDiary(_ diaryId: String) async throws
}

struct DiaryService: DiaryServiceProtocol {
    var appState: AppState
    var webRepositories: AppEnvironment.WebRepositories

    func fetchDiaryList() async throws -> [DiaryListPerSemester] {
        let dto = try await diaryRepository.fetchDiaryList()
        return dto.map { .init(from: $0) }
    }
    
    func submitDiary(_ diary: DiaryDto) async throws {
        try await diaryRepository.submitDiary(diary)
    }
    
    func fetchDailyClassTypeList() async throws -> [AnswerOption] {
        let dto = try await diaryRepository.fetchDailyClassTypes()
        return dto.enumerated().map { .init(id: $0.0, content: $0.1.name) }
    }
    
    func fetchQuestionnaire(for lectureId: String, from dailyClassTypes: [AnswerOption]) async throws -> DiaryQuestionnaire {
        let dto = try await diaryRepository.fetchQuestionnaire(from: .init(lectureId: lectureId, dailyClassTypes: dailyClassTypes.map(\.content)))
        return .init(from: dto)
    }
    
    func deleteDiary(_ diaryId: String) async throws {
        try await diaryRepository.deleteDiary(diaryId)
    }
    
    private var diaryRepository: DiaryRepositoryProtocol {
        webRepositories.diaryRepository
    }
}

class FakeDiaryService: DiaryServiceProtocol {
    func fetchDiaryList() async throws -> [DiaryListPerSemester] { return [] }
    func submitDiary(_ diary: DiaryDto) async throws {}
    func fetchDailyClassTypeList() async throws -> [AnswerOption] { return [] }
    func fetchQuestionnaire(for lectureId: String, from dailyClassTypes: [AnswerOption]) async throws -> DiaryQuestionnaire { return .preview }
    func deleteDiary(_ diaryId: String) async throws {}
}
