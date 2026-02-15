//
//  LectureReminderEmptyView.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI

struct LectureReminderEmptyView: View {
    let title: String
    let description: String
    let actionButton: (() -> Void)?

    init(
        title: String = TimetableStrings.reminderEmptyTitle,
        description: String = TimetableStrings.reminderEmptyDescription,
        actionButton: (() -> Void)? = nil
    ) {
        self.title = title
        self.description = description
        self.actionButton = actionButton
    }

    var body: some View {
        VStack(spacing: 16) {
            SharedUIComponentsAsset.catError.swiftUIImage

            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.primary)

            Text(description.asMarkdown())
                .lineHeight(with: .systemFont(ofSize: 13), percentage: 145)
                .foregroundColor(SharedUIComponentsAsset.gray30.swiftUIColor)
                .multilineTextAlignment(.center)

            if let actionButton {
                Button(TimetableStrings.reminderErrorRetry) {
                    actionButton()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    LectureReminderEmptyView()
}
