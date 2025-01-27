//
//  LocalizedErrorCode.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Foundation

public enum LocalizedErrorCode: Int, LocalizedError {
    case serverFault = 0x0000
    case noNetwork = 0x0001
    case unknownError = 0x0002

    case noFBIdOrToken = 0x1001
    case noYearOrSemester = 0x1002
    case notEnoughToCreateTimetable = 0x1003
    case noLectureInput = 0x1004
    case noLectureId = 0x1005
    case attemptToModifyIdentity = 0x1006
    case noTimetableTitle = 0x1007
    case noRegistrationId = 0x1008
    case invalidTimemask = 0x1009
    case invalidColor = 0x100A
    case noLectureTitle = 0x100B
    case invalidTimeJSON = 0x100C
    case invalidNotificationDetail = 0x100D
    case noGoogleToken = 0x100E
    case noKakaoToken = 0x100F
    case noLocalId = 0x1015
    case noEmail = 0x1018
    case invalidSemesterForVacancyNotification = 40005
    case invalidNickname = 40008

    case wrongApiKey = 0x2000
    case noUserToken = 0x2001
    case wrongUserToken = 0x2002
    case noAdminPrivilege = 0x2003
    case wrongId = 0x2004
    case wrongPassword = 0x2005
    case wrongFBToken = 0x2006
    case unknownApp = 0x2007
    case wrongAppleToken = 0x2008
    case noPasswordResetRequest = 0x2009
    case expiredPasswordResetCode = 0x2010
    case wrongPasswordResetCode = 0x2011

    case invalidId = 0x3000
    case invalidPassword = 0x3001
    case duplicateId = 0x3002
    case duplicateTimetableTitle = 0x3003
    case duplicateLecture = 0x3004
    case alreadyLocalAccount = 0x3005
    case alreadyFBAccount = 0x3006
    case notLocalAccount = 0x3007
    case notFBAccount = 0x3008
    case fbIdWithSomeoneElse = 0x3009
    case wrongSemester = 0x300A
    case notCustomLecture = 0x300B
    case lectureTimeOverlap = 0x300C
    case isCustomLecture = 0x300D
    case userHasNoFCMKey = 0x300E
    case invalidEmail = 0x300F

    case tagNotFound = 0x4000
    case timetableNotFound = 0x4001
    case lectureNotFound = 0x4002
    case refLectureNotFound = 0x4003
    case userNotFound = 0x4004
    case colorlistNotFound = 0x4005
    case emailNotFound = 0x4006

    case cantChangeOthersTheme = 0x5001
    case invalidLectureTime = 0x5002
    case invalidRnBundle = 0x5003
    case duplicateThemeName = 40904
    case deeplinkLectureNotFound = 0x5004
    case deeplinkTimetableNotFound = 0x5005
    case deeplinkBookmarkNotFound = 0x5006
    case deeplinkProcessFailed = 0x5007

    case alreadyVerifiedAccount = 0x9000
    case alreadyVerifiedEmail = 0x9001
    case duplicateVacancyNotification = 40900
    case duplicateEmail = 40901

    case excessiveEmailVerificationRequest = 0xA000

