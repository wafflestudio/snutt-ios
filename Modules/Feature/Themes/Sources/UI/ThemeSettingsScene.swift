//
//  ThemeSettingsScene.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI
import ThemesInterface

struct ThemeSettingsScene: View {
    @Environment(\.themeViewModel) private var themeViewModel: any ThemeViewModelProtocol
    @State private var themeForBottomSheet: Theme?
    @State private var isNewThemePresented = false

    var body: some View {
        Form {
            Section {
                ThemeHorizontalScrollView(
                    themes: customThemes,
                    onTapCreateButton: {
                        isNewThemePresented = true
                    },
                    onTapTheme: { theme in
                        themeForBottomSheet = theme
                    }
                )
                .sheet(isPresented: $isNewThemePresented) {
                    NavigationStack {
                        ThemeEditDetailScene(entryTheme: nil)
                    }
                    .presentationDetents([.large])
                }
            } header: {
                FormSectionHeader(ThemesStrings.settingsCustom)
            }

            if !downloadedThemes.isEmpty {
                Section {
                    ThemeHorizontalScrollView(
                        themes: downloadedThemes,
                        onTapTheme: { theme in
                            themeForBottomSheet = theme
                        }
                    )
                } header: {
                    FormSectionHeader(ThemesStrings.downloadedTheme)
                }
            }

            Section {
                ThemeHorizontalScrollView(
                    themes: basicThemes,
                    onTapTheme: { theme in
                        themeForBottomSheet = theme
                    }
                )
            } header: {
                FormSectionHeader(ThemesStrings.settingsBasic)
            } footer: {
                HowToApplyThemeInfoView()
            }
        }
        .navigationTitle(ThemesStrings.settingsTitle)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $themeForBottomSheet) { theme in
            ThemeDetailSheet(theme: theme)
        }
        .animation(.defaultSpring, value: downloadedThemes)
        .task {
            try? await themeViewModel.fetchThemes()
        }
        .analyticsScreen(.themeHome)
    }

    private var customThemes: [Theme] {
        themeViewModel.availableThemes.filter { $0.status == .customPrivate }
    }

    private var downloadedThemes: [Theme] {
        themeViewModel.availableThemes.filter { $0.status == .customDownloaded }
    }

    private var basicThemes: [Theme] {
        themeViewModel.availableThemes.filter { $0.status == .builtIn }
    }
}

private struct HowToApplyThemeInfoView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "info.circle")
                    .resizable()
                    .frame(width: 14, height: 14)
                Text(ThemesStrings.settingsHowtoQuestion)
                    .font(.system(size: 12, weight: .bold))
            }
            Group {
                Text(ThemesStrings.settingsHowtoAnswer1)
                    .lineSpacing(1.3)
                Text(ThemesStrings.settingsHowtoAnswer2)
            }
            .font(.system(size: 12))
        }
        .padding(.top, 24)
        .padding(.bottom, 40)
        .foregroundStyle(SharedUIComponentsAsset.gray2.swiftUIColor)
    }
}
