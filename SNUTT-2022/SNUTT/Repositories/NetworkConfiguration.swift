//
//  NetworkConfiguration.swift
//  SNUTT
//
//  Created by 최유림 on 2022/08/24.
//

import SwiftUI
import Foundation

struct NetworkConfiguration {
    static let serverBaseURL: String = Bundle.main.infoDictionary?["API_SERVER_URL"] as! String
    static let snuevBaseURL: String = Bundle.main.infoDictionary?["SNUEV_WEB_URL"] as! String
    static let apiKey: String = Bundle.main.infoDictionary?["API_KEY"] as! String

    static func getCookie(name: String, value: String) -> HTTPCookie? {
        return HTTPCookie(properties: [
            .domain: NetworkConfiguration.snuevBaseURL.replacingOccurrences(of: "https://", with: ""),
            .path: "/",
            .name: name,
            .value: value,
            .expires: Date(timeIntervalSince1970: Date().timeIntervalSince1970 + pow(10, 9) * 2)
        ])
    }

    static func getCookiesFrom(accessToken: String) -> [HTTPCookie] {
        guard let apiKeyCookie = getCookie(name: "x-access-apikey", value: NetworkConfiguration.apiKey),
              let tokenCookie = getCookie(name: "x-access-token", value: accessToken),
              let deviceTypeCookie = getCookie(name: "x-os-type", value: AppMetadata.osType.value ?? "ios")
        else { return [] }

        return [apiKeyCookie, tokenCookie, deviceTypeCookie]
    }
}
