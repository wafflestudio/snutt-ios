//
//  EvaluationActionViews.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI

/// A capsule that shows the like count and toggles the current user's like.
struct EvaluationLikeButton: View {
    let like: EvaluationLike
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: like.isLiked ? "hand.thumbsup.fill" : "hand.thumbsup")
                    .imageScale(.small)
                    .symbolEffect(.bounce, value: like.isLiked)
                Text(like.count, format: .number)
                    .monospacedDigit()
                    .contentTransition(.numericText(value: Double(like.count)))
            }
            .font(.caption.weight(.medium))
            .foregroundStyle(like.isLiked ? EvaluationDesignColor.accent : .secondary)
            .padding(.horizontal, 10)
            .frame(minHeight: 28)
            .background {
                Capsule()
                    .fill(like.isLiked ? EvaluationDesignColor.accentBackground : .clear)
            }
            .overlay {
                Capsule()
                    .strokeBorder(
                        like.isLiked ? EvaluationDesignColor.accent.opacity(0.4) : Color(uiColor: .systemGray5)
                    )
            }
            .contentShape(.capsule)
        }
        .buttonStyle(.animatable(scale: 0.92, hapticFeedback: true))
        .animation(.defaultSpring, value: like)
        .accessibilityLabel(EvaluationsStrings.likeAccessibility)
        .accessibilityValue(EvaluationsStrings.likeCountAccessibility(like.count))
        .accessibilityAddTraits(like.isLiked ? .isSelected : [])
    }
}

/// The overflow menu on an evaluation, offering only the actions the user is permitted to take.
struct EvaluationMenuButton: View {
    let evaluation: LectureEvaluation
    let onSelect: (EvaluationMenuAction) -> Void

    var body: some View {
        if !evaluation.permissions.isEmpty {
            Menu {
                if evaluation.permissions.contains(.report) {
                    Button(EvaluationsStrings.menuReport, systemImage: "exclamationmark.bubble") {
                        onSelect(.report(evaluation.id))
                    }
                }
                if evaluation.permissions.contains(.modify) {
                    Button(EvaluationsStrings.menuDelete, systemImage: "trash", role: .destructive) {
                        onSelect(.delete(evaluation.id))
                    }
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
                    .frame(width: 32, height: 28)
                    .contentShape(.rect)
            }
            .accessibilityLabel(EvaluationsStrings.menuMore)
        }
    }
}

extension View {
    /// Presents the confirmation for a picked ``EvaluationMenuAction``: a reason prompt for reports,
    /// and a destructive confirmation for deletions.
    func evaluationMenuActionAlerts(
        _ action: Binding<EvaluationMenuAction?>,
        onReport: @escaping (EvaluationID, String) -> Void,
        onDelete: @escaping (EvaluationID) -> Void
    ) -> some View {
        modifier(EvaluationMenuActionAlerts(action: action, onReport: onReport, onDelete: onDelete))
    }
}

private struct EvaluationMenuActionAlerts: ViewModifier {
    @Binding var action: EvaluationMenuAction?
    let onReport: (EvaluationID, String) -> Void
    let onDelete: (EvaluationID) -> Void

    @State private var reportReason = ""

    func body(content: Content) -> some View {
        content
            .alert(
                EvaluationsStrings.reportTitle,
                isPresented: isPresented(\.reportedEvaluationID),
                presenting: action?.reportedEvaluationID
            ) { id in
                TextField(EvaluationsStrings.reportPlaceholder, text: $reportReason)
                Button(EvaluationsStrings.cancel, role: .cancel) {}
                Button(EvaluationsStrings.reportSubmit) {
                    onReport(id, reportReason.trimmingCharacters(in: .whitespacesAndNewlines))
                }
                .disabled(reportReason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            } message: { _ in
                Text(EvaluationsStrings.reportMessage)
            }
            .alert(
                EvaluationsStrings.deleteTitle,
                isPresented: isPresented(\.deletedEvaluationID),
                presenting: action?.deletedEvaluationID
            ) { id in
                Button(EvaluationsStrings.cancel, role: .cancel) {}
                Button(EvaluationsStrings.deleteConfirm, role: .destructive) {
                    onDelete(id)
                }
            } message: { _ in
                Text(EvaluationsStrings.deleteMessage)
            }
            .onChange(of: action) {
                reportReason = ""
            }
    }

    private func isPresented(_ keyPath: KeyPath<EvaluationMenuAction, EvaluationID?>) -> Binding<Bool> {
        Binding(
            get: { action?[keyPath: keyPath] != nil },
            set: { isPresented in
                if !isPresented { action = nil }
            }
        )
    }
}

extension EvaluationMenuAction {
    fileprivate var reportedEvaluationID: EvaluationID? {
        if case .report(let id) = self { id } else { nil }
    }

    fileprivate var deletedEvaluationID: EvaluationID? {
        if case .delete(let id) = self { id } else { nil }
    }
}

#Preview {
    @Previewable @State var like = EvaluationLike(count: 12, isLiked: false)
    EvaluationLikeButton(like: like) {
        like = like.toggled()
    }
}
