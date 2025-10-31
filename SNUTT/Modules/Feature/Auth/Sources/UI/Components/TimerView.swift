//
//  TimerView.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI

struct TimerView: View {
    let initialRemainingTime: Int
    let onRestart: (() async -> Void)?
    let onTimeout: (() -> Void)?

    @State private var remainingTime: Int
    @State private var timeOut = false
    @State private var restartTrigger = 0

    init(
        initialRemainingTime: Int,
        onRestart: (() async -> Void)? = nil,
        onTimeout: (() -> Void)? = nil
    ) {
        self.initialRemainingTime = initialRemainingTime
        self.onRestart = onRestart
        self.onTimeout = onTimeout
        self._remainingTime = State(initialValue: initialRemainingTime)
    }

    var body: some View {
        HStack(spacing: 4) {
            if onRestart != nil && timeOut {
                Button {
                    Task {
                        await onRestart?()
                        restartTrigger += 1
                    }
                } label: {
                    Text(AuthStrings.alertResend)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(SharedUIComponentsAsset.assistive.swiftUIColor)
                }
            } else {
                Text(timeString)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(SharedUIComponentsAsset.assistive.swiftUIColor)
                    .monospacedDigit()
            }
        }
        .task(id: restartTrigger) {
            remainingTime = initialRemainingTime
            timeOut = false

            while remainingTime > 0, !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                remainingTime -= 1
            }

            timeOut = true
            onTimeout?()
        }
    }

    private var timeString: String {
        let minutes = remainingTime / 60
        let seconds = remainingTime % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    struct PreviewContainer: View {
        var body: some View {
            VStack(spacing: 20) {
                TimerView(
                    initialRemainingTime: 5,
                    onRestart: {
                        print("Restart requested")
                    },
                    onTimeout: {
                        print("Timed out")
                    }
                )
            }
            .padding()
        }
    }

    return PreviewContainer()
}
