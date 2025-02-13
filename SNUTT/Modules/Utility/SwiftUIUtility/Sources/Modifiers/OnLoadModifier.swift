//
//  OnLoadModifier.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SwiftUI

extension View {
    /// Adds an (asynchronous) action to perform when this view is loaded.
    public func onLoad(perform action: (() async -> Void)? = nil) -> some View {
        modifier(OnLoadModifier(perform: action))
    }
}

private struct OnLoadModifier: ViewModifier {
    @State private var didLoad = false
    private let action: (() async -> Void)?

    init(perform action: (() async -> Void)? = nil) {
        self.action = action
    }

    func body(content: Content) -> some View {
        content.task {
            if didLoad == false {
                didLoad = true
                await action?()
            }
        }
    }
}
