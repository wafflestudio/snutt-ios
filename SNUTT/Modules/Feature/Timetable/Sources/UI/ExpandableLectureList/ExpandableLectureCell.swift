//
//  ExpandableLectureCell.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import AppReviewPromptInterface
import Combine
import Dependencies
import SharedUIComponents
import SwiftUI
import TimetableInterface
import UIKit
import UIKitUtility

struct ExpandableLectureCell: View {
    let viewModel: any ExpandableLectureListViewModel
    let lecture: Lecture

    var body: some View {
        let isSelected = viewModel.isSelected(lecture: lecture)
        ZStack(alignment: .top) {
            if isSelected {
                TimetableAsset.searchlistBackgroundSelected.swiftUIColor
            }
            VStack(spacing: 8) {
                LectureHeaderRow(lecture: lecture)
                HStack {
                    LectureDetailRow(type: .department, lecture: lecture)
                    if let evLecture = lecture.evLecture {
                        LectureEvaluationSummary(evLecture: evLecture)
                    }
                }

                LectureDetailRow(type: .time, lecture: lecture)
                LectureDetailRow(type: .place, lecture: lecture)
                LectureDetailRow(type: .remark, lecture: lecture)

                if isSelected {
                    HStack {
                        LectureActionButton(viewModel: viewModel, lecture: lecture, type: .detail)
                        LectureActionButton(viewModel: viewModel, lecture: lecture, type: .review)
                        LectureActionButton(viewModel: viewModel, lecture: lecture, type: .bookmark)
                        LectureActionButton(viewModel: viewModel, lecture: lecture, type: .vacancy)
                        LectureActionButton(viewModel: viewModel, lecture: lecture, type: .add)
                    }
                    .transition(.opacity)
                }
            }
            .padding(.top, 10)
            .padding(.bottom, 5)
            .padding(.horizontal, 15)
            .contentShape(Rectangle())
            .onTapGesture {
                viewModel.selectLecture(lecture)
            }
        }
    }
}

private struct LectureEvaluationSummary: View {
    let evLecture: EvLecture
    var body: some View {
        HStack(spacing: 2) {
            TimetableAsset.searchRatingStar.swiftUIImage
            Text(evLecture.avgRatingString)
                .foregroundColor(.white.opacity(0.7))
                .font(.system(size: 12))
        }
    }
}

private struct LectureActionButton: View {
    let viewModel: any ExpandableLectureListViewModel
    let lecture: Lecture
    let type: ActionButtonType

    var isSelected: Bool {
        viewModel.isToggled(lecture: lecture, type: type)
    }

    enum Design {
        static let buttonFont: UIFont = .systemFont(ofSize: 11)
    }

    @Environment(\.errorAlertHandler) private var errorAlertHandler
    @Environment(\.lectureTimeConflictHandler) private var conflictHandler
    @Environment(\.presentToast) private var presentToast
    @Dependency(\.appReviewService) private var appReviewService
    @Dependency(\.notificationCenter) private var notificationCenter

    var body: some View {
        AnimatableButton(
            animationOptions: .identity.impact().scale(0.95).backgroundColor(touchDown: .black.opacity(0.04)),
            layoutOptions: [.respectIntrinsicHeight, .expandHorizontally]
        ) {
            errorAlertHandler.withAlert {
                do {
                    try await conflictHandler.withConflictHandling { overrideOnConflict in
                        try await viewModel.toggleAction(
                            lecture: lecture,
                            type: type,
                            overrideOnConflict: overrideOnConflict
                        )
                        handleSuccessToast(for: type)
                    }
                } catch {
                    throw error
                }
            }
        } configuration: { button in
            var config = UIButton.Configuration.plain()
            config.imagePlacement = .top
            config.imagePadding = 2
            config.image = type.image(isSelected: isSelected).withTintColor(.white).resized(
                to: .init(width: 19, height: 19)
            )
            config.attributedTitle = .init(
                type.text(isSelected: isSelected),
                attributes: .init([.font: Design.buttonFont])
            )
            config.baseForegroundColor = .white
            config.contentInsets = .init(top: 5, leading: 0, bottom: 5, trailing: 0)
            button.tintAdjustmentMode = .normal
            return config
        }
    }

