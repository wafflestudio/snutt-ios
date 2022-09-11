//
//  AuthRepositoryTests.swift
//  SNUTTTests
//
//  Created by 박신홍 on 2022/09/24.
//

import Alamofire
import XCTest

class AuthRepositoryTests: XCTestCase {
    let repository = AuthRepository(session: .test)

    let testId = "snuttiostest123"
    let testPW = "snuttiostest123"

    func testRegisterAndLoginWithId() async throws {
        do {
            let _ = try await repository.registerWithId(id: testId, password: testPW, email: "")
        } catch {
            if error.asSTError == .DUPLICATE_ID {
                // 중복 발생 가능
                return
            }
            XCTFail(error.asSTError?.errorTitle ?? "")
        }

        do {
            let _ = try await repository.registerWithId(id: testId, password: testPW, email: "")
        } catch {
            XCTAssertEqual(error.asSTError, .DUPLICATE_ID)
        }

        do {
            let _ = try await repository.loginWithId(id: testId, password: testPW)
        } catch {
            XCTFail(error.asSTError?.errorTitle ?? "")
        }
    }
}