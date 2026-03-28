//
//  ReviewsWebViewModel.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import AuthInterface
import Dependencies
import Foundation
import Observation
import SharedAppMetadata

@MainActor
@Observable
final class ReviewsWebViewModel {
    @ObservationIgnored
    @Dependency(\.appMetadata) private var appMetadata

    @ObservationIgnored
    @Dependency(\.authState) private var authState

    private var baseURL: URL {
        (Bundle.main.infoDictionary?["SNUEV_WEB_URL"] as? String)
            .flatMap { URL(string: $0) }!
    }

    func baseURL(for evLectureID: Int?) -> URL {
        guard let evLectureID else { return baseURL }
        return
            baseURL
            .appending(path: "detail")
            .appending(queryItems: [
                .init(name: "id", value: evLectureID.description),
                .init(name: "on_back", value: "close"),
            ])
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
