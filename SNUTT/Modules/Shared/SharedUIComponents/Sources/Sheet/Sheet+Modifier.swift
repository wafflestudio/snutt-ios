//
//  SheetExample2.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import SwiftUI

extension View {
    public func customSheet<Content: View>(
        isPresented: Binding<Bool>,
        configuration: SheetConfiguration,
        @ViewBuilder content: @MainActor @escaping () -> Content
    ) -> some View {
        preference(
            key: SheetPresentationKey.self,
            value: .init(
                id: .init(),
                isPresented: isPresented,
                configuration: configuration,
                content: { AnyView(content()) }
            )
        )
    }
}

public struct SheetPresentationKey: PreferenceKey {
    public typealias Value = SheetPresentationContext
    public static var defaultValue: SheetPresentationContext {
        SheetPresentationContext(
            id: UUID(),
            isPresented: .constant(false),
            configuration: .init(orientation: .left(maxWidth: 0)),
            content: nil
        )
    }
    public static func reduce(value: inout SheetPresentationContext, nextValue: () -> SheetPresentationContext) {
        value = if value.content == nil || !value.isPresented.wrappedValue {
            nextValue()
        } else {
            value
        }
    }
}

public struct SheetPresentationContext: Equatable {
    let id: UUID
    let isPresented: Binding<Bool>
    let configuration: SheetConfiguration
    let content: (@MainActor () -> AnyView)?

    @MainActor
    @ViewBuilder
    public func makeSheet() -> some View {
        if isPresented.wrappedValue, let content {
            Sheet(isPresented: isPresented, configuration: configuration, content: content)
        } else {
            EmptyView()
        }
    }

    public static func == (lhs: SheetPresentationContext, rhs: SheetPresentationContext) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: Preview

private struct RootPreview: View {
    @State private var sheetContext: SheetPresentationContext?

    public init() {}

    public var body: some View {
        ZStack {
            SomeSubview()
            sheetContext?.makeSheet()
        }
        .onPreferenceChange(SheetPresentationKey.self) { value in
            sheetContext = value
        }
    }
}

private struct SomeSubview: View {
    @State private var isPresented = false
    var body: some View {
        VStack {
            Button("Sheet is presented: \(isPresented)") {
                isPresented.toggle()
            }
            .customSheet(isPresented: $isPresented, configuration: .init(orientation: .left(maxWidth: 300))) {
                VStack {
                    Text("Sheet Content")
                }
            }

            if isPresented {
                EmptyView()
            }
        }
    }
}

#Preview {
    RootPreview()
}
