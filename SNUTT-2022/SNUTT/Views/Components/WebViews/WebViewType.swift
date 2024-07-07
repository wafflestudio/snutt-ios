//
//  WebViewType.swift
//  SNUTT
//
//  Created by 최유림 on 2022/10/01.
//

import Foundation

enum WebViewConnectionState {
    case error
    case success
}

enum WebViewType {
    case developerInfo
    case termsOfService
    case privacyPolicy
    case review
    case reviewDetail(id: Int)

    var baseURL: String {
        switch self {
        case .review, .reviewDetail:
            return NetworkConfiguration.snuevBaseURL
        default:
            return NetworkConfiguration.serverBaseURL
        }
    }

    var path: String {
        switch self {
        case .developerInfo:
            return "/member"
        case .termsOfService:
            return "/terms_of_service"
        case .privacyPolicy:
            return "/privacy_policy"
        case .review:
            return ""
        case let .reviewDetail(id):
            return "/detail/?id=\(id)&on_back=close"
        }
    }

    var url: URL {
        URL(string: baseURL + path)!
    }
}
