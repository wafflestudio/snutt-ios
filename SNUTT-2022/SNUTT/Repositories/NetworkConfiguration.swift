//
//  NetworkConfiguration.swift
//  SNUTT
//
//  Created by 최유림 on 2022/08/24.
//

import Foundation
import SwiftUI

struct NetworkConfiguration {
    static let serverBaseURL: String = Bundle.main.infoDictionary?["API_SERVER_URL"] as! String
    static let serverV1BaseURL: String = serverBaseURL + "/v1"
    static let snuevBaseURL: String = Bundle.main.infoDictionary?["SNUEV_WEB_URL"] as! String

    static func getCookie(name: String, value: String) -> HTTPCookie? {
        return HTTPCookie(properties: [
            .domain: NetworkConfiguration.snuevBaseURL.replacingOccurrences(of: "https://", with: ""),
            .path: "/",
            .name: name,
            .value: value,
            .expires: Date(timeIntervalSince1970: Date().timeIntervalSince1970 + pow(10, 9) * 2),
        ])
    }

    static func getCookiesFrom(accessToken: String) -> [HTTPCookie] {
        guard let tokenCookie = getCookie(name: "x-access-token", value: accessToken),
              let apiKeyCookie = getCookie(name: AppMetadata.apiKey.key, value: AppMetadata.apiKey.value),
              let osTypeCookie = getCookie(name: AppMetadata.osType.key, value: AppMetadata.osType.value),
              let osVersionCookie = getCookie(name: AppMetadata.osVersion.key, value: AppMetadata.osVersion.value),
              let appVersionCookie = getCookie(name: AppMetadata.appVersion.key, value: AppMetadata.appVersion.value),
              let appTypeCookie = getCookie(name: AppMetadata.appType.key, value: AppMetadata.appType.value),
              let buildNumberCookie = getCookie(name: AppMetadata.buildNumber.key, value: AppMetadata.buildNumber.value)
        else { return [] }

        return [apiKeyCookie, tokenCookie, osTypeCookie, osVersionCookie, appVersionCookie, appTypeCookie, buildNumberCookie]
    }
}