    public var errorDescription: String? {
        switch self {
        case .serverFault:
            APIClientInterfaceStrings.errorDescriptionServerFault
        case .noNetwork:
            APIClientInterfaceStrings.errorDescriptionNoNetwork
        case .unknownError:
            APIClientInterfaceStrings.errorDescriptionUnknownError
        case .noFBIdOrToken, .noGoogleToken, .noKakaoToken:
            APIClientInterfaceStrings.errorDescriptionNoToken
        case .noYearOrSemester, .notEnoughToCreateTimetable, .wrongSemester:
            APIClientInterfaceStrings.errorDescriptionInvalidSemester
        case .noLectureInput, .noLectureId, .noLectureTitle:
            APIClientInterfaceStrings.errorDescriptionNoLecture
        case .attemptToModifyIdentity:
            APIClientInterfaceStrings.errorDescriptionModifyIdentity
        case .noTimetableTitle:
            APIClientInterfaceStrings.errorDescriptionTimetableTitle
        case .duplicateTimetableTitle:
            APIClientInterfaceStrings.errorDescriptionDuplicateTimetableTitle
        case .noRegistrationId:
            APIClientInterfaceStrings.errorDescriptionNoRegistrationId
        case .invalidTimemask:
            APIClientInterfaceStrings.errorDescriptionInvalidTimemask
        case .invalidColor:
            APIClientInterfaceStrings.errorDescriptionInvalidColor
        case .invalidTimeJSON, .invalidLectureTime, .lectureTimeOverlap:
            APIClientInterfaceStrings.errorDescriptionInvalidTime
        case .invalidNotificationDetail:
            APIClientInterfaceStrings.errorDescriptionInvalidNotification
        case .noLocalId, .duplicateId:
            APIClientInterfaceStrings.errorDescriptionId
        case .noEmail, .duplicateEmail, .invalidEmail:
            APIClientInterfaceStrings.errorDescriptionEmail
        case .invalidNickname:
            APIClientInterfaceStrings.errorDescriptionInvalidNickname
        case .wrongApiKey:
            APIClientInterfaceStrings.errorDescriptionWrongApiKey
        case .noUserToken, .wrongUserToken:
            APIClientInterfaceStrings.errorDescriptionUserToken
        case .noAdminPrivilege:
            APIClientInterfaceStrings.errorDescriptionAdminPrivilege
        case .wrongId, .wrongPassword, .wrongFBToken, .wrongAppleToken:
            APIClientInterfaceStrings.errorDescriptionLogin
        case .unknownApp:
            APIClientInterfaceStrings.errorDescriptionUnknownApp
        case .noPasswordResetRequest, .expiredPasswordResetCode, .wrongPasswordResetCode:
            APIClientInterfaceStrings.errorDescriptionPasswordReset
        case .invalidId, .invalidPassword:
            APIClientInterfaceStrings.errorDescriptionInvalidCredentials
        case .alreadyLocalAccount, .alreadyFBAccount:
            APIClientInterfaceStrings.errorDescriptionAlreadyAccount
        case .notLocalAccount, .notFBAccount:
            APIClientInterfaceStrings.errorDescriptionNotAccount
        case .fbIdWithSomeoneElse:
            APIClientInterfaceStrings.errorDescriptionFbIdWithSomeoneElse
        case .notCustomLecture, .isCustomLecture:
            APIClientInterfaceStrings.errorDescriptionCustomLecture
        case .userHasNoFCMKey:
            APIClientInterfaceStrings.errorDescriptionNoFCMKey
        case .tagNotFound, .timetableNotFound, .lectureNotFound, .refLectureNotFound, .userNotFound, .colorlistNotFound, .emailNotFound:
            APIClientInterfaceStrings.errorDescriptionNotFound
        case .cantChangeOthersTheme:
            APIClientInterfaceStrings.errorDescriptionCantChangeTheme
        case .invalidRnBundle:
            APIClientInterfaceStrings.errorDescriptionInvalidRnBundle
        case .duplicateThemeName:
            APIClientInterfaceStrings.errorDescriptionDuplicateThemeName
        case .deeplinkLectureNotFound, .deeplinkTimetableNotFound, .deeplinkBookmarkNotFound:
            APIClientInterfaceStrings.errorDescriptionDeeplinkNotFound
        case .deeplinkProcessFailed:
            APIClientInterfaceStrings.errorDescriptionDeeplinkProcessFailed
        case .alreadyVerifiedAccount, .alreadyVerifiedEmail:
            APIClientInterfaceStrings.errorDescriptionAlreadyVerified
        case .duplicateVacancyNotification:
            APIClientInterfaceStrings.errorDescriptionDuplicateVacancyNotification
        case .excessiveEmailVerificationRequest:
            APIClientInterfaceStrings.errorDescriptionExcessiveEmailVerification
        case .invalidSemesterForVacancyNotification:
            APIClientInterfaceStrings.errorDescriptionInvalidSemesterForVacancyNotification
        case .duplicateLecture:
            APIClientInterfaceStrings.errorDescriptionDuplicateLecture
        }
    }

