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

    init(_ errorCode: ErrorCode) {
        title = errorCode.errorTitle
        content = errorCode.errorMessage
        code = errorCode
    }

    init(_ errorCode: ErrorCode, content: String) {
        title = errorCode.errorTitle
        self.content = content
        code = errorCode
    }
}

enum ErrorCode: Int {
    case SERVER_FAULT = 0x0000
    case NO_NETWORK = 0x0001
    case UNKNOWN_ERROR = 0x0002

    /* 401 - Request was invalid */
    case NO_FB_ID_OR_TOKEN = 0x1001
    case NO_YEAR_OR_SEMESTER = 0x1002
    case NOT_ENOUGH_TO_CREATE_TIMETABLE = 0x1003
    case NO_LECTURE_INPUT = 0x1004
    case NO_LECTURE_ID = 0x1005
    case ATTEMPT_TO_MODIFY_IDENTITIY = 0x1006
    case NO_TIMETABLE_TITLE = 0x1007
    case NO_REGISTRATION_ID = 0x1008
    case INVALID_TIMEMASK = 0x1009
    case INVALID_COLOR = 0x100A
    case NO_LECTURE_TITLE = 0x100B
    case INVALID_TIMEJSON = 0x100C
    case INVALID_NOTIFICATION_DETAIL = 0x100D
    case NO_LOCAL_ID = 0x1015
    case NO_EMAIL = 0x1018
    case INVALID_SEMESTER_FOR_VACANCY_NOTIFICATION = 40005
    case INVALID_NICKNAME = 40008

    /* 403 - Authorization-related */
    case WRONG_API_KEY = 0x2000
    case NO_USER_TOKEN = 0x2001
    case WRONG_USER_TOKEN = 0x2002
    case NO_ADMIN_PRIVILEGE = 0x2003
    case WRONG_ID = 0x2004
    case WRONG_PASSWORD = 0x2005
    case WRONG_FB_TOKEN = 0x2006
    case UNKNOWN_APP = 0x2007
    case WRONG_APPLE_TOKEN = 0x2008
    case NO_PASSWORD_RESET_REQUEST = 0x2009
    case EXPIRED_PASSWORD_RESET_CODE = 0x2010
    case WRONG_PASSWORD_RESET_CODE = 0x2011

    /* 403 - Restrictions */
    case INVALID_ID = 0x3000
    case INVALID_PASSWORD = 0x3001
    case DUPLICATE_ID = 0x3002
    case DUPLICATE_TIMETABLE_TITLE = 0x3003
    case DUPLICATE_LECTURE = 0x3004
    case ALREADY_LOCAL_ACCOUNT = 0x3005
    case ALREADY_FB_ACCOUNT = 0x3006
    case NOT_LOCAL_ACCOUNT = 0x3007
    case NOT_FB_ACCOUNT = 0x3008
    case FB_ID_WITH_SOMEONE_ELSE = 0x3009
    case WRONG_SEMESTER = 0x300A
    case NOT_CUSTOM_LECTURE = 0x300B
    case LECTURE_TIME_OVERLAP = 0x300C
    case IS_CUSTOM_LECTURE = 0x300D
    case USER_HAS_NO_FCM_KEY = 0x300E
    case INVALID_EMAIL = 0x300F
    case EMAIL_NOT_VERIFIED = 0x3011

    /* 404 - NOT found */
    case TAG_NOT_FOUND = 0x4000
    case TIMETABLE_NOT_FOUND = 0x4001
    case LECTURE_NOT_FOUND = 0x4002
    case REF_LECTURE_NOT_FOUND = 0x4003
    case USER_NOT_FOUND = 0x4004
    case COLORLIST_NOT_FOUND = 0x4005
    case EMAIL_NOT_FOUND = 0x4006

    /* Client-side Errors */
    case CANT_CHANGE_OTHERS_THEME = 0x5001
    case INVALID_LECTURE_TIME = 0x5002
    case INVALID_RN_BUNDLE = 0x5003

    /* 409 - Conflicts (Email Verification related) */
    case ALREADY_VERIFIED_ACCOUNT = 0x9000
    case ALREADY_VERIFIED_EMAIL = 0x9001
    case DUPLICATE_VACANCY_NOTIFICATION = 40900
    case DUPLICATE_EMAIL = 40901

    /* 429 - Too many requests */
    case EXCESSIVE_EMAIL_VERIFICATION_REQUEST = 0xA000

