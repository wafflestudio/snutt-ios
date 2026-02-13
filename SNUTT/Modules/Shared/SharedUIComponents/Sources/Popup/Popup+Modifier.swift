//
//  Popup+Modifier.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SwiftUI

private typealias PopupPresentationContext = HUDPresentationContext<Popup<AnyView>>
private typealias PopupPresentationKey = HUDPresentationKey<Popup<AnyView>>

extension View {
    public func overlayPopup() -> some View {
        modifier(HUDPresentationModifier<Popup<AnyView>>())
    }

    public func customPopup<Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @MainActor @escaping () -> Content
    ) -> some View {
        preference(
            key: PopupPresentationKey.self,
            value: .init(
                id: .init(),
                isPresented: isPresented,
                content: {
                    Popup(isPresented: isPresented) {
                        AnyView(content())
                    }
                }
            )
        )
    }
}