    public var failureReason: String? {
        switch self {
        case .serverFault:
            APIClientInterfaceStrings.errorFailureReasonServerFault
        case .noNetwork:
            APIClientInterfaceStrings.errorFailureReasonNoNetwork
        case .unknownError:
            APIClientInterfaceStrings.errorFailureReasonUnknownError
        case .noFBIdOrToken, .noGoogleToken, .noKakaoToken:
            APIClientInterfaceStrings.errorFailureReasonNoToken
        case .noYearOrSemester, .notEnoughToCreateTimetable, .wrongSemester:
            APIClientInterfaceStrings.errorFailureReasonInvalidSemester
        case .noLectureInput, .noLectureId, .noLectureTitle:
            APIClientInterfaceStrings.errorFailureReasonNoLecture
        case .attemptToModifyIdentity:
            APIClientInterfaceStrings.errorFailureReasonModifyIdentity
        case .noTimetableTitle:
            APIClientInterfaceStrings.errorFailureReasonTimetableTitle
        case .duplicateTimetableTitle:
            APIClientInterfaceStrings.errorFailureReasonDuplicateTimetableTitle
        case .noRegistrationId:
            APIClientInterfaceStrings.errorFailureReasonNoRegistrationId
        case .invalidTimemask:
            APIClientInterfaceStrings.errorFailureReasonInvalidTimemask
        case .invalidColor:
            APIClientInterfaceStrings.errorFailureReasonInvalidColor
        case .invalidTimeJSON, .invalidLectureTime, .lectureTimeOverlap:
            APIClientInterfaceStrings.errorFailureReasonInvalidTime
        case .invalidNotificationDetail:
            APIClientInterfaceStrings.errorFailureReasonInvalidNotification
        case .noLocalId, .duplicateId:
            APIClientInterfaceStrings.errorFailureReasonId
        case .noEmail, .duplicateEmail, .invalidEmail:
            APIClientInterfaceStrings.errorFailureReasonEmail
        case .invalidNickname:
            APIClientInterfaceStrings.errorFailureReasonInvalidNickname
        case .wrongApiKey:
            APIClientInterfaceStrings.errorFailureReasonWrongApiKey
        case .noUserToken, .wrongUserToken:
            APIClientInterfaceStrings.errorFailureReasonUserToken
        case .noAdminPrivilege:
            APIClientInterfaceStrings.errorFailureReasonAdminPrivilege
        case .wrongId, .wrongPassword, .wrongFBToken, .wrongAppleToken:
            APIClientInterfaceStrings.errorFailureReasonLogin
        case .unknownApp:
            APIClientInterfaceStrings.errorFailureReasonUnknownApp
        case .noPasswordResetRequest, .expiredPasswordResetCode, .wrongPasswordResetCode:
            APIClientInterfaceStrings.errorFailureReasonPasswordReset
        case .invalidId, .invalidPassword:
            APIClientInterfaceStrings.errorFailureReasonInvalidCredentials
        case .alreadyLocalAccount, .alreadyFBAccount:
            APIClientInterfaceStrings.errorFailureReasonAlreadyAccount
        case .notLocalAccount, .notFBAccount:
            APIClientInterfaceStrings.errorFailureReasonNotAccount
        case .fbIdWithSomeoneElse:
            APIClientInterfaceStrings.errorFailureReasonFbIdWithSomeoneElse
        case .notCustomLecture, .isCustomLecture:
            APIClientInterfaceStrings.errorFailureReasonCustomLecture
        case .userHasNoFCMKey:
            APIClientInterfaceStrings.errorFailureReasonNoFCMKey
        case .tagNotFound, .timetableNotFound, .lectureNotFound, .refLectureNotFound, .userNotFound, .colorlistNotFound, .emailNotFound:
            APIClientInterfaceStrings.errorFailureReasonNotFound
        case .cantChangeOthersTheme:
            APIClientInterfaceStrings.errorFailureReasonCantChangeTheme
        case .invalidRnBundle:
            APIClientInterfaceStrings.errorFailureReasonInvalidRnBundle
        case .duplicateThemeName:
            APIClientInterfaceStrings.errorFailureReasonDuplicateThemeName
        case .deeplinkLectureNotFound, .deeplinkTimetableNotFound, .deeplinkBookmarkNotFound:
            APIClientInterfaceStrings.errorFailureReasonDeeplinkNotFound
        case .deeplinkProcessFailed:
            APIClientInterfaceStrings.errorFailureReasonDeeplinkProcessFailed
        case .alreadyVerifiedAccount, .alreadyVerifiedEmail:
            APIClientInterfaceStrings.errorFailureReasonAlreadyVerified
        case .duplicateVacancyNotification:
            APIClientInterfaceStrings.errorFailureReasonDuplicateVacancyNotification
        case .excessiveEmailVerificationRequest:
            APIClientInterfaceStrings.errorFailureReasonExcessiveEmailVerification
        case .invalidSemesterForVacancyNotification:
            APIClientInterfaceStrings.errorFailureReasonInvalidSemesterForVacancyNotification
        case .duplicateLecture:
            APIClientInterfaceStrings.errorFailureReasonDuplicateLecture
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .serverFault:
            APIClientInterfaceStrings.errorRecoverySuggestionServerFault
        case .noNetwork:
            APIClientInterfaceStrings.errorRecoverySuggestionNoNetwork
        case .unknownError:
            APIClientInterfaceStrings.errorRecoverySuggestionUnknownError
        case .noFBIdOrToken, .noGoogleToken, .noKakaoToken:
            APIClientInterfaceStrings.errorRecoverySuggestionNoToken
        case .noYearOrSemester, .notEnoughToCreateTimetable, .wrongSemester:
            APIClientInterfaceStrings.errorRecoverySuggestionInvalidSemester
        case .noLectureInput, .noLectureId, .noLectureTitle:
            APIClientInterfaceStrings.errorRecoverySuggestionNoLecture
        case .attemptToModifyIdentity:
            APIClientInterfaceStrings.errorRecoverySuggestionModifyIdentity
        case .noTimetableTitle:
            APIClientInterfaceStrings.errorRecoverySuggestionTimetableTitle
        case .duplicateTimetableTitle:
            APIClientInterfaceStrings.errorRecoverySuggestionDuplicateTimetableTitle
        case .noRegistrationId:
            APIClientInterfaceStrings.errorRecoverySuggestionNoRegistrationId
        case .invalidTimemask:
            APIClientInterfaceStrings.errorRecoverySuggestionInvalidTimemask
        case .invalidColor:
            APIClientInterfaceStrings.errorRecoverySuggestionInvalidColor
        case .invalidTimeJSON, .invalidLectureTime, .lectureTimeOverlap:
            APIClientInterfaceStrings.errorRecoverySuggestionInvalidTime
        case .invalidNotificationDetail:
            APIClientInterfaceStrings.errorRecoverySuggestionInvalidNotification
        case .noLocalId, .duplicateId:
            APIClientInterfaceStrings.errorRecoverySuggestionId
        case .noEmail, .duplicateEmail, .invalidEmail:
            APIClientInterfaceStrings.errorRecoverySuggestionEmail
        case .invalidNickname:
            APIClientInterfaceStrings.errorRecoverySuggestionInvalidNickname
        case .wrongApiKey:
            nil
        case .noUserToken, .wrongUserToken:
            APIClientInterfaceStrings.errorRecoverySuggestionUserToken
        case .noAdminPrivilege:
            APIClientInterfaceStrings.errorRecoverySuggestionAdminPrivilege
        case .wrongId, .wrongPassword, .wrongFBToken, .wrongAppleToken:
            APIClientInterfaceStrings.errorRecoverySuggestionLogin
        case .unknownApp:
            APIClientInterfaceStrings.errorRecoverySuggestionUnknownApp
        case .noPasswordResetRequest, .expiredPasswordResetCode, .wrongPasswordResetCode:
            APIClientInterfaceStrings.errorRecoverySuggestionPasswordReset
        case .invalidId, .invalidPassword:
            APIClientInterfaceStrings.errorRecoverySuggestionInvalidCredentials
        case .alreadyLocalAccount, .alreadyFBAccount:
            APIClientInterfaceStrings.errorRecoverySuggestionAlreadyAccount
        case .notLocalAccount, .notFBAccount:
            APIClientInterfaceStrings.errorRecoverySuggestionNotAccount
        case .fbIdWithSomeoneElse:
            APIClientInterfaceStrings.errorRecoverySuggestionFbIdWithSomeoneElse
        case .notCustomLecture, .isCustomLecture:
            APIClientInterfaceStrings.errorRecoverySuggestionCustomLecture
        case .userHasNoFCMKey:
            APIClientInterfaceStrings.errorRecoverySuggestionNoFCMKey
        case .tagNotFound, .timetableNotFound, .lectureNotFound, .refLectureNotFound, .userNotFound, .colorlistNotFound, .emailNotFound:
            APIClientInterfaceStrings.errorRecoverySuggestionNotFound
        case .cantChangeOthersTheme:
            APIClientInterfaceStrings.errorRecoverySuggestionCantChangeTheme
        case .invalidRnBundle:
            APIClientInterfaceStrings.errorRecoverySuggestionInvalidRnBundle
        case .duplicateThemeName:
            APIClientInterfaceStrings.errorRecoverySuggestionDuplicateThemeName
        case .deeplinkLectureNotFound, .deeplinkTimetableNotFound, .deeplinkBookmarkNotFound:
            APIClientInterfaceStrings.errorRecoverySuggestionDeeplinkNotFound
        case .deeplinkProcessFailed:
            APIClientInterfaceStrings.errorRecoverySuggestionDeeplinkProcessFailed
        case .alreadyVerifiedAccount, .alreadyVerifiedEmail:
            nil
        case .duplicateVacancyNotification:
            nil
        case .excessiveEmailVerificationRequest:
            APIClientInterfaceStrings.errorRecoverySuggestionExcessiveEmailVerification
        case .invalidSemesterForVacancyNotification:
            nil
        case .duplicateLecture:
            nil
        }
    }
}
