//
//  DiaryRouter.swift
//  SNUTT
//
//  Created by 최유림 on 9/7/25.
//

import Alamofire
import Foundation

enum DiaryRouter: Router {
    var baseURL: URL {
        URL(string: NetworkConfiguration.serverV1BaseURL + "/diary")!
    }

    case fetchMyDiaryList
    case uploadDiary(diary: DiaryDto)
    case fetchDailyClassTypeList
    case getQuestionnaire(classType: QuestionnaireRequestDto)
    case deleteDiary(diaryId: String)

    var method: HTTPMethod {
        switch self {
        case .fetchMyDiaryList:
            return .get
        case .uploadDiary:
            return .post
        case .fetchDailyClassTypeList:
            return .get
        case .getQuestionnaire:
            return .post
        case .deleteDiary:
            return .delete
        }
    }

    var path: String {
        switch self {
        case .fetchMyDiaryList:
            return "/my"
        case .uploadDiary:
            return ""
        case .fetchDailyClassTypeList:
            return "/dailyClassTypes"
        case .getQuestionnaire:
            return "/questionnaire"
        case let .deleteDiary(diaryId):
            return "/\(diaryId)"
        }
    }

    var parameters: Parameters? {
        switch self {
        case .fetchMyDiaryList:
            return nil
        case let .uploadDiary(diary):
            print(diary.asDictionary())
            return diary.asDictionary()
        case .fetchDailyClassTypeList:
            return nil
        case let .getQuestionnaire(classType):
            print(classType.asDictionary())
            return classType.asDictionary()
        case let .deleteDiary(diaryId):
            return nil
        }
    }
}
