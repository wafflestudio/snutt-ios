//
//  EvaluationTakenLectureSection.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI
import TimetableInterface

struct EvaluationTakenLectureSection: View {
    enum Mode: Equatable {
        case loading
        case loaded(TakenLectureFeedContent)

        var isLoading: Bool {
            if case .loading = self { true } else { false }
        }
    }

    let mode: Mode
    let onOpenMyEvaluations: () -> Void
    let onSelectLecture: (EvaluationLectureID) -> Void
    let onWriteEvaluation: (EvaluationLectureID) -> Void

    private var feed: TakenLectureFeedContent {
        switch mode {
        case .loading:
            .placeholder
        case .loaded(let feed):
            feed
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header

            ForEach(feed.lectures) { lecture in
                TakenLectureCell(
                    lecture: lecture,
                    onTap: {
                        onSelectLecture(lecture.id)
                    },
                    onWrite: {
                        onWriteEvaluation(lecture.id)
                    }
                )
                .padding(.horizontal, 20)

                Divider()
                    .padding(.horizontal, 20)
            }
        }
        .redacted(reason: mode.isLoading ? .placeholder : [])
    }

    private var header: some View {
        HStack(spacing: 12) {
            Text(feed.title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(EvaluationDesignColor.mint)
                .lineLimit(1)
                .minimumScaleFactor(0.85)

            Spacer(minLength: 8)

            Button {
                onOpenMyEvaluations()
            } label: {
                HStack(spacing: 4) {
                    Text("나의 강의평")
                        .font(.system(size: 13, weight: .medium))

                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundStyle(Color(uiColor: .tertiaryLabel))
                .contentShape(Rectangle())
            }
            .buttonStyle(.animatable())
        }
        .padding(.horizontal, 20)
        .frame(height: 40)
        .background(EvaluationDesignColor.mintBackground)
    }
}

extension TakenLectureFeedContent {
    fileprivate var title: String {
        "\(takenQuarter.year % 100)년 \(takenQuarter.semester.takenLectureSectionDisplayTitle) 수강한 강의"
    }
}

extension Semester {
    fileprivate var takenLectureSectionDisplayTitle: String {
        switch self {
        case .first:
            "1학기"
        case .summer:
            "여름학기"
        case .second:
            "2학기"
        case .winter:
            "겨울학기"
        }
    }
}

#Preview("Taken Lecture Loading") {
    EvaluationTakenLectureSection(
        mode: .loading,
        onOpenMyEvaluations: {},
        onSelectLecture: { _ in },
        onWriteEvaluation: { _ in }
    )
    .background(Color(uiColor: .systemBackground))
}

#Preview("Taken Lecture Loaded") {
    EvaluationTakenLectureSection(
        mode: .loaded(EvaluationPreviewFixtures.takenLectureFeed),
        onOpenMyEvaluations: {},
        onSelectLecture: { _ in },
        onWriteEvaluation: { _ in }
    )
    .background(Color(uiColor: .systemBackground))
}
