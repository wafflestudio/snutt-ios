//
//  AppDelegate+ThirdPartySDKs.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import FacebookCore
import Firebase
import UIKit
import os.log

private let logger = Logger(subsystem: "com.wafflestudio.snutt", category: "AppDelegate")

/// Manages initialization of third-party SDKs (Firebase, Facebook).
///
/// ## Overview
/// Handles setup of external dependencies for analytics, push notifications, and social authentication.
///
/// ## Firebase Configuration
/// Uses environment-specific configuration files:
/// - **Debug**: `GoogleServiceDebugInfo.plist` (dev Firebase project)
/// - **Release**: `GoogleServiceReleaseInfo.plist` (prod Firebase project)
///
/// This ensures dev/prod data isolation.
extension AppDelegate {
    /// Sets up all third-party SDKs required for app functionality.
    ///
    /// - Parameters:
    ///   - application: The UIApplication instance
    ///   - launchOptions: Launch options from didFinishLaunchingWithOptions
    /// - Returns: True if Facebook SDK initialized successfully
    func setupThirdPartySDKs(
        application: UIApplication,
        launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        configureFirebase()
        return configureFacebookSDK(application: application, launchOptions: launchOptions)
    }

    /// Configures Firebase with environment-specific settings.
    ///
    /// ## When Called
    /// Called during app launch before notification system setup.
    ///
    /// ## Why Separate Plists?
    /// - Prevents test data from polluting production analytics
    /// - Isolates dev push notification testing
    /// - Uses different APNs certificates per environment
    private func configureFirebase() {
        guard let filePath = Bundle.main.path(forResource: firebaseConfigName, ofType: "plist"),
            let configOption = FirebaseOptions(contentsOfFile: filePath)
        else {
            assertionFailure("Firebase configuration not found: \(firebaseConfigName).plist")
            return
        }

        FirebaseApp.configure(options: configOption)
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        logger.info("Firebase configured with \(self.firebaseConfigName)")
    }

    /// Initializes Facebook SDK for Facebook Login integration.
    private func configureFacebookSDK(
        application: UIApplication,
        launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        FacebookCore.ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
    }
}
