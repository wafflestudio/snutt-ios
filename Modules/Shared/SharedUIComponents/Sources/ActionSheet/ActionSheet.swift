//
//  ActionSheet.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SwiftUI

public struct ActionSheet: View {
    private let items: [ActionSheetItem]

    enum Design {
        static let padding = 10.0
    }

    public init(@ActionSheetBuilder items: () -> [ActionSheetItem]) {
        self.items = items()
    }

    public var body: some View {
        VStack(spacing: 0) {
            ForEach(items) { item in
                Button {
                    item.action()
                } label: {
                    ActionSheetLabel(image: item.image, title: item.title, role: item.role)
                }
            }
        }
        .buttonStyle(ActionSheetButtonStyle())
        .padding(Design.padding)
        .mask {
            ContainerRelativeShape().inset(by: Design.padding).ignoresSafeArea(edges: .bottom)
        }
        .presentationDetents([.height(ActionSheetLabel.rowHeight * CGFloat(items.count) + Design.padding * 2)])
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
