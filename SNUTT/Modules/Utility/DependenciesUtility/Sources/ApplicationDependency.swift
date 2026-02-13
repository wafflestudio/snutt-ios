//
//  ApplicationDependency.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import DependenciesAdditions
import UIKit

extension Application {
    @MainActor public func dismissKeyboard() {
        _ = sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
