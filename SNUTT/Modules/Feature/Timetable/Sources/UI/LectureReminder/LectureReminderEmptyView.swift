//
//  LectureReminderEmptyView.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
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
        VStack(spacing: 20) {
            SharedUIComponentsAsset.catError.swiftUIImage
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)

            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.primary)

            Text(description)
                .font(.system(size: 15))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            if let actionButton {
                Button(TimetableStrings.reminderErrorRetry) {
                    actionButton()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    LectureReminderEmptyView()
}
