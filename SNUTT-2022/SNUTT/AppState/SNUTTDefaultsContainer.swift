//
//  SNUTTDefaultsContainer.swift
//  SNUTT
//
//  Created by 최유림 on 2022/08/04.
//

import Foundation

struct SNUTTDefaultsContainer {
    enum DataType {
        case token
        case userId
        case userLocalId
        case userFBName

        case currentTimetable
        case timetableConfig

        case apiKey
        case registeredFCMToken
        case appVersion

        case shouldShowBadge
        case shouldDeleteFCMInfos

        var key: String {
            switch self {
            case .token: return "token"
            case .userId: return "userId"
            case .userLocalId: return "userLocalId"
            case .userFBName: return "userFBName"
            case .currentTimetable: return "currentTimetable"
            case .timetableConfig: return "timetableConfig"
            case .apiKey: return "apiKey"
            case .registeredFCMToken: return "registeredFCMToken"
            case .appVersion: return "appVersion"
            case .shouldShowBadge: return "shouldShowBadge"
            case .shouldDeleteFCMInfos: return "shouldDeleteFCMInfos"
            }
        }
    }

    @SNUTTDefaults(.token, value: "") var token: String?
    @SNUTTDefaults(.userId, value: "") var userId: String?
    @SNUTTDefaults(.userLocalId, value: nil) var userLocalId: String?
    @SNUTTDefaults(.userFBName, value: "") var userFBName: String?

    @SNUTTDefaults(.currentTimetable, value: nil) var currentTimetable: TimetableDto?
    @SNUTTDefaults(.timetableConfig, value: TimetableConfiguration()) var timetableConfig: TimetableConfiguration

    @SNUTTDefaults(.apiKey, value: "") var apiKey: String
    @SNUTTDefaults(.registeredFCMToken, value: "") var registeredFCMToken: String?
    @SNUTTDefaults(.appVersion, value: "") var appVersion: String

    @SNUTTDefaults(.shouldShowBadge, value: false) var shouldShowBadge: Bool
    @SNUTTDefaults(.shouldDeleteFCMInfos, value: "") var shouldDeleteFCMInfos: String? // STFCMInfoList
}
