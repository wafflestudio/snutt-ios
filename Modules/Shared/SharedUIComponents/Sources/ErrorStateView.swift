//
//  ErrorStateView.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import FoundationUtility
import SwiftUI

public struct ErrorStateView: View {
    let title: String
    let description: String
    let buttonLabel: String
    let retryAction: (() -> Void)?

    public init(
        title: String = SharedUIComponentsStrings.errorViewTitle,
        description: String = SharedUIComponentsStrings.errorViewSubTitle,
        buttonLabel: String = SharedUIComponentsStrings.errorViewButtonLabel,
        retryAction: (() -> Void)? = nil
    ) {
        self.title = title
        self.description = description
        self.buttonLabel = buttonLabel
        self.retryAction = retryAction
    }

    public var body: some View {
        VStack(spacing: 16) {
            SharedUIComponentsAsset.catError.swiftUIImage

            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.primary)

            Text(description.asMarkdown())
                .font(.systemFont(ofSize: 13), lineHeightMultiple: 1.45)
                .foregroundColor(SharedUIComponentsAsset.gray30.swiftUIColor)
                .multilineTextAlignment(.center)

            if let retryAction {
                Button {
                    retryAction()
                } label: {
                    Text(buttonLabel)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.white)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color.enabledRectButtonBackground)
                .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ErrorStateView(title: "Error", description: "Try again later.") {
        print("retry")
    }
}
