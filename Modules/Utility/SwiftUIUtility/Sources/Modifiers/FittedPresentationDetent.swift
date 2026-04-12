//
//  FittedPresentationDetent.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SwiftUI

private struct FittedPresentationSizing: ViewModifier {
    @State private var contentHeight: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .onGeometryChange(for: CGFloat.self) { proxy in
                proxy.size.height
            } action: { height in
                contentHeight = height
            }
            .presentationDetents(contentHeight > 0 ? [.height(contentHeight)] : [])
            .presentationDragIndicator(.hidden)
            .presentationCompactAdaptation(horizontal: .sheet, vertical: .sheet)
    }
}

extension View {
    /// Backport of `.presentationSizing(.fitted)` for iOS 17.
    /// Measures content height and sets `presentationDetents` to fit exactly.
    @available(iOS, deprecated: 18.0, message: "Use .presentationSizing(.fitted) instead")
    public func presentationSizingFitted() -> some View {
        modifier(FittedPresentationSizing())
    }
}
