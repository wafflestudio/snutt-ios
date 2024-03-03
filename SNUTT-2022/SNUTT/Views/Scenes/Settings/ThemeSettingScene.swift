//
//  ThemeSettingScene.swift
//  SNUTT
//
//  Created by 이채민 on 2024/01/17.
//

import SwiftUI

struct ThemeSettingScene: View {
    @ObservedObject var viewModel: ThemeSettingViewModel

    var body: some View {
        ZStack {
            Form {
                Section(header: Text("커스텀 테마")) {
                    ThemeScrollView(themes: viewModel.customThemes) {
                        viewModel.openNewThemeSheet()
                    } action: { theme in
                        viewModel.openBottomSheet(for: theme)
                    }
                }
                Section(header: Text("제공 테마"), footer: infoView()) {
                    ThemeScrollView(themes: viewModel.basicThemes) { theme in
                        viewModel.openBasicThemeSheet(for: theme)
                    }
                }
            }
            ThemeBottomSheet(isOpen: $viewModel.isBottomSheetOpen,
                             openCustomThemeSheet: viewModel.openCustomThemeSheet,
                             copyTheme: viewModel.copyTheme,
                             deleteTheme: viewModel.deleteTheme)
        }
        .navigationTitle("시간표 테마")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $viewModel.isNewThemeSheetOpen, content: {
            ZStack {
                NavigationView {
                    ThemeDetailScene(viewModel: .init(container: viewModel.container), theme: viewModel.newTheme, themeType: .new)
                }
            }
            .accentColor(Color(UIColor.label))
        })
        .sheet(isPresented: $viewModel.isBasicThemeSheetOpen, content: {
            ZStack {
                NavigationView {
                    ThemeDetailScene(viewModel: .init(container: viewModel.container), theme: viewModel.targetTheme ?? viewModel.newTheme, themeType: .basic)
                }
            }
            .accentColor(Color(UIColor.label))
        })
        .sheet(isPresented: $viewModel.isCustomThemeSheetOpen, content: {
            ZStack {
                NavigationView {
                    ThemeDetailScene(viewModel: .init(container: viewModel.container), theme: viewModel.targetTheme ?? viewModel.newTheme, themeType: .custom)
                }
            }
            .accentColor(Color(UIColor.label))
        })
    }
}

@ViewBuilder private func infoView() -> some View {
    VStack(alignment: .leading) {
        HStack {
            Image("vacancy.info")
                .resizable()
                .frame(width: 14, height: 14)
            Text("테마는 어떻게 적용하나요?")
                .font(STFont.detailsSemibold)
                .foregroundColor(.secondary)
        }
        Text("시간표 적용은 시간표 목록 > 더보기 버튼 > 테마 설정에서 개별적으로 적용할 수 있어요.")
            .font(STFont.details)
            .foregroundColor(.secondary)
            .lineSpacing(1.4)
    }
    .padding(.top, 25)
    .padding(.horizontal, -12)
}

private struct ThemeScrollView: View {
    let themes: [Theme]
    var openNewThemeSheet: (() -> Void)? = nil
    let action: (Theme) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                if let openNewThemeSheet {
                    Button {
                        openNewThemeSheet()
                    } label: {
                        VStack {
                            Image("theme.new")
                            Text("새 테마")
                                .font(STFont.detailLabel)
                                .padding(.top, 5)
                        }
                    }
                }
                
                ForEach(themes, id: \.id) { theme in
                    ThemeButton(theme: theme, action: { action(theme) })
                        .id(theme.id)
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 8)
        }
    }
}

private struct ThemeButton: View {
    let theme: Theme
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack {
                themeIconView
                themeInfoView
                    .padding(.top, 5)
            }
        }
    }

    @ViewBuilder private var themeIconView: some View {
        if theme.isCustom {
            ThemeIcon(theme: theme)
                .frame(width: 80, height: 78)
                .overlay(
                    Image("theme.ellipsis").offset(x: 4, y: -4),
                    alignment: .topTrailing
                )
        } else {
            Image(theme.theme?.imageName ?? "")
                .frame(width: 80, height: 78)
        }
    }

    private var themeInfoView: some View {
        VStack {
            Text(theme.name)
                .font(STFont.detailLabel)
                .frame(width: 70, height: 15)
        }
    }
}

#if DEBUG
    struct ThemeSettingScene_Previews: PreviewProvider {
        static var previews: some View {
            let preview = DIContainer.preview
            preview.appState.timetable.configuration.autoFit = false
            return ThemeSettingScene(viewModel: .init(container: preview))
        }
    }
#endif
