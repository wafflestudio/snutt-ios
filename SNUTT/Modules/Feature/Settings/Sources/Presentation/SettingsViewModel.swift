//
//  SettingsViewModel.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Dependencies
import Foundation
import Observation
import SharedAppMetadata

@Observable final class SettingsViewModel {
    @ObservationIgnored
    @Dependency(\.appMetadata) private var appMetadata: AppMetadata
    
    var appVersion: String {
        appMetadata[.appVersion]
    }
}
