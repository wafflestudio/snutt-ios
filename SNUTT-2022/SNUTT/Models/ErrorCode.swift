//
//  ErrorCode.swift
//  SNUTT
//
//  Created by Rajin on 2017. 1. 30..
//  Copyright © 2017년 WaffleStudio. All rights reserved.
//

import Foundation

struct STError: Error {
    let code: ErrorCode
    let title: String
    let content: String
    let underlyingError: [String: String]?

    init(_ errorCode: ErrorCode) {
        title = errorCode.errorTitle
        content = errorCode.errorMessage
        code = errorCode
        underlyingError = nil
    }

    init(_ errorCode: ErrorCode, content: String, detail: [String: String]?) {
        title = errorCode.errorTitle
        self.content = content
        code = errorCode
        underlyingError = detail
    }
}

enum ErrorCode: Int {
    /* Server-defined Errors */
    case SERVER_FAULT = 0x0000
    case NO_NETWORK = 0x0001
    case NO_USER_TOKEN = 0x2001
    case WRONG_USER_TOKEN = 0x2002
    case LECTURE_TIME_OVERLAP = 0x300C
    case INVALID_EMAIL = 0x300F

    /* Client-side Errors */
    case CANT_CHANGE_OTHERS_THEME = 0x5001
    case INVALID_LECTURE_TIME = 0x5002
    case INVALID_RN_BUNDLE = 0x5003
    case DEEPLINK_LECTURE_NOT_FOUND = 0x5004
    case DEEPLINK_TIMETABLE_NOT_FOUND = 0x5005
    case DEEPLINK_BOOKMARK_NOT_FOUND = 0x5006
    case DEEPLINK_PROCESS_FAILED = 0x5007
    case TIMETABLE_NOT_FOUND = 0x5008
    case SOCIAL_LOGIN_FAILED = 0x5009

    var errorTitle: String {
        switch self {
        case .SERVER_FAULT:
            return "SERVER_ERROR".localized
        case .NO_NETWORK:
            return "네트워크 오류"
        case .INVALID_EMAIL,
             .CANT_CHANGE_OTHERS_THEME,
             .INVALID_RN_BUNDLE,
             .DEEPLINK_LECTURE_NOT_FOUND,
             .DEEPLINK_TIMETABLE_NOT_FOUND,
             .DEEPLINK_BOOKMARK_NOT_FOUND,
             .DEEPLINK_PROCESS_FAILED,
             .TIMETABLE_NOT_FOUND:
            return "요청 실패"
        case .LECTURE_TIME_OVERLAP,
             .INVALID_LECTURE_TIME:
            return "시간대 겹침"
        case .NO_USER_TOKEN,
             .WRONG_USER_TOKEN,
             .SOCIAL_LOGIN_FAILED:
            return "로그인 실패"
        }
    }

    var errorMessage: String {
        switch self {
        case .SERVER_FAULT:
            return "서버에 문제가 있으니, 잠시 후 다시 시도해주세요"
        case .NO_USER_TOKEN,
             .WRONG_USER_TOKEN:
            return "앱을 완전히 종료한 뒤, 로그인을 다시 시도해 주시기 바랍니다"
        case .INVALID_RN_BUNDLE:
            return "리소스를 다운로드하는 도중 문제가 발생했습니다"
        case .NO_NETWORK:
            return "네트워크가 불안정합니다. 잠시 후 다시 시도해주세요"
        case .INVALID_EMAIL:
            return "올바른 이메일을 입력해주세요"
        case .DEEPLINK_PROCESS_FAILED:
            return "올바르지 않은 정보입니다"
        case .DEEPLINK_LECTURE_NOT_FOUND:
            return "시간표에서 삭제된 강의입니다"
        case .DEEPLINK_TIMETABLE_NOT_FOUND:
            return "존재하지 않는 시간표입니다"
        case .DEEPLINK_BOOKMARK_NOT_FOUND:
            return "관심강좌에서 삭제된 강의입니다"
        case .LECTURE_TIME_OVERLAP:
            return "강좌의 시간이 올바르게 설정되었는지 확인해 주시기 바랍니다"
        case .INVALID_LECTURE_TIME:
            return "강의 시간이 서로 겹칩니다"
        case .CANT_CHANGE_OTHERS_THEME:
            return "현재 시간표의 테마만 변경할 수 있습니다"
        case .TIMETABLE_NOT_FOUND:
            return "존재하지 않는 시간표입니다"
        case .SOCIAL_LOGIN_FAILED:
            return "소셜 로그인 과정에 문제가 생겼습니다"
        }
    }
}

extension Error {
    var asSTError: STError? {
        self as? STError
    }
}
