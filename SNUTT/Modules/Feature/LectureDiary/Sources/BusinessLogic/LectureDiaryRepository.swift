//
//  LectureDiaryRepository.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Foundation
import Spyable
import TimetableInterface

@Spyable
public protocol LectureDiaryRepository: Sendable {
    func fetchDiaryList(quarter: Quarter) async throws -> [DiarySummary]
    func fetchQuestionnaire() async throws -> [QuestionItem]
    func submitDiary(_ submission: DiarySubmission) async throws
    func deleteDiary(diaryID: String) async throws
}