    var errorTitle: String {
        switch self {
        case .SERVER_FAULT:
            return "SERVER_ERROR".localized
        case .NO_NETWORK:
            return "네트워크 오류"
        case .NO_FB_ID_OR_TOKEN,
             .NO_YEAR_OR_SEMESTER,
             .NOT_ENOUGH_TO_CREATE_TIMETABLE,
             .NO_LECTURE_INPUT,
             .NO_LECTURE_ID,
             .ATTEMPT_TO_MODIFY_IDENTITIY,
             .NO_TIMETABLE_TITLE,
             .NO_REGISTRATION_ID,
             .INVALID_TIMEMASK,
             .INVALID_NOTIFICATION_DETAIL,
             .INVALID_COLOR,
             .NO_LECTURE_TITLE,
             .NO_EMAIL,
             .NO_PASSWORD_RESET_REQUEST,
             .CANT_CHANGE_OTHERS_THEME,
             .INVALID_RN_BUNDLE,
             .EXPIRED_PASSWORD_RESET_CODE:
            return "요청 실패"
        case .EMAIL_NOT_VERIFIED:
            return "인증 필요"
        case .NO_USER_TOKEN,
             .WRONG_API_KEY,
             .WRONG_USER_TOKEN,
             .NO_ADMIN_PRIVILEGE:
            return "권한 문제"
        case .WRONG_ID,
             .WRONG_PASSWORD,
             .WRONG_APPLE_TOKEN,
             .WRONG_FB_TOKEN:
            return "로그인 실패"
        case .UNKNOWN_APP:
            return "앱 정보 실패"
        case .INVALID_ID,
             .INVALID_PASSWORD,
             .INVALID_EMAIL,
             .DUPLICATE_ID,
             .DUPLICATE_TIMETABLE_TITLE,
             .DUPLICATE_LECTURE,
             .DUPLICATE_EMAIL,
             .ALREADY_LOCAL_ACCOUNT,
             .ALREADY_FB_ACCOUNT,
             .ALREADY_VERIFIED_ACCOUNT,
             .ALREADY_VERIFIED_EMAIL,
             .DUPLICATE_VACANCY_NOTIFICATION,
             .EXCESSIVE_EMAIL_VERIFICATION_REQUEST,
             .NOT_LOCAL_ACCOUNT,
             .NOT_FB_ACCOUNT,
             .FB_ID_WITH_SOMEONE_ELSE,
             .WRONG_SEMESTER,
             .WRONG_PASSWORD_RESET_CODE,
             .NOT_CUSTOM_LECTURE,
             .IS_CUSTOM_LECTURE,
             .USER_HAS_NO_FCM_KEY,
             .INVALID_TIMEJSON,
             .INVALID_SEMESTER_FOR_VACANCY_NOTIFICATION,
             .INVALID_NICKNAME,
             .NO_LOCAL_ID:
            return "잘못된 요청"
        case .LECTURE_TIME_OVERLAP,
             .INVALID_LECTURE_TIME:
            return "시간대 겹침"
        case .TAG_NOT_FOUND,
             .TIMETABLE_NOT_FOUND,
             .LECTURE_NOT_FOUND,
             .REF_LECTURE_NOT_FOUND,
             .USER_NOT_FOUND,
             .EMAIL_NOT_FOUND,
             .COLORLIST_NOT_FOUND:
            return "찾지 못함"
        case .UNKNOWN_ERROR:
            return "알 수 없는 오류"
        }
    }

