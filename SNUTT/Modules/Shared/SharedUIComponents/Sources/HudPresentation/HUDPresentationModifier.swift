//
//  HUDPresentationModifier.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SwiftUI

struct HUDPresentationModifier<HUDContent: View>: ViewModifier {
    @State private var hudPresentationContext: HUDPresentationContext<HUDContent>?

    func body(content: Content) -> some View {
        content
            .overlay {
                hudPresentationContext?.makeHUDView()
            }
            .onPreferenceChange(HUDPresentationKey<HUDContent>.self) { value in
                Task { @MainActor in
                    hudPresentationContext = value
                }
            }
    }
}
