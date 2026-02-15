//
//  Popup.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SwiftUI

public struct Popup<Content>: View where Content: View {
    @Binding private var isPresented: Bool
    private var content: () -> Content

    @State private var backgroundOpacity: CGFloat = 0
    @State private var scale: CGFloat = 1.1
    @State private var contentOpacity: CGFloat = 0

    private enum Layout {
        static var backgroundOpacity: CGFloat { 0.5 }
        static var cornerRadius: CGFloat { 12 }
        static var horizontalMargin: CGFloat { 40 }
    }

    private var animation: Animation {
        .defaultSpring
    }

    public init(
        isPresented: Binding<Bool>,
        content: @escaping () -> Content
    ) {
        _isPresented = isPresented
        self.content = content
    }

    public var body: some View {
        ZStack {
            backgroundOverlay
            popupContent
        }
        .onAppear {
            withAnimation(animation) {
                backgroundOpacity = 1
                scale = 1.0
                contentOpacity = 1
            }
        }
    }

    private var backgroundOverlay: some View {
        Color.black.opacity(Layout.backgroundOpacity)
            .opacity(backgroundOpacity)
            .ignoresSafeArea()
            .contentShape(Rectangle())
            .allowsHitTesting(true)
            .onTapGesture {
                dismissPopup()
            }
    }

    private var popupContent: some View {
        content()
            .environment(
                \.popupDismiss,
                PopupDismissAction(action: {
                    dismissPopup()
                })
            )
            .background(SharedUIComponentsAsset.systemBackground.swiftUIColor)
            .clipShape(RoundedRectangle(cornerRadius: Layout.cornerRadius))
            .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
            .padding(.horizontal, Layout.horizontalMargin)
            .scaleEffect(scale)
            .opacity(contentOpacity)
    }

    private func dismissPopup() {
        withAnimation(animation) {
            backgroundOpacity = 0
            scale = 0.95
            contentOpacity = 0
        } completion: {
            isPresented = false
        }
    }
}

private struct PopupDismissKey: EnvironmentKey {
    static let defaultValue: PopupDismissAction = .init(action: nil)
}

extension EnvironmentValues {
    public var popupDismiss: PopupDismissAction {
        get { self[PopupDismissKey.self] }
        set { self[PopupDismissKey.self] = newValue }
    }
}

@MainActor
public struct PopupDismissAction {
    let action: (@MainActor () -> Void)?
    public func callAsFunction() {
        action?()
    }
}

// MARK: - Preview

struct PreviewPopup: View {
    @Environment(\.popupDismiss) private var dismiss
    var body: some View {
        VStack(spacing: 20) {
            Text("Popup Content")
                .font(.headline)
            Text("This is a custom popup")
                .font(.body)
            Button("Close") {
                dismiss()
            }
        }
        .padding(40)
    }
}

#Preview {
    @Previewable @State var isPresented = true

    ZStack {
        Color.gray.opacity(0.3)
            .ignoresSafeArea()

        VStack {
            Button("Show Popup") {
                isPresented = true
            }
            .customPopup(isPresented: $isPresented) {
                PreviewPopup()
            }
        }
    }
    .overlayPopup()
}
