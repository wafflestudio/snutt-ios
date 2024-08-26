//
//  TimetableBlock.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/04/30.
//

import SwiftUI

struct TimetableBlock: View {
    typealias VisibilityOptions = TimetableConfiguration.VisibilityOptions

    let lecture: Lecture
    let timePlace: TimePlace
    let theme: Theme?
    let idealHeight: CGFloat
    let visibilityOptions: VisibilityOptions

    private enum Design {
        static let padding: CGFloat = 4
    }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(lecture.getColor(with: theme).bg)
                .border(Color.black.opacity(0.1), width: 0.5)

            VStack(spacing: 0) {
                Group {
                    let visibilityOptions = adjustedVisibilityOptions()
                    let informationTypes = allInformationTypes()
                    ForEach(informationTypes) { type in
                        if type.needsDisplay(by: visibilityOptions) {
                            Text(type.attributedString)
                                .foregroundColor(lecture.getColor(with: theme).fg)
                                .padding(.top, type.topPadding)
                                .minimumScaleFactor(type.minimumScaleFactor)
                        }
                    }
                }
                .multilineTextAlignment(.center)
                .foregroundColor(lecture.getColor(with: theme).fg)
            }
            .animation(.customSpring, value: visibilityOptions)
            .padding(Design.padding)
        }
    }

    private func allInformationTypes() -> [BlockInformationType] {
        [
            .lectureTitle(text: lecture.title),
            .place(text: timePlace.place),
            .lectureNumber(text: "(\(lecture.lectureNumber))"),
            .instructor(text: lecture.instructor),
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
            STFont.lectureBlockTitle
        case .place:
            STFont.lectureBlockPlace
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
