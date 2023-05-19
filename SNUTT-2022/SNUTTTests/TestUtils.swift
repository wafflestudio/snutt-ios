//
//  TestUtils.swift
//  SNUTTTests
//
//  Created by 박신홍 on 2022/09/22.
//

import Alamofire
import Foundation
@testable import SNUTT

extension Session {
    @MainActor static var test: Session {
        Session(interceptor: Interceptor(userState: AppState.test.user), eventMonitors: [Logger()])
    }
}

extension AppState {
    static var test: AppState = {
        let state = AppState()
        state.user.accessToken = TestStorage.accessToken
        return state
    }()
}

struct TestStorage {
    static var apiKey: String = Bundle.main.infoDictionary?["API_KEY"] as! String
    static var accessToken: String = Bundle.main.infoDictionary?["ACCESS_TOKEN_TEST"] as! String
}

struct TestUtils {
    static func randomString(length: Int, asciiOnly: Bool = false) -> String {
        let letters = "qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890\(asciiOnly ? "" : "!@#$%^&*()_+")"
        return String((0 ..< length).map { _ in letters.randomElement()! })
    }
}
