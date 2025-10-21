//
//  AuthRepositoryTests.swift
//  SNUTTTests
//
//  Created by 박신홍 on 2022/09/24.
//

import Alamofire
@testable import SNUTT
import XCTest

class AuthRepositoryTests: XCTestCase {
    var repository: AuthRepository!

    let testId = "snuttiostest123"
    let testPW = "snuttiostest123"
    override func setUp() async throws {
        repository = AuthRepository(session: await .test)
    }
    
    func testLoginWithId() async throws {
        do {
            let _ = try await repository.loginWithLocalId(localId: testId, localPassword: testPW)
        } catch {
            XCTFail(error.asSTError?.title ?? "")
        }
    }
}
