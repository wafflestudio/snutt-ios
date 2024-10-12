//
//  BundleInfoDictionaryDependency.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import Foundation
@_spi(Internals) import DependenciesAdditionsBasics

public extension DependencyValues {
    var infoPlist: BundleInfoDictionary {
        get { self[BundleInfoDictionary.self] }
        set { self[BundleInfoDictionary.self] = newValue }
    }
}

public struct BundleInfoDictionary: Sendable {
    public subscript(bundle: Bundle = .main, key key: String) -> String? {
        bundle.object(forInfoDictionaryKey: key) as? String
    }
}

extension BundleInfoDictionary: DependencyKey {
    public static var liveValue: BundleInfoDictionary {
        BundleInfoDictionary()
    }

    public static var testValue: BundleInfoDictionary {
        BundleInfoDictionary()
    }
}
