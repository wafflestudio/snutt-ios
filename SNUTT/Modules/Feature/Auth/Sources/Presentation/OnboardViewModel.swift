//
//  OnboardViewModel.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import AuthInterface
import Combine
import Dependencies
import UIKit

import struct SwiftUI.NavigationPath

@MainActor
@Observable
final class OnboardViewModel {
    @ObservationIgnored
    @Dependency(\.authUseCase) private var authUseCase
    var paths = [OnboardDetailSceneTypes]()

    func loginWithLocalId(localID: String, localPassword: String) async throws {
        do {
            try await authUseCase.loginWithLocalID(localID: localID, localPassword: localPassword)
        } catch {
            throw error
        }
    }
}

enum OnboardDetailSceneTypes {
    case loginLocal
    case registerLocal
    case findLocalID
    case resetLocalPassword
}
