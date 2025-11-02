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
    func fetchDailyClassTypeList() async throws -> [ClassCategoryDto]
    func fetchQuestionnaireList(for lectureId: String, from dailyClassTypes: [ClassCategoryDto]) async throws -> DiaryQuestionnaire
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
        
    }
    
    func fetchDailyClassTypeList() async throws -> [ClassCategoryDto] {
        return try await diaryRepository.fetchDailyClassTypes()
    }
    
    func fetchQuestionnaireList(for lectureId: String, from dailyClassTypes: [ClassCategoryDto]) async throws -> DiaryQuestionnaire {
        let dto = try await diaryRepository.fetchQuestionnaireList(from: .init(lectureId: lectureId, dailyClassTypes: dailyClassTypes.map({ $0.name })))
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
    func fetchDailyClassTypeList() async throws -> [ClassCategoryDto] { return [] }
    func fetchQuestionnaireList(for lectureId: String, from dailyClassTypes: [ClassCategoryDto]) async throws -> DiaryQuestionnaire { return .preview }
    func deleteDiary(_ diaryId: String) async throws {}
}
