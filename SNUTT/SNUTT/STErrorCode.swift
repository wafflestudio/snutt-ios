//
//  STErrorCode.swift
//  SNUTT
//
//  Created by Rajin on 2017. 1. 30..
//  Copyright © 2017년 WaffleStudio. All rights reserved.
//

import Foundation

public enum STErrorCode: Int {
    case SERVER_FAULT = 0x0000
    case NO_NETWORK = 0x0001

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

    /* 403 - Authorization-related */
    case WRONG_API_KEY = 0x2000
    case NO_USER_TOKEN = 0x2001
    case WRONG_USER_TOKEN = 0x2002
    case NO_ADMIN_PRIVILEGE = 0x2003
    case WRONG_ID = 0x2004
    case WRONG_PASSWORD = 0x2005
    case WRONG_FB_TOKEN = 0x2006
    case UNKNOWN_APP = 0x2007

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

    /* 404 - NOT found */
    case TAG_NOT_FOUND = 0x4000
    case TIMETABLE_NOT_FOUND = 0x4001
    case LECTURE_NOT_FOUND = 0x4002
    case REF_LECTURE_NOT_FOUND = 0x4003
    case USER_NOT_FOUND = 0x4004
    case COLORLIST_NOT_FOUND = 0x4005

    var errorTitle: String {
        switch self {
        case .SERVER_FAULT:
            return "서버 문제"
        case .NO_NETWORK:
            return "네트워킹 문제"
        case .NO_FB_ID_OR_TOKEN,
             .NO_YEAR_OR_SEMESTER,
             .NOT_ENOUGH_TO_CREATE_TIMETABLE,
             .NO_LECTURE_INPUT,
             .NO_LECTURE_ID,
             .ATTEMPT_TO_MODIFY_IDENTITIY,
             .NO_TIMETABLE_TITLE,
             .NO_REGISTRATION_ID,
             .INVALID_TIMEMASK,
             .INVALID_COLOR,
             .NO_LECTURE_TITLE:
            return "요청 실패"
        case .NO_USER_TOKEN,
             .WRONG_API_KEY,
             .WRONG_USER_TOKEN,
             .NO_ADMIN_PRIVILEGE:
            return "권한 문제"
        case .WRONG_ID,
             .WRONG_PASSWORD,
             .WRONG_FB_TOKEN:
            return "로그인 실패"
        case .UNKNOWN_APP:
            return "앱 정보 실패"
        case .INVALID_ID,
             .INVALID_PASSWORD,
             .DUPLICATE_ID,
             .DUPLICATE_TIMETABLE_TITLE,
             .DUPLICATE_LECTURE,
             .ALREADY_LOCAL_ACCOUNT,
             .ALREADY_FB_ACCOUNT,
             .NOT_LOCAL_ACCOUNT,
             .NOT_FB_ACCOUNT,
             .FB_ID_WITH_SOMEONE_ELSE,
             .WRONG_SEMESTER,
             .NOT_CUSTOM_LECTURE,
             .IS_CUSTOM_LECTURE,
             .USER_HAS_NO_FCM_KEY:
            return "잘못된 요청"
        case .TAG_NOT_FOUND,
             .TIMETABLE_NOT_FOUND,
             .LECTURE_NOT_FOUND,
             .REF_LECTURE_NOT_FOUND,
             .USER_NOT_FOUND,
             .COLORLIST_NOT_FOUND:
            return "찾지 못함"
        case .LECTURE_TIME_OVERLAP:
            return "시간대 겹침"
        }
    }

    var errorMessage: String {
        switch self {
        case .SERVER_FAULT:
            return "서버에 문제가 있으니, 잠시후 다시 시도해주세요."
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
        case .UNKNOWN_APP:
            return "앱 버전 정보를 가져오는 것을 실패했습니다."
        case .INVALID_ID:
            return "ID는 영문자와 숫자로 이루어진 4~32자여야 합니다."
        case .INVALID_PASSWORD:
            return "비밀번호는 최소 하나의 숫자와 하나의 영문자를 포함하는 6~20자여야 합니다."
        case .DUPLICATE_ID:
            return "이미 존재하는 ID입니다."
        case .DUPLICATE_TIMETABLE_TITLE:
            return "이미 존재하는 시간표 이름입니다."
        case .DUPLICATE_LECTURE:
            return "이미 넣은 강좌입니다."
        case .ALREADY_LOCAL_ACCOUNT:
            return "이미 ID와 비번이 등록되어있습니다."
        case .ALREADY_FB_ACCOUNT:
            return "이미 페이스북 계정이 연동되어있습니다."
        case .NOT_LOCAL_ACCOUNT:
            return "등록된 ID와 비번이 없습니다."
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
        case .IS_CUSTOM_LECTURE:
            return "직접 만든 강좌입니다."
        case .REF_LECTURE_NOT_FOUND:
            return "수강편람에서 찾을 수 없는 강좌입니다."
        case .USER_NOT_FOUND:
            return "유저를 찾을 수 없습니다."
        case .COLORLIST_NOT_FOUND:
            return "색상 목록을 찾을 수 없습니다."
        }
    }
}
