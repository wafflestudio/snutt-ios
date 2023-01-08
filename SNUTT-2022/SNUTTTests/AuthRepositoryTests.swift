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
    let repository = AuthRepository(session: .test)

    let testId = "snuttiostest123"
    let testPW = "snuttiostest123"

    func testRegisterAndLoginWithId() async throws {
        do {
            let _ = try await repository.registerWithLocalId(localId: testId, localPassword: testPW, email: "test@example.com")
        } catch {
            if error.asSTError?.code == .DUPLICATE_ID {
                // 중복 발생 가능
                return
            }
            XCTFail(error.asSTError?.title ?? "")
        }

        do {
            let _ = try await repository.registerWithLocalId(localId: testId, localPassword: testPW, email: "test@example.com")
        } catch {
            XCTAssertEqual(error.asSTError?.code, .DUPLICATE_ID)
        }

        do {
            let _ = try await repository.loginWithLocalId(localId: testId, localPassword: testPW)
        } catch {
            XCTFail(error.asSTError?.title ?? "")
        }
    }
}
