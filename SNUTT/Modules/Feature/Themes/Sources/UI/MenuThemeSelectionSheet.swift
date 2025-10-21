//
//  MenuThemeSelectionSheet.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Dependencies
import SharedUIComponents
import SwiftUI
import SwiftUIUtility
import ThemesInterface
import TimetableInterface

struct MenuThemeSelectionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.timetableViewModel) private var timetableViewModel: any TimetableViewModelProtocol
    @Environment(\.themeViewModel) private var themeViewModel: any ThemeViewModelProtocol
    @Environment(\.errorAlertHandler) private var errorAlertHandler: ErrorAlertHandler

    enum SelectionType: Identifiable, Equatable {
        case new
        case theme(Theme)

        var id: String {
            switch self {
            case .new:
                return "new"
            case let .theme(theme):
                return theme.id
            }
        }

        var theme: Theme? {
            switch self {
            case .new:
                return nil
            case let .theme(theme):
                return theme
            }
        }
    }

    private var selections: [SelectionType] {
        let availableThemes = themeViewModel.availableThemes
        let customThemes = availableThemes.filter { $0.isCustom }
        let builtInThems = availableThemes.filter { !$0.isCustom }
        let allThemes = (customThemes + builtInThems).map { SelectionType.theme($0) }
        return [.new] + allThemes
    }

    var body: some View {
        GeometryReader { _ in
            VStack(spacing: 0) {
                SheetTopBar(
                    cancel: {
                        dismiss()
                    },
                    confirm: {
                        errorAlertHandler.withAlert {
                            try await themeViewModel.saveSelectedTheme()
                            dismiss()
                        }
                    }
                )

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(selections) { selection in
                            selectionButton(for: selection)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .withResponsiveTouch()
                .padding(.vertical)
            }
        }
        .presentationDetents([.height(160)])
        .observeErrors()
        .onAppear {
            if let initialSelectedTheme = themeViewModel.availableThemes
                .first(where: { $0.id == timetableViewModel.currentTimetable?.theme.id })
            {
                themeViewModel.selectTheme(initialSelectedTheme)
            }
        }
        .onDisappear {
            themeViewModel.selectTheme(nil)
        }
    }

    @ViewBuilder func selectionButton(for selection: SelectionType) -> some View {
        Button {
            switch selection {
            case .new:
                break
            case let .theme(theme):
                themeViewModel.selectTheme(theme)
            }
        } label: {
            VStack(spacing: 8) {
                Group {
                    switch selection {
                    case .new:
                        ThemesAsset.themeNew.swiftUIImage
                            .resizable()
                            .scaledToFit()
                    case let .theme(theme):
                        ThemeIcon(theme: theme)
                    }
                }
                .frame(width: 80, height: 80)

                let selectionBackgroundColor: Color =
                    if isSelectionHighlighted(selection) {
                        Color(uiColor: .tertiarySystemFill)
                    } else {
                        .clear
                    }

                Text(selectionTitle(for: selection))
                    .frame(width: 60, height: 15)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .font(.system(size: 14))
                    .background(selectionBackgroundColor)
                    .clipShape(Capsule())
            }
        }
        .buttonStyle(.plain)
    }

    func isSelectionHighlighted(_ selection: SelectionType) -> Bool {
        guard let selectionTheme = selection.theme else { return false }
        return themeViewModel.selectedTheme?.id == selectionTheme.id
    }

    func selectionTitle(for selection: SelectionType) -> String {
        switch selection {
        case .new:
            return ThemesStrings.newTheme
        case let .theme(theme):
            return theme.name
        }
    }
}

#Preview {
    @Previewable @State var isSheetPresented = false

    VStack {
        Button {
            isSheetPresented = true
        } label: {
            Text("Show Theme Selection Sheet")
        }
        .sheet(isPresented: $isSheetPresented) {
            MenuThemeSelectionSheet()
        }
    }
}
