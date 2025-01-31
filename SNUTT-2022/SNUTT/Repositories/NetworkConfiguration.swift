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
    static let themeBaseURL: String = Bundle.main.infoDictionary?["THEME_WEB_URL"] as! String

    private static func createCookie(domain: String, name: String, value: String) -> HTTPCookie? {
        return HTTPCookie(properties: [
            .domain: domain.replacingOccurrences(of: "https://", with: ""),
            .path: "/",
            .name: name,
            .value: value,
            .expires: Date(timeIntervalSinceNow: pow(10, 9) * 2),
        ])
    }

    static func getSnuevCookie(name: String, value: String) -> HTTPCookie? {
        return createCookie(domain: snuevBaseURL, name: name, value: value)
    }

    static func getThemeCookie(name: String, value: String) -> HTTPCookie? {
        return createCookie(domain: themeBaseURL, name: name, value: value)
    }

    static func getCookiesFrom(accessToken: String, type: String) -> [HTTPCookie] {
        let cookieProvider: (String, String) -> HTTPCookie? = {
            switch type {
            case "review":
                return getSnuevCookie
            case "theme":
                return getThemeCookie
            default:
                return { _, _ in nil }
            }
        }()

        guard let tokenCookie = cookieProvider("x-access-token", accessToken),
              let apiKeyCookie = cookieProvider(AppMetadata.apiKey.key, AppMetadata.apiKey.value),
              let osTypeCookie = cookieProvider(AppMetadata.osType.key, AppMetadata.osType.value),
              let osVersionCookie = cookieProvider(AppMetadata.osVersion.key, AppMetadata.osVersion.value),
              let appVersionCookie = cookieProvider(AppMetadata.appVersion.key, AppMetadata.appVersion.value),
              let appTypeCookie = cookieProvider(AppMetadata.appType.key, AppMetadata.appType.value),
              let buildNumberCookie = cookieProvider(AppMetadata.buildNumber.key, AppMetadata.buildNumber.value)
        else { return [] }

        return [apiKeyCookie, tokenCookie, osTypeCookie, osVersionCookie, appVersionCookie, appTypeCookie, buildNumberCookie]
    }
}
