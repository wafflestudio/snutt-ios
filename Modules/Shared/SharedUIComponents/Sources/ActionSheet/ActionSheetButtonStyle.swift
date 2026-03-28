//
//  ActionSheetButtonStyle.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SwiftUI

public struct ActionSheetButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color(.label).opacity(configuration.isPressed ? 0.05 : 0))
            )
            .scaleEffect(configuration.isPressed ? 0.99 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    @Previewable @State var isPresented = true
    @Previewable @State var canDelete = true
    ZStack {
        Color.gray.ignoresSafeArea()
        Button("Present Sheet") { isPresented = true }
            .buttonStyle(.borderedProminent)
    }
    .sheet(isPresented: $isPresented) {
        ActionSheet {
            ActionSheetItem(image: Image(systemName: "pencil"), title: "Rename") {}
            ActionSheetItem(image: Image(systemName: "star"), title: "Set as primary") {}
            ActionSheetItem(image: Image(systemName: "square.and.arrow.up"), title: "Share image") {}
            ActionSheetItem(image: Image(systemName: "paintpalette"), title: "Configure theme") {}
            if canDelete {
                ActionSheetItem(image: Image(systemName: "trash"), title: "Delete", role: .destructive) {}
            }
        }
    }
}