    var errorMessage: String {
        switch self {
        case .SERVER_FAULT:
            return "서버에 문제가 있으니, 잠시 후 다시 시도해주세요."
        case .INVALID_RN_BUNDLE:
            return "리소스를 다운로드하는 도중 문제가 발생했습니다."
        case .NO_NETWORK:
            return "네트워크가 불안정합니다."
        case .NO_USER_TOKEN:
            return "로그인 정보가 없습니다."
        case .NO_FB_ID_OR_TOKEN:
            return "페이스북 로그인 정보에 문제가 생겼습니다."
        case .NO_YEAR_OR_SEMESTER:
            return "올바른 년도와 학기를 정해주세요."
        case .NOT_ENOUGH_TO_CREATE_TIMETABLE:
            return "올바른 년도, 학기, 이름을 정해주세요."
        case .NO_LECTURE_INPUT:
            return "올바른 강좌를 넣어주세요."
        case .NO_LECTURE_ID:
            return "업데이트 하려는 강좌의 id가 존재하지 않습니다."
        case .ATTEMPT_TO_MODIFY_IDENTITIY:
            return "강좌 번호나 분반 정보는 바꿀 수 없습니다."
        case .NO_TIMETABLE_TITLE:
            return "시간표 이름이 주어지지 않았습니다."
        case .NO_REGISTRATION_ID:
            return "알림을 주기 위한 절차에 문제가 생겼습니다."
        case .INVALID_TIMEMASK:
            return "잘못된 비트마스크 형식입니다."
        case .INVALID_COLOR:
            return "올바른 색상 또는 색상 형식이 아닙니다."
        case .NO_LECTURE_TITLE:
            return "강좌에 이름을 넣어주세요."
        case .WRONG_API_KEY:
            return "잘못된 API Key 입니다."
        case .WRONG_USER_TOKEN:
            return "잘못된 유저 토큰입니다."
        case .NO_ADMIN_PRIVILEGE:
            return "어드민 유저가 아닙니다."
        case .WRONG_ID:
            return "잘못된 ID입니다."
        case .WRONG_PASSWORD:
            return "잘못된 비밀번호입니다."
        case .WRONG_FB_TOKEN:
            return "잘못된 페이스북 토큰입니다."
        case .NO_LOCAL_ID:
            return "아이디를 입력해주세요."
        case .NO_EMAIL:
            return "이메일을 입력해주세요."
        case .UNKNOWN_APP:
            return "앱 버전 정보를 가져오는 것을 실패했습니다."
        case .INVALID_ID:
            return "ID는 영문자와 숫자로 이루어진 4~32자여야 합니다."
        case .INVALID_NICKNAME:
            return "사용할 수 없는 닉네임입니다."
        case .INVALID_TIMEJSON:
            return "강의 시간은 0보다 큰 숫자여야 합니다."
        case .INVALID_PASSWORD:
            return "비밀번호는 최소 하나의 숫자와 하나의 영문자를 포함하는 6~20자여야 합니다."
        case .INVALID_EMAIL:
            return "올바른 이메일을 입력해주세요."
        case .INVALID_NOTIFICATION_DETAIL:
            return "알림을 불러올 수 없습니다. 잠시 후 다시 시도해주세요."
        case .DUPLICATE_ID:
            return "이미 존재하는 ID입니다."
        case .DUPLICATE_TIMETABLE_TITLE:
            return "이미 존재하는 시간표 이름입니다."
        case .DUPLICATE_LECTURE:
            return "이미 추가된 강좌입니다."
        case .ALREADY_LOCAL_ACCOUNT:
            return "이미 ID와 비밀번호가 등록되어 있습니다."
        case .ALREADY_FB_ACCOUNT:
            return "이미 페이스북 계정이 연동되어 있습니다."
        case .NOT_LOCAL_ACCOUNT:
            return "등록된 ID와 비밀번호가 없습니다."
        case .NOT_FB_ACCOUNT:
            return "연동된 페이스북 계정이 없습니다."
        case .FB_ID_WITH_SOMEONE_ELSE:
            return "이미 다른 계정에 연동이 되어있습니다."
        case .USER_HAS_NO_FCM_KEY:
            return "유저에게 등록된 Firebase 키가 존재하지 않습니다."
        case .TAG_NOT_FOUND:
            return "없는 태그입니다."
        case .TIMETABLE_NOT_FOUND:
            return "없는 시간표입니다."
        case .LECTURE_NOT_FOUND:
            return "없는 강좌입니다."
        case .WRONG_SEMESTER:
            return "올바르지 않은 학기입니다."
        case .NOT_CUSTOM_LECTURE:
            return "직접 만든 강좌가 아닙니다."
        case .LECTURE_TIME_OVERLAP:
            return "시간표의 시간과 겹칩니다."
        case .INVALID_LECTURE_TIME:
            return "강의 시간이 서로 겹칩니다."
        case .IS_CUSTOM_LECTURE:
            return "직접 만든 강좌입니다."
        case .REF_LECTURE_NOT_FOUND:
            return "수강편람에서 찾을 수 없는 강좌입니다."
        case .USER_NOT_FOUND:
            return "해당 정보로 가입된 사용자가 없습니다."
        case .EMAIL_NOT_FOUND:
            return "등록된 이메일이 없습니다."
        case .COLORLIST_NOT_FOUND:
            return "색상 목록을 찾을 수 없습니다."
        case .CANT_CHANGE_OTHERS_THEME:
            return "현재 시간표의 테마만 변경할 수 있습니다."
        case .UNKNOWN_ERROR:
            return "알 수 없는 오류가 발생했습니다."
        case .WRONG_APPLE_TOKEN:
            return "애플 계정으로 로그인하지 못했습니다."
        case .EMAIL_NOT_VERIFIED:
            return "강의평 확인을 위해 이메일 인증이 필요합니다. 이메일 인증을 진행하시겠습니까?"
        case .NO_PASSWORD_RESET_REQUEST:
            return "비밀번호 재설정을 다시 시도해주세요."
        case .EXPIRED_PASSWORD_RESET_CODE:
            return "만료된 인증코드입니다."
        case .WRONG_PASSWORD_RESET_CODE:
            return "잘못된 인증코드입니다."
        case .ALREADY_VERIFIED_ACCOUNT:
            return "이메일 인증이 완료된 계정입니다."
        case .DUPLICATE_EMAIL:
            return "이미 사용 중인 이메일입니다."
        case .ALREADY_VERIFIED_EMAIL:
            return "다른 계정에서 인증된 이메일입니다."
        case .DUPLICATE_VACANCY_NOTIFICATION:
            return "이미 빈자리 알림을 받고 있는 강의입니다."
        case .INVALID_SEMESTER_FOR_VACANCY_NOTIFICATION:
            return "해당 학기의 빈자리 알림 신청 기간이 종료되었습니다."
        case .EXCESSIVE_EMAIL_VERIFICATION_REQUEST:
            return "인증 요청 횟수가 초과되었습니다. 3분 후 인증 요청을 다시 해주시기 바랍니다."
        }
    }
}

extension Error {
    var asSTError: STError? {
        self as? STError
    }
}
