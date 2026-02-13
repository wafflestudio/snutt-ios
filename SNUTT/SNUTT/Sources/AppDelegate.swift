//
//  AppDelegate.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import FacebookCore
import Firebase
import UIKit

/// The application delegate for SNUTT.
///
/// ## Overview
/// Coordinates app-level initialization and lifecycle management.
///
/// ## Architecture
/// Responsibilities are separated into focused extensions:
/// - ``AppDelegate+ThirdPartySDKs``: Firebase and Facebook initialization
/// - ``AppDelegate+Notifications``: Notification lifecycle, FCM handling, and URL scheme routing
///
/// ## Initialization Flow
/// 1. `setupThirdPartySDKs` - Firebase and Facebook
/// 2. `setupNotificationSystem` - APNs and FCM
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Configuration

    /// Returns the Firebase configuration plist name based on build configuration.
    ///
    /// - **Debug**: `GoogleServiceDebugInfo.plist` (dev Firebase project)
    /// - **Release**: `GoogleServiceReleaseInfo.plist` (prod Firebase project)
    ///
    /// Ensures dev/prod data isolation for analytics, crash reports, and push notifications.
    internal var firebaseConfigName: String {
        #if DEBUG
            return "GoogleServiceDebugInfo"
        #else
            return "GoogleServiceReleaseInfo"
        #endif
    }

    // MARK: - Application Lifecycle

    /// Called when the app finishes launching.
    ///
    /// ## Initialization Sequence
    /// 1. Third-party SDKs (Firebase, Facebook)
    /// 2. Notification system (APNs, FCM)
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions options: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Initialize third-party SDKs (Firebase, Facebook)
        let facebookInitialized = setupThirdPartySDKs(
            application: application,
            launchOptions: options
        )

        // Setup notification system (APNs, FCM)
        setupNotificationSystem(application: application)

        return facebookInitialized
    }

    // MARK: - Scene Management

    /// Configures a new scene session.
    ///
    /// Returns configuration with `SceneDelegate` as delegate class.
    /// SceneDelegate handles window setup and URL routing.
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let sceneConfig = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = SceneDelegate.self
        return sceneConfig
    }

    /// Called when scene sessions are discarded.
    ///
    /// Currently no cleanup needed - resources managed by scene delegates and ViewModels.
    func application(
        _ application: UIApplication,
        didDiscardSceneSessions sceneSessions: Set<UISceneSession>
    ) {
        // No cleanup needed
    }
}
