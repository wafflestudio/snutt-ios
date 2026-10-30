//
//  EvaluationTakenLectureSection.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI

/// Lectures the user took in one semester, each with the user's own evaluations or a prompt to write one.
struct EvaluationTakenLectureSection: View {
    let group: TakenLectureGroup
    let onWriteEvaluation: (EvaluationLectureID) -> Void
    let onToggleLike: (LectureEvaluation) -> Void
    let onSelectMenuAction: (EvaluationMenuAction) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header

            ForEach(group.lectures) { lecture in
                TakenLectureCell(
                    lecture: lecture,
                    onWrite: { onWriteEvaluation(lecture.id) },
                    onToggleLike: onToggleLike,
                    onSelectMenuAction: onSelectMenuAction
                )
                .padding(.horizontal, 20)

                if lecture.id != group.lectures.last?.id {
                    Divider()
                        .padding(.horizontal, 20)
                }
            }
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            Text(EvaluationsStrings.homeTakenLecturesTitle(group.quarter.evaluationDisplayText))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(EvaluationDesignColor.accent)
                .lineLimit(1)
                .accessibilityAddTraits(.isHeader)

            Spacer(minLength: 8)

            NavigationLink(value: EvaluationDestination.myEvaluations) {
                HStack(spacing: 2) {
                    Text(EvaluationsStrings.homeMyEvaluations)
                    Image(systemName: "chevron.right")
                        .imageScale(.small)
                }
                .font(.footnote.weight(.medium))
                .foregroundStyle(.secondary)
                .frame(minHeight: 44)
                .contentShape(.rect)
            }
            .buttonStyle(.animatable)
        }
        .padding(.horizontal, 20)
        .background(EvaluationDesignColor.accentBackground)
    }
}

struct TakenLectureCell: View {
    let lecture: TakenLecture
    let onWrite: () -> Void
    let onToggleLike: (LectureEvaluation) -> Void
    let onSelectMenuAction: (EvaluationMenuAction) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header

            if lecture.myEvaluations.isEmpty {
                TakenLectureEmptyPrompt(lectureTitle: lecture.info.brief.title, action: onWrite)
            } else {
                ForEach(lecture.myEvaluations) { evaluation in
                    EvaluationRow(
                        evaluation: evaluation,
                        contentLineLimit: 3,
                        onToggleLike: { onToggleLike(evaluation) },
                        onSelectMenuAction: onSelectMenuAction
                    )
                }
            }
        }
        .padding(.vertical, 20)
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {
            NavigationLink(value: EvaluationDestination.lectureDetail(lecture.id, referrer: .takenLecture)) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(lecture.info.brief.title)
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    HStack(spacing: 4) {
                        EvaluationAverageRatingLabel(averageRating: lecture.averageRating)
                        Text("·")
                            .foregroundStyle(.tertiary)
                            .accessibilityHidden(true)
                        Text(lecture.info.brief.instructorDisplayText)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    .font(.footnote)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(.rect)
            }
            .buttonStyle(.animatable(scale: 0.98))
            .accessibilityElement(children: .combine)

            TakenLectureWriteButton(isCompleted: !lecture.myEvaluations.isEmpty, action: onWrite)
        }
    }
}

private struct TakenLectureWriteButton: View {
    let isCompleted: Bool
    let action: () -> Void

    var body: some View {
        if isCompleted {
            chip(EvaluationsStrings.writeCompleted, systemImage: "checkmark")
                .foregroundStyle(.tertiary)
                .background(Color(uiColor: .tertiarySystemFill), in: chipShape)
        } else {
            Button(action: action) {
                chip(EvaluationsStrings.writeButton, systemImage: "pencil")
                    .foregroundStyle(.white)
                    .background(EvaluationDesignColor.accent, in: chipShape)
                    // Keeps a comfortable touch target around the compact chip.
                    .contentShape(.rect.inset(by: -8))
            }
            .buttonStyle(.animatable(scale: 0.95, hapticFeedback: true))
        }
    }

    private var chipShape: some Shape {
        .rect(cornerRadius: 6, style: .continuous)
    }

    private func chip(_ title: String, systemImage: String) -> some View {
        Label(title, systemImage: systemImage)
            .labelStyle(.titleAndIcon)
            .font(.caption.weight(.semibold))
            .imageScale(.small)
            .padding(.horizontal, 10)
            .frame(minHeight: 26)
    }
}

private struct TakenLectureEmptyPrompt: View {
    let lectureTitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: "pencil")
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(EvaluationDesignColor.accent)
                    .frame(width: 32, height: 32)
                    .background(EvaluationDesignColor.accent.opacity(0.14), in: .circle)

                VStack(spacing: 2) {
                    Text(lectureTitle)
                        .foregroundStyle(EvaluationDesignColor.accent)
                        .lineLimit(1)
                    Text(EvaluationsStrings.takenEmptyPrompt)
                        .foregroundStyle(.secondary)
                }
                .font(.subheadline.weight(.semibold))
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, minHeight: 112)
            .background(EvaluationDesignColor.accentBackground, in: .rect(cornerRadius: 12, style: .continuous))
            .contentShape(.rect)
        }
        .buttonStyle(.animatable(scale: 0.98))
        .accessibilityElement(children: .combine)
        .accessibilityHint(EvaluationsStrings.writeButton)
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            EvaluationTakenLectureSection(
                group: EvaluationPreviewFixtures.takenLectureGroups[0],
                onWriteEvaluation: { _ in },
                onToggleLike: { _ in },
                onSelectMenuAction: { _ in }
            )
        }
    }
}
