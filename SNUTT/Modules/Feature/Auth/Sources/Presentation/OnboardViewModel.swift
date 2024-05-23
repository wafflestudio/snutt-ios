//
//  OnboardViewModel.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import Combine
import Dependencies
import struct SwiftUI.NavigationPath
import AuthInterface
import UIKit

@MainActor
final class OnboardViewModel: ObservableObject {
    @Dependency(\.authUseCase) private var authUseCase
    @Published var paths = [OnboardDetailSceneTypes]()

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
