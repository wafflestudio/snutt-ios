//
//  MigrationManager.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import AuthInterface
import Dependencies
import DependenciesAdditions
import Foundation

/// Runs app-level migrations in order and records the last completed version.
/// - Note: Add new versions to `KnownVersion` and handle them in `run()`.
struct MigrationManager {
    @Dependency(\.authUseCase) private var authUseCase
    @Dependency(\.userDefaults) private var userDefaults

    func run() {
        let lastVersion = userDefaults.string(forKey: StorageKey.lastMigratedVersion)
            .flatMap(KnownVersion.init(rawValue:))

        let pendingVersions = KnownVersion.allCases.filter { version in
            guard let lastVersion else { return true }
            return version > lastVersion
        }

        for version in pendingVersions {
            switch version {
            case .v4_0_0:
                authUseCase.migrateV3AuthIfNeeded()
            }

            userDefaults.set(version.rawValue, forKey: StorageKey.lastMigratedVersion)
        }
    }
}

private enum StorageKey {
    static let lastMigratedVersion = "lastMigratedVersion"
}
