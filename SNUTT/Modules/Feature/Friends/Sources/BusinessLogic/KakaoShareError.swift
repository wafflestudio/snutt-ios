//
//  KakaoShareError.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Foundation

enum KakaoShareError: LocalizedError {
    case shareUnavailable
    case preparationFailed
    case unknownError

    var errorDescription: String? {
        switch self {
        case .shareUnavailable:
            "카카오톡 초대 기능을 사용할 수 없습니다"
        case .preparationFailed, .unknownError:
            "알 수 없는 오류가 발생했습니다"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .shareUnavailable:
            "카카오톡이 설치되어 있는지 확인해보세요."
        case .preparationFailed, .unknownError:
            "개발자 괴롭히기를 통해 문의해주세요."
        }
    }
}
