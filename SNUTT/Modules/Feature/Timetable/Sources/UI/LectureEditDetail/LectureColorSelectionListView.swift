//
//  LectureColorSelectionListView.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SwiftUI
import SwiftUIUtility
import ThemesInterface
import TimetableInterface

struct LectureColorSelectionListView: View {
    let theme: Theme
    let viewModel: LectureEditDetailViewModel

    var body: some View {
        Form {
            fixedColorsSection
            customColorSection
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(TimetableStrings.editColorTitle)
    }

    private var checkMarkImage: Image {
        Image(systemName: "checkmark")
    }

    private var fixedColorsSection: some View {
        Section {
            ForEach(Array(theme.colors.enumerated()), id: \.offset) { index, color in
                let isSelected =
                    if theme.isCustom {
                        viewModel.editableLecture.colorIndex == 0 && viewModel.editableLecture.customColor == color
                    } else {
                        viewModel.editableLecture.colorIndex == index + 1
                    }
                LectureColorPreviewButton(
                    lectureColor: color,
                    title: TimetableStrings.editColorName,
                    trailingImage: isSelected ? checkMarkImage : nil
                ) {
                    withAnimation(.defaultSpring) {
                        if theme.isCustom {
                            viewModel.editableLecture.colorIndex = 0
                            viewModel.editableLecture.customColor = color
                        } else {
                            viewModel.editableLecture.colorIndex = index + 1
                        }
                    }
                }
            }
        }
    }
}

extension LectureColorSelectionListView {
    @ViewBuilder private var customColorSection: some View {
        if theme.isCustom {
            EmptyView()
        } else {
            Section {
                let isSelected = viewModel.editableLecture.colorIndex == 0
                DisclosureGroup(isExpanded: .init(get: { isSelected }, set: { _ in })) {
                    Group {
                        ColorPicker(
                            TimetableStrings.editColorFontColor,
                            selection: fgColorBinding(),
                            supportsOpacity: false
                        )
                        ColorPicker(
                            TimetableStrings.editColorBackgroundColor,
                            selection: bgColorBinding(),
                            supportsOpacity: false
                        )
                    }
                } label: {
                    LectureColorPreviewButton(
                        lectureColor: viewModel.editableLecture.customColor ?? .temporary,
                        title: TimetableStrings.editColorName,
                        trailingImage: isSelected ? checkMarkImage : nil
                    ) {
                        withAnimation(.defaultSpring) {
                            viewModel.editableLecture.colorIndex = 0
                            viewModel.editableLecture.customColor = viewModel.editableLecture.customColor ?? .temporary
                        }
                    }
                }
            }
        }
    }

    private func fgColorBinding() -> Binding<Color> {
        .init {
            (viewModel.editableLecture.customColor ?? .temporary).fg
        } set: { color in
            viewModel.editableLecture.customColor?.fgHex = color.toHex()
        }
    }

    private func bgColorBinding() -> Binding<Color> {
        .init {
            (viewModel.editableLecture.customColor ?? .temporary).bg
        } set: { color in
            viewModel.editableLecture.customColor?.bgHex = color.toHex()
        }
    }
}

struct LectureColorPreviewButton: View {
    let lectureColor: LectureColor
    let title: String?
    let trailingImage: Image?
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 15) {
                colorPreview
                if let title {
                    Text(title)
                }
                Spacer()

                trailingImage
            }
        }
    }

    private var colorPreview: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(lectureColor.fg)
                .border(Color.black.opacity(0.1), width: 1)
                .aspectRatio(1.0, contentMode: .fit)
            Rectangle()
                .fill(lectureColor.bg)
                .border(Color.black.opacity(0.1), width: 1)
                .aspectRatio(1.0, contentMode: .fit)
        }
        .frame(height: 25)
    }
}

#Preview {
    let timetable = PreviewHelpers.preview(id: "1")
    let lecture = timetable.lectures.first!
    let viewModel = LectureEditDetailViewModel(
        displayMode: .normal(timetable: timetable),
        entryLecture: lecture
    )

    return NavigationStack {
        LectureColorSelectionListView(
            theme: .snutt,
            viewModel: viewModel
        )
    }
}
