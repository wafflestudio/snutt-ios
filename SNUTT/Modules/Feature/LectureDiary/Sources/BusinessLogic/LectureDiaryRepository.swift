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
    func fetchClassTypeList() async throws -> [AnswerOption]
    func fetchDiaryList() async throws -> [DiarySubmissionsOfYearSemester]
    func fetchQuestionnaire(for lectureID: String, with classTypes: [String]) async throws -> [QuestionItem]
    func submitDiary(_ submission: DiarySubmission) async throws
    func deleteDiary(diaryID: String) async throws
}
