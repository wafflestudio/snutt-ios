//
//  OnLoadModifier.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/10/07.
//

import SwiftUI

struct ViewDidLoadModifier: ViewModifier {
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

extension View {
    /// Adds an (asynchronous) action to perform when this view is loaded.
    func onLoad(perform action: (() async -> Void)? = nil) -> some View {
        modifier(ViewDidLoadModifier(perform: action))
    }
}
