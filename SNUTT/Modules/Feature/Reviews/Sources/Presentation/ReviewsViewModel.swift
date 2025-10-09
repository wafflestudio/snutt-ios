//
//  ReviewsViewModel.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import AuthInterface
import Dependencies
import Foundation
import Observation
import SharedAppMetadata

@MainActor
@Observable
final class ReviewsViewModel {
    @ObservationIgnored
    @Dependency(\.appMetadata) private var appMetadata

    @ObservationIgnored
    @Dependency(\.authState) private var authState

    var baseURL: URL {
        (Bundle.main.infoDictionary?["SNUEV_WEB_URL"] as? String)
            .flatMap { URL(string: $0) }!
    }

    var webCookies: [HTTPCookie] {
        var cookies: [HTTPCookie?] = []
        guard let host = baseURL.host else { return [] }
        if let accessToken = authState.get(.accessToken) {
            cookies.append(
                HTTPCookie(properties: [.name: "x-access-token", .value: accessToken, .domain: host, .path: "/"])
            )
        }
        for item in AppMetadataKey.allCases {
            if let key = item.keyForHeader {
                cookies.append(
                    HTTPCookie(properties: [.name: key, .value: appMetadata[item], .domain: host, .path: "/"])
                )
            }
        }
        return cookies.compactMap(\.self)
    }
}
