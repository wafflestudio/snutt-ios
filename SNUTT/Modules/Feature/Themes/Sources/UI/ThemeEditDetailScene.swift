//
//  ThemeEditDetailScene.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SwiftUI
import SwiftUIUtility
import ThemesInterface

struct ThemeEditDetailScene: View {
    @State private var viewModel: ThemeDetailViewModel
    @State private var expandedColorId: UUID?

    @Environment(\.errorAlertHandler) private var errorAlertHandler
    @Environment(\.dismiss) private var dismiss

    init(entryTheme: Theme?) {
        _viewModel = .init(initialValue: .init(entryTheme: entryTheme))
    }

    var body: some View {
        Form {
            themeNameSection
            colorCombinationSection
            previewSection
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if viewModel.isThemeEditable {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(ThemesStrings.save) {
                        errorAlertHandler.withAlert {
                            try await viewModel.save()
                            dismiss()
                        }
                    }
                }
            }
        }
    }

    private var navigationTitle: String {
        if viewModel.isNewTheme {
            return ThemesStrings.newTheme
        }
        switch viewModel.editableTheme.status {
        case .builtIn:
            return ThemesStrings.builtinTheme
        case .customPrivate, .customPublished:
            return ThemesStrings.customTheme
        case .customDownloaded:
            return ThemesStrings.downloadedTheme
        }
    }

    private var analyticsScreen: AnalyticsScreen {
        if viewModel.isNewTheme {
            return .themeCustomNew
        }
        switch viewModel.editableTheme.status {
        case .builtIn:
            return .themeBasicDetail
        case .customPrivate, .customPublished:
            return .themeCustomEdit
        case .customDownloaded:
            return .themeDownloaded
        }
    }

    private var themeNameSection: some View {
        Section(ThemesStrings.themeName) {
            if viewModel.isThemeEditable {
                TextField(ThemesStrings.themeName, text: $viewModel.editableTheme.name)
            } else {
                Text(viewModel.editableTheme.name)
            }
        }
    }

    private var colorCombinationSection: some View {
        Section(ThemesStrings.colorCombination) {
            ForEach(Array(viewModel.identifiableColors.enumerated()), id: \.element.id) { index, identifiableColor in
                if viewModel.isThemeEditable {
                    editableColorRow(index: index, identifiableColor: identifiableColor)
                } else {
                    readOnlyColorRow(index: index, color: identifiableColor.color)
                }
            }

            if viewModel.isThemeEditable {
                Button {
                    withAnimation(.defaultSpring) {
                        viewModel.addColor()
                    }
                } label: {
                    Label(ThemesStrings.addColor, systemImage: "plus")
                }
            }
        }
    }

    @ViewBuilder
    private func editableColorRow(index: Int, identifiableColor: IdentifiableColor) -> some View {
        let isExpanded = expandedColorId == identifiableColor.id
        DisclosureGroup(
            isExpanded: .init(
                get: { isExpanded },
                set: { newValue in
                    withAnimation(.defaultSpring) {
                        expandedColorId = newValue ? identifiableColor.id : nil
                    }
                }
            )
        ) {
            ColorPicker(
                ThemesStrings.foregroundColor,
                selection: fgColorBinding(for: identifiableColor.id),
                supportsOpacity: false
            )
            ColorPicker(
                ThemesStrings.backgroundColor,
                selection: bgColorBinding(for: identifiableColor.id),
                supportsOpacity: false
            )
        } label: {
            HStack(spacing: 15) {
                LectureColorPreview(lectureColor: identifiableColor.color)
                    .frame(height: 25)
                Text(ThemesStrings.colorNumber(index + 1))
                Spacer()

                Button {
                    withAnimation(.defaultSpring) {
                        viewModel.duplicateColor(id: identifiableColor.id)
                    }
                } label: {
                    Image(systemName: "doc.on.doc")
                }
                .buttonStyle(.plain)

                Button {
                    withAnimation(.defaultSpring) {
                        viewModel.deleteColor(id: identifiableColor.id)
                    }
                } label: {
                    Image(systemName: "trash")
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func readOnlyColorRow(index: Int, color: LectureColor) -> some View {
        HStack(spacing: 15) {
            LectureColorPreview(lectureColor: color)
                .frame(height: 25)
            Text(ThemesStrings.colorNumber(index + 1))
            Spacer()
        }
    }

    @ViewBuilder
    private var previewSection: some View {
        if let timetable = viewModel.timetable {
            Section(ThemesStrings.preview) {
                TimetableThemePreview(
                    timetable: timetable,
                    configuration: viewModel.configuration,
                    theme: viewModel.editableTheme
                )
            }
        }
    }

    private func fgColorBinding(for id: UUID) -> Binding<Color> {
        .init {
            viewModel.identifiableColors.first { $0.id == id }?.color.fg ?? .clear
        } set: { color in
            viewModel.updateColorFg(id: id, hex: color.toHex())
        }
    }

    private func bgColorBinding(for id: UUID) -> Binding<Color> {
        .init {
            viewModel.identifiableColors.first { $0.id == id }?.color.bg ?? .clear
        } set: { color in
            viewModel.updateColorBg(id: id, hex: color.toHex())
        }
    }
}

#Preview {
    ThemeEditDetailScene(entryTheme: .snutt)
}

#Preview {
    ThemeEditDetailScene(entryTheme: nil)
}

#Preview {
    ThemeEditDetailScene(entryTheme: .preview1)
}
