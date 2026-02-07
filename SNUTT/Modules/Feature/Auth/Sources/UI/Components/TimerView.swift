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

    @State private var isTimedOut = false
    @State private var endDate: Date
    @State private var didTimeout = false
    @State private var restartTrigger = 0

    init(
        initialRemainingTime: Int,
        onRestart: (() async -> Void)? = nil,
        onTimeout: (() -> Void)? = nil
    ) {
        self.initialRemainingTime = initialRemainingTime
        self.onRestart = onRestart
        self.onTimeout = onTimeout
        self._endDate = State(initialValue: Date().addingTimeInterval(TimeInterval(initialRemainingTime)))
    }

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let remaining = remainingTime(now: context.date)

            HStack(spacing: 4) {
                if onRestart != nil && isTimedOut {
                    Button {
                        Task {
                            await onRestart?()
                            restartTrigger += 1
                        }
                    } label: {
                        Text(AuthStrings.alertResend)
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(SharedUIComponentsAsset.cyan.swiftUIColor)
                    }
                } else {
                    Text(timeString(remaining: remaining))
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(SharedUIComponentsAsset.assistive.swiftUIColor)
                        .monospacedDigit()
                }
            }
            .onChange(of: remaining) { newValue in
                if newValue == 0, !didTimeout {
                    didTimeout = true
                    isTimedOut = true
                    onTimeout?()
                }
            }
        }
        .task(id: restartTrigger) {
            endDate = Date().addingTimeInterval(TimeInterval(initialRemainingTime))
            isTimedOut = false
            didTimeout = false
        }
    }

    private func remainingTime(now: Date) -> Int {
        max(0, Int(ceil(endDate.timeIntervalSince(now))))
    }

    private func timeString(remaining: Int) -> String {
        let minutes = remaining / 60
        let seconds = remaining % 60
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
