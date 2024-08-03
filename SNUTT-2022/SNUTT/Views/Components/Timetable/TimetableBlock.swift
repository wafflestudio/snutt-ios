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

    var body: some View {
        ZStack {
            Rectangle()
                .fill(lecture.getColor(with: theme).bg)
                .border(Color.black.opacity(0.1), width: 0.5)

            VStack(spacing: 0) {
                Group {
                    let visibilityOptions = adjustedVisibilityOptions()

                    if visibilityOptions.contains(.lectureTitle) {
                        Text(attributedString(for: lecture.title, font: .systemFont(ofSize: 11, weight: .regular)))
                            .foregroundColor(lecture.getColor(with: theme).fg)
                            .font(STFont.lectureBlockTitle)
                    }

                    if !timePlace.place.isEmpty, visibilityOptions.contains(.place) {
                        Text(attributedString(for: timePlace.place, font: .systemFont(ofSize: 12, weight: .semibold)))
                            .padding(.top, 2)
                            .minimumScaleFactor(0.8)
                    }

                    if !lecture.lectureNumber.isEmpty, visibilityOptions.contains(.lectureNumber) {
                        Text(attributedString(for: "(\(lecture.lectureNumber))", font: .systemFont(ofSize: 12)))
                            .padding(.top, 2)
                            .minimumScaleFactor(0.8)
                    }

                    if !lecture.instructor.isEmpty, visibilityOptions.contains(.instructor) {
                        Text(attributedString(for: lecture.instructor, font: .systemFont(ofSize: 11)))
                            .padding(.top, 2)
                            .minimumScaleFactor(0.8)
                    }
                }
                .multilineTextAlignment(.center)
                .foregroundColor(lecture.getColor(with: theme).fg)
            }
            .animation(.customSpring, value: visibilityOptions)
            .padding(4)
        }
    }

    private func attributedString(for string: String, font: UIFont) -> AttributedString {
        var container = AttributeContainer()
        container.font = font
        return AttributedString(string, attributes: container)
    }

    private func height(for string: String, font: UIFont) -> CGFloat {
        let attrString = attributedString(for: string, font: font)
        return NSAttributedString(attrString).size().height
    }

    private func adjustedVisibilityOptions() -> VisibilityOptions {
        var estimatedHeight: CGFloat = 0
        var newOptions = VisibilityOptions()

        let elements: [(VisibilityOptions, String, UIFont)] = [
            (.lectureTitle, lecture.title, .systemFont(ofSize: 11, weight: .regular)),
            (.place, timePlace.place, .systemFont(ofSize: 12, weight: .semibold)),
            (.lectureNumber, "(\(lecture.lectureNumber))", .systemFont(ofSize: 12)),
            (.instructor, lecture.instructor, .systemFont(ofSize: 11))
        ]

        for (option, text, font) in elements {
            if visibilityOptions.contains(option) {
                estimatedHeight += height(for: text, font: font)
                if estimatedHeight >= idealHeight {
                    return newOptions
                } else {
                    newOptions.insert(option)
                }
            }
        }
        return newOptions
    }
}
