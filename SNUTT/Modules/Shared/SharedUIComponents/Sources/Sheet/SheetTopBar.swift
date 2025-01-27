//
//  SheetTopBar.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import MemberwiseInit
import SwiftUI
import SwiftUIUtility

@MemberwiseInit(.public)
public struct SheetTopBar: View {
    public var cancel: @MainActor () -> Void
    public var confirm: @MainActor () async -> Void
    public var isConfirmDisabled: Bool = false

    public var body: some View {
        HStack {
            SheetTopBarButton(label: "취소") {
                cancel()
            }

            Spacer()

            SheetTopBarButton(label: "적용") {
                await confirm()
            }
            .disabled(isConfirmDisabled)
        }
        .padding(.top, 5)
        .padding(.horizontal, 5)
    }
}

private struct SheetTopBarButton: View {
    let label: String
    let action: () async -> Void

    @State private var isLoading = false
    var body: some View {
        AnimatableButton(
            animationOptions: .scale(0.97).backgroundColor(touchDown: .label.opacity(0.05))
        ) {
            guard !isLoading else { return }
            isLoading = true
            Task {
                await action()
                isLoading = false
            }
        } configuration: { _ in
            var config = UIButton.Configuration.plain()
            config.title = label
            config.baseForegroundColor = .label
            return config
        }
    }
}
