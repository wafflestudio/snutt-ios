//
//  TimetableLectureBlock.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI
import TimetableInterface
import ThemesInterface

struct TimetableLectureBlock: View {
    typealias VisibilityOptions = TimetableConfiguration.VisibilityOptions

    let lecture: Lecture
    let lectureColor: LectureColor
    let timePlace: TimePlace
    let idealHeight: CGFloat
    let visibilityOptions: VisibilityOptions

    private enum Design {
        static let padding: CGFloat = 4
    }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(lectureColor.bg)
                .border(Color.black.opacity(0.1), width: 0.5)

            VStack(spacing: 0) {
                Group {
                    let visibilityOptions = adjustedVisibilityOptions()
                    let informationTypes = allInformationTypes()
                    ForEach(informationTypes) { type in
                        if type.needsDisplay(by: visibilityOptions) {
                            Text(type.attributedString)
                                .padding(.top, type.topPadding)
                                .minimumScaleFactor(type.minimumScaleFactor)
                        }
                    }
                }
                .multilineTextAlignment(.center)
                .foregroundStyle(lectureColor.fg)
            }
            .animation(.defaultSpring, value: visibilityOptions)
            .padding(Design.padding)
        }
        .animation(.defaultSpring, value: lectureColor)
    }

    private func allInformationTypes() -> [BlockInformationType] {
        [
            .lectureTitle(text: lecture.courseTitle),
            .place(text: timePlace.place),
            .lectureNumber(text: "(\(lecture.lectureNumber ?? ""))"),
            .instructor(text: lecture.instructor ?? ""),
        ]
    }

    private func adjustedVisibilityOptions() -> VisibilityOptions {
        var estimatedHeight: CGFloat = 0
        var newOptions = VisibilityOptions()
        for type in allInformationTypes() where type.needsDisplay(by: visibilityOptions) {
            estimatedHeight += (type.height + type.topPadding)
            if estimatedHeight > idealHeight - Design.padding * 2 {
                return newOptions
            } else {
                newOptions.insert(type.asVisibilityOption())
            }
        }
        return newOptions
    }
}

private enum BlockInformationType: Identifiable {
    var id: String {
        switch self {
        case let .lectureTitle(text):
            "lectureTitle-\(text)"
        case let .place(text):
            "place-\(text)"
        case let .lectureNumber(text):
            "lectureNumber-\(text)"
        case let .instructor(text):
            "instructor-\(text)"
        }
    }

    case lectureTitle(text: String)
    case place(text: String)
    case lectureNumber(text: String)
    case instructor(text: String)

    var font: UIFont {
        switch self {
        case .lectureTitle:
            .systemFont(ofSize: 11)
        case .place:
            .systemFont(ofSize: 11, weight: .bold)
        case .lectureNumber:
            .systemFont(ofSize: 12)
        case .instructor:
            .systemFont(ofSize: 11)
        }
    }

    func asVisibilityOption() -> TimetableConfiguration.VisibilityOptions {
        switch self {
        case .lectureTitle:
            .lectureTitle
        case .place:
            .place
        case .lectureNumber:
            .lectureNumber
        case .instructor:
            .instructor
        }
    }

    var minimumScaleFactor: CGFloat {
        switch self {
        case .lectureTitle:
            1
        case .place,
             .lectureNumber,
             .instructor:
            0.8
        }
    }

    var text: String {
        switch self {
        case let .lectureTitle(text),
             let .place(text),
             let .lectureNumber(text),
             let .instructor(text):
            text.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }

    var topPadding: CGFloat {
        switch self {
        case .lectureTitle:
            0
        case .place,
             .lectureNumber,
             .instructor:
            2
        }
    }

    func needsDisplay(by visibilityOptions: TimetableConfiguration.VisibilityOptions) -> Bool {
        if text.isEmpty {
            return false
        }
        return switch self {
        case .lectureTitle:
            visibilityOptions.contains(.lectureTitle)
        case .place:
            visibilityOptions.contains(.place)
        case .lectureNumber:
            visibilityOptions.contains(.lectureNumber)
        case .instructor:
            visibilityOptions.contains(.instructor)
        }
    }

    var attributedString: AttributedString {
        Self.attributedString(for: text, font: font)
    }

    var height: CGFloat {
        return NSAttributedString(attributedString).size().height
    }

    private static func attributedString(for string: String, font: UIFont) -> AttributedString {
        var container = AttributeContainer()
        container.font = font
        return AttributedString(string, attributes: container)
    }
}

#Preview {
    let preview = PreviewHelpers.preview(id: "1")
    let lecture = preview.lectures.first!
    let timePlace = lecture.timePlaces.first!
    let height = 100.0
    let width = 80.0
    TimetableLectureBlock(
        lecture: lecture,
        lectureColor: .temporary,
        timePlace: timePlace,
        idealHeight: height,
        visibilityOptions: .default
    )
    .frame(width: width, height: height)
}
