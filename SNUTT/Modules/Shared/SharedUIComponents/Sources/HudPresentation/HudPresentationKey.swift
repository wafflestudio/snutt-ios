//
//  HUDPresentationKey.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SwiftUI

public struct HUDPresentationKey<Content: View>: PreferenceKey {
    public typealias Value = HUDPresentationContext<Content>
    public static var defaultValue: Value {
        HUDPresentationContext(
            id: UUID(),
            isPresented: .constant(false),
            content: nil
        )
    }

    public static func reduce(value: inout Value, nextValue: () -> Value) {
        value = if value.content == nil || !value.isPresented.wrappedValue {
            nextValue()
        } else {
            value
        }
    }
}

public struct HUDPresentationContext<Content: View>: Equatable, Sendable {
    let id: UUID
    let isPresented: Binding<Bool>
    let content: (@MainActor () -> Content)?

    @MainActor
    @ViewBuilder public func makeHUDView() -> some View {
        if isPresented.wrappedValue, let content {
            content()
        } else {
            EmptyView()
        }
    }

    public static func == (lhs: HUDPresentationContext, rhs: HUDPresentationContext) -> Bool {
        lhs.id == rhs.id
    }
}
