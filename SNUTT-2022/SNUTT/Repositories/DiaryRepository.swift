//
//  DiaryRepository.swift
//  SNUTT
//
//  Created by 최유림 on 10/24/25.
//

import Alamofire
import Foundation

protocol DiaryRepositoryProtocol {
    func fetchDiaryList() async throws -> [DiarySummaryListDto]
    func submitDiary(_ diary: DiaryDto) async throws
    func fetchDailyClassTypes() async throws -> [ClassCategoryDto]
    func fetchQuestionnaireList(from classTypeList: DiaryQuestionnaireRequestDto) async throws -> DiaryQuestionnaireResponseDto
    func deleteDiary(_ diaryId: String) async throws
}

class DiaryRepository: DiaryRepositoryProtocol {
    private let session: Session

    init(session: Session) {
        self.session = session
    }

    func fetchDiaryList() async throws -> [DiarySummaryListDto] {
        return try await session
            .request(DiaryRouter.fetchMyDiaryList)
            .serializingDecodable([DiarySummaryListDto].self)
            .handlingError()
    }
    
    func submitDiary(_ diary: DiaryDto) async throws {
        try await session
            .request(DiaryRouter.uploadDiary(diary: diary))
            .serializingString()
            .handlingError()
    }
    
    func fetchDailyClassTypes() async throws -> [ClassCategoryDto] {
        return try await session
            .request(DiaryRouter.fetchDailyClassTypeList)
            .serializingDecodable([ClassCategoryDto].self)
            .handlingError()
    }
    
    func fetchQuestionnaireList(from classTypeList: DiaryQuestionnaireRequestDto) async throws -> DiaryQuestionnaireResponseDto {
        return try await session
            .request(DiaryRouter.getQuestionnaireList(classType: classTypeList))
            .serializingDecodable(DiaryQuestionnaireResponseDto.self)
            .handlingError()
    }
    
    func deleteDiary(_ diaryId: String) async throws {
        try await session.request(DiaryRouter.deleteDiary(diaryId: diaryId))
            .serializingString()
            .handlingError()
    }
}
