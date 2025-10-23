//
//  ThemeSettingsScene.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SwiftUI
import ThemesInterface

struct ThemeSettingsScene: View {
    @Environment(\.themeViewModel) private var themeViewModel: any ThemeViewModelProtocol
    @State private var themeForBottomSheet: Theme?
    @State private var isNewThemePresented = false

    var body: some View {
        Form {
            Section(header: Text("Custom Themes")) {
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
            }

            if !downloadedThemes.isEmpty {
                Section(header: Text("Downloaded Themes")) {
                    ThemeHorizontalScrollView(
                        themes: downloadedThemes,
                        onTapTheme: { theme in
                            themeForBottomSheet = theme
                        }
                    )
                }
            }

            Section(header: Text("Basic Themes"), footer: HowToApplyThemeInfoView()) {
                ThemeHorizontalScrollView(
                    themes: basicThemes,
                    onTapTheme: { theme in
                        themeForBottomSheet = theme
                    }
                )
            }

        }
        .navigationTitle("시간표 테마")
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
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: "info.circle")
                    .resizable()
                    .frame(width: 14, height: 14)
                Text("테마는 어떻게 적용하나요?")
                    .font(.system(size: 12, weight: .bold))
            }
            Text("시간표 적용은 시간표 목록 > 더보기 버튼 > 테마 설정에서 개별적으로 적용할 수 있어요.")
                .font(.system(size: 12))
                .lineSpacing(1.3)
            Text("새로운 시간표에는 가장 최근 편집한 커스텀 테마가 적용돼요.")
                .font(.system(size: 12))
        }
        .padding(.top, 25)
    }
}
