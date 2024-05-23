//
//  BundleInfoDictionaryDependency.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import Foundation
@_spi(Internals) import DependenciesAdditionsBasics

extension DependencyValues {
    public var infoPlist: BundleInfoDictionary {
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
    static public var liveValue: BundleInfoDictionary {
        BundleInfoDictionary()
    }
    static public var testValue: BundleInfoDictionary {
        BundleInfoDictionary()
    }
}
