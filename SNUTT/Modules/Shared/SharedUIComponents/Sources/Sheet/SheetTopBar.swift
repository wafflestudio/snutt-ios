//
//  SheetTopBar.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import MemberwiseInit
import SwiftUI
import SwiftUIUtility

public struct SheetTopBar: View {
    public var cancel: @MainActor () -> Void
    public var confirm: @MainActor () async -> Void
    public var isConfirmDisabled: Bool

    @State private var isLoading = false

    enum Design {
        static let symbolSize = CGSize(width: 18, height: 16)
    }

    public init(
        cancel: @escaping @MainActor () -> Void,
        confirm: @escaping @MainActor () async -> Void,
        isConfirmDisabled: Bool = false
    ) {
        self.cancel = cancel
        self.confirm = confirm
        self.isConfirmDisabled = isConfirmDisabled
    }

    public var body: some View {
        HStack {
            Button {
                cancel()
            } label: {
                Image(systemName: "xmark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: Design.symbolSize.width, height: Design.symbolSize.height)
            }
            .buttonStyle(.bordered)
            .tint(.secondary)

            Spacer()

            Button {
                Task {
                    isLoading = true
                    await confirm()
                    isLoading = false
                }
            } label: {
                Group {
                    if isLoading {
                        Image(systemName: "ellipsis")
                            .resizable()
                            .fontWeight(.black)
                            .symbolEffect(.variableColor.iterative, isActive: true)
                    } else {
                        Image(systemName: "checkmark")
                            .resizable()
                    }
                }
                .scaledToFit()
                .frame(width: Design.symbolSize.width, height: Design.symbolSize.height)
            }
            .contentTransition(.symbolEffect)
            .buttonStyle(.borderedProminent)
            .disabled(isConfirmDisabled || isLoading)
            .animation(.defaultSpring, value: isLoading)
        }
        .padding(.top, 15)
        .padding(.horizontal, 15)
        .tint(SharedUIComponentsAsset.cyan.swiftUIColor)
    }
}

#Preview {
    SheetTopBar(
        cancel: {},
        confirm: {
            try? await Task.sleep(for: .seconds(3))
        }
    )
    .border(.gray, width: 1)
}
