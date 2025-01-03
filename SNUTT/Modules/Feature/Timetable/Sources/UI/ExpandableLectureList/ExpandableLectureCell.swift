//
//  ExpandableLectureCell.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import Combine
import SharedUIComponents
import SwiftUI
import TimetableInterface
import UIKit
import UIKitUtility

struct ExpandableLectureCell: View {
    let viewModel: any ExpandableLectureListViewModel
    let lecture: any Lecture
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
                    HStack(spacing: 2) {
                        TimetableAsset.searchRatingStar.swiftUIImage
                    }
                }

                LectureDetailRow(type: .time, lecture: lecture)
                LectureDetailRow(type: .place, lecture: lecture)
                LectureDetailRow(type: .remark, lecture: lecture)

                if isSelected {
                    HStack {
                        LectureActionButton(type: .detail, isSelected: false)
                        LectureActionButton(type: .review, isSelected: false)
                        LectureActionButton(type: .bookmark, isSelected: false)
                        LectureActionButton(type: .vacancy, isSelected: false)
                        LectureActionButton(type: .add, isSelected: false)
                    }
                    .transition(.opacity)
                }
            }
            .padding(.top, 10)
            .padding(.bottom, 5)
            .padding(.horizontal, 15)
        }
        .foregroundStyle(.white)
        .contentShape(Rectangle())
        .onTapGesture {
            viewModel.selectLecture(lecture)
        }
    }
}

private struct LectureActionButton: View {
    let type: ActionButtonType
    let isSelected: Bool
    enum Design {
        static let buttonFont: UIFont = .systemFont(ofSize: 11)
    }

    var body: some View {
        AnimatableButton(
            animationOptions: .identity.impact().scale(0.95).backgroundColor(touchDown: .black.opacity(0.04)),
            layoutOptions: [.respectIntrinsicHeight, .expandHorizontally]
        ) {} configuration: { _ in
            var config = UIButton.Configuration.plain()
            config.imagePlacement = .top
            config.imagePadding = 2
            config.image = type.image(isSelected: isSelected)
            config.attributedTitle = .init(type.text(isSelected: isSelected), attributes: .init([.font: Design.buttonFont]))
            config.baseForegroundColor = .white
            config.contentInsets = .init(top: 5, leading: 0, bottom: 5, trailing: 0)
            return config
        }
    }
}

private struct LectureHeaderRow: View {
    let lecture: any Lecture

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
                    Text("\(credit)학점")
                        .font(Design.detail)
                } else if let credit = lecture.credit, let instructor = lecture.instructor {
                    Text("\(instructor) / \(credit)학점")
                        .font(Design.detail)
                }
            }
        }
    }
}

private struct LectureDetailRow: View {
    let type: DetailLabelType
    let lecture: any Lecture

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
                .frame(width: 15, height: 15)
            Text(text.isEmpty ? "-" : text)
                .font(Design.detail)
                .lineLimit(1)
                .opacity(text.isEmpty ? 0.5 : 1)
            Spacer()
        }
    }
}

enum ActionButtonType: String, CaseIterable, Identifiable {
    var id: String {
        rawValue
    }

    case detail
    case review
    case bookmark
    case vacancy
    case add

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

    func text(isSelected _: Bool) -> String {
        switch self {
        case .detail:
            "자세히"
        case .review:
            "강의평"
        case .bookmark:
            "관심강좌"
        case .vacancy:
            "빈자리알림"
        case .add:
            "추가하기"
        }
    }
}

private enum DetailLabelType: CaseIterable {
    case department
    case time
    case place
    case remark

    var image: Image {
        switch self {
        case .department:
            TimetableAsset.tagWhite.swiftUIImage
        case .time:
            TimetableAsset.clockWhite.swiftUIImage
        case .place:
            TimetableAsset.mapWhite.swiftUIImage
        case .remark:
            TimetableAsset.ellipsisWhite.swiftUIImage
        }
    }

    func text(for lecture: any Lecture) -> String {
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
