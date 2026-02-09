//
//  AppMetadata.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import Dependencies
import DependenciesAdditions
import DependenciesUtility
import Foundation

extension DependencyValues {
    public var appMetadata: AppMetadata {
        get { self[AppMetadata.self] }
        set { self[AppMetadata.self] = newValue }
    }
}

public struct AppMetadata: Sendable {
    @Dependency(\.bundleInfo.shortVersion) private var marketingVersion
    @Dependency(\.bundleInfo.version) private var buildVersion
    @Dependency(\.syncDevice.systemVersion) private var systemVersion
    @Dependency(\.syncDevice.modelName) private var modelName
    @Dependency(\.syncDevice.identifierForVendor) private var identifierForVendor

    public subscript(key: AppMetadataKey) -> String {
        switch key {
        case .appVersion:
            marketingVersion
        case .appType:
            #if DEBUG
                "debug"
            #else
                "release"
            #endif
        case .osType:
            "ios"
        case .osVersion:
            systemVersion
        case .deviceID:
            identifierForVendor ?? ""
        case .deviceModel:
            modelName
        case .apiKey:
            Bundle.main.object(forInfoDictionaryKey: "API_KEY") as! String
        case .buildNumber:
            buildVersion
        case .apiURL:
            Bundle.main.object(forInfoDictionaryKey: "API_SERVER_URL") as! String
        }
    }

    public var apiURL: URL {
        URL(string: self[.apiURL])!
    }
}

extension AppMetadata: DependencyKey {
    public static let liveValue: AppMetadata = .init()
    public static let testValue: AppMetadata = .init()
}

public enum AppMetadataKey: CaseIterable {
    case appVersion, appType, osType, osVersion, apiKey, buildNumber, deviceID, deviceModel, apiURL

    public var keyForHeader: String? {
        switch self {
        case .appVersion:
            "x-app-version"
        case .appType:
            "x-app-type"
        case .osType:
            "x-os-type"
        case .osVersion:
            "x-os-version"
        case .apiKey:
            "x-access-apikey"
        case .buildNumber:
            "x-build-number"
        case .deviceID:
            "x-device-id"
        case .deviceModel:
            "x-device-model"
        case .apiURL:
            nil
        }
    }
}
