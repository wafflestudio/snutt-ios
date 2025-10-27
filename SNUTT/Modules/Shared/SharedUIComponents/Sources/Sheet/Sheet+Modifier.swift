//
//  Sheet+Modifier.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import SwiftUI

private typealias SheetPresentationContext = HUDPresentationContext<Sheet<AnyView>>
private typealias SheetPresentationKey = HUDPresentationKey<Sheet<AnyView>>

extension View {
    public func overlaySheet() -> some View {
        modifier(HUDPresentationModifier<Sheet<AnyView>>())
    }

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

extension SheetConfiguration {
    fileprivate static var preview: Self {
        SheetConfiguration(orientation: .left(maxWidth: 300))
    }
}

#Preview {
    @Previewable @State var isPresented = false
    ZStack {
        Color.black.opacity(0.1).ignoresSafeArea()

        Button("Sheet is presented: \(isPresented.description)") {
            isPresented.toggle()
        }
        .padding()
        .customSheet(
            isPresented: $isPresented,
            configuration: .preview
        ) {
            Color.blue
        }
    }
    .overlaySheet()
}
