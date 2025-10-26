//
//  HUDPresentationModifier.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SwiftUI

/// A ViewModifier that enables child views to present HUD-style overlays (sheets, popups, etc.)
/// using SwiftUI's preference key system.
///
/// How it works:
/// 1. Child views use `.preference(key: HUDPresentationKey.self, value: context)` to send presentation requests
/// 2. This modifier listens via `.onPreferenceChange` and captures the latest context
/// 3. The context is then displayed as an overlay on top of the content
///
/// This pattern allows deep child views to trigger overlays at a parent level without passing bindings down.
struct HUDPresentationModifier<HUDContent: View>: ViewModifier {
    @State private var hudPresentationContext: HUDPresentationContext<HUDContent>?

    func body(content: Content) -> some View {
        content
            .overlay {
                // Display the HUD content when context exists and isPresented is true
                hudPresentationContext?.makeHUDView()
            }
            .onPreferenceChange(HUDPresentationKey<HUDContent>.self) { value in
                // Update context when child views request presentation changes
                Task { @MainActor in
                    hudPresentationContext = value
                }
            }
    }
}