    private func handleSuccessToast(for actionType: ActionButtonType) {
        switch actionType {
        case .bookmark:
            guard isSelected else { return }
            presentToast(
                Toast(
                    message: TimetableStrings.toastBookmarkMessage,
                    button: ToastButton(
                        title: TimetableStrings.toastActionView,
                        action: {
                            notificationCenter.post(NavigateToBookmarkMessage())
                        }
                    )
                )
            )
            Task {
                await appReviewService.requestReviewIfNeeded()
            }

        case .vacancy:
            guard isSelected else { return }
            presentToast(
                Toast(
                    message: TimetableStrings.toastVacancyMessage,
                    button: ToastButton(
                        title: TimetableStrings.toastActionView,
                        action: {
                            notificationCenter.post(NavigateToVacancyMessage())
                        }
                    )
                )
            )

        default:
            break
        }
    }

}

private struct LectureHeaderRow: View {
    let lecture: Lecture

    private enum Design {
        static let title: Font = .system(size: 14, weight: .bold)
        static let detail: Font = .system(size: 12)
    }

    var body: some View {
        HStack {
            Group {
                Text(lecture.courseTitle)
                    .font(Design.title)
                    .truncationMode(.middle)
                Spacer()
                if lecture.instructor?.isEmpty == true, let credit = lecture.credit {
                    Text("\(credit)\(TimetableStrings.lectureCreditSuffix)")
                        .font(Design.detail)
                } else if let credit = lecture.credit, let instructor = lecture.instructor {
                    Text("\(instructor) / \(credit)\(TimetableStrings.lectureCreditSuffix)")
                        .font(Design.detail)
                }
            }
        }
    }
}

struct LectureDetailRow: View {
    let type: DetailLabelType
    let lecture: Lecture

    private enum Design {
        static let detail: Font = .system(size: 12)
    }

    private var text: String {
        type.text(for: lecture)
    }

    var body: some View {
        HStack {
            type.image
                .resizable()
                .renderingMode(.template)
                .frame(width: 15, height: 15)
            Text(text.isEmpty ? "-" : text)
                .font(Design.detail)
                .lineLimit(1)
                .opacity(text.isEmpty ? 0.5 : 1)
            Spacer()
        }
    }
}

extension ActionButtonType {
    func image(isSelected: Bool) -> UIImage {
        switch self {
        case .detail:
            TimetableAsset.searchDetail.image
        case .review:
            TimetableAsset.searchEvaluation.image
        case .bookmark:
            isSelected ? TimetableAsset.searchBookmarkFill.image : TimetableAsset.searchBookmark.image
        case .vacancy:
            isSelected ? TimetableAsset.searchVacancyFill.image : TimetableAsset.searchVacancy.image
        case .add:
            isSelected ? TimetableAsset.searchRemoveFill.image : TimetableAsset.searchAdd.image
        }
    }

    func text(isSelected: Bool) -> String {
        switch self {
        case .detail:
            TimetableStrings.lectureActionDetail
        case .review:
            TimetableStrings.lectureActionReview
        case .bookmark:
            TimetableStrings.lectureActionBookmark
        case .vacancy:
            TimetableStrings.lectureActionVacancy
        case .add:
            isSelected ? TimetableStrings.lectureActionRemove : TimetableStrings.lectureActionAdd
        }
    }
}

extension DetailLabelType {
    var image: Image {
        switch self {
        case .department:
            TimetableAsset.lectureTag.swiftUIImage
        case .time:
            TimetableAsset.lectureClock.swiftUIImage
        case .place:
            TimetableAsset.lectureMap.swiftUIImage
        case .remark:
            TimetableAsset.lectureEllipsis.swiftUIImage
        }
    }

    func text(for lecture: Lecture) -> String {
        switch self {
        case .department:
            [lecture.department, lecture.academicYear]
                .compactMap { $0 }
                .joined(separator: ", ")
        case .time:
            lecture.timePlacesDescription
        case .place:
            lecture.placesDescription ?? ""
        case .remark:
            lecture.remark ?? ""
        }
    }
}
