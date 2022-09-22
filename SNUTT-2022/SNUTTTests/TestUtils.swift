//
//  TestUtils.swift
//  SNUTTTests
//
//  Created by 박신홍 on 2022/09/22.
//

import Foundation
import Alamofire

extension Session {
    static var test: Session {
        Session(interceptor: Interceptor(authStorage: TestAuthStorage()), eventMonitors: [Logger()])
    }
}

class TestAuthStorage: AuthStorage {
    var apiKey: ApiKey = Bundle.main.infoDictionary?["API_KEY"] as! String
    var accessToken: AccessToken = Bundle.main.infoDictionary?["ACCESS_TOKEN_TEST"] as! String
}

struct TestUtils {
    static func randomString(length: Int) -> String {
        let letters = "qwertyuiopasdfghjklzxcvbnm!@#$%^&*()_+"
        return String((0..<length).map{ _ in letters.randomElement()! })
      }
}
