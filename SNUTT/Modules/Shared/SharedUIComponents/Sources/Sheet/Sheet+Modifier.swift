//
//  SheetExample2.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import SwiftUI

public typealias SheetPresentationContext = HUDPresentationContext<Sheet<AnyView>>
public typealias SheetPresentationKey = HUDPresentationKey<Sheet<AnyView>>

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
                content: {
                    Sheet(isPresented: isPresented, configuration: configuration) {
                        AnyView(content())
                    }
                }
            )
        )
    }
}

// MARK: Preview

private struct RootPreview: View {
    @State private var sheetContext: SheetPresentationContext?

    public init() {}

    public var body: some View {
        ZStack {
            SomeSubview()
            sheetContext?.makeHUDView()
        }
        .onPreferenceChange(SheetPresentationKey.self) { value in
            Task { @MainActor in
                sheetContext = value
            }
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
