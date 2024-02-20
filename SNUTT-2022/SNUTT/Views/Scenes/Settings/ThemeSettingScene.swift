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

                Section(header: Text("제공 테마")) {
                    ThemeScrollView(themes: viewModel.basicThemes) { theme in
                        viewModel.openBottomSheet(for: theme)
                    }
                }
            }
            ThemeBottomSheet(isOpen: $viewModel.isBottomSheetOpen,
                             isCustom: viewModel.targetTheme?.isCustom,
                             isDefault: viewModel.targetTheme?.isDefault,
                             openCustomThemeSheet: viewModel.openCustomThemeSheet,
                             makeCustomThemeDefault: viewModel.makeCustomThemeDefault,
                             undoCustomThemeDefault: viewModel.undoCustomThemeDefault,
                             copyTheme: viewModel.copyTheme,
                             deleteTheme: viewModel.deleteTheme,
                             openBasicThemeSheet: viewModel.openBasicThemeSheet,
                             makeBasicThemeDefault: viewModel.makeBasicThemeDefault,
                             undoBasicThemeDefault: viewModel.undoBasicThemeDefault)
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

private struct ThemeScrollView: View {
    let themes: [Theme]
    var openNewThemeSheet: (() -> Void)? = nil
    let action: (Theme) -> Void

    var body: some View {
        ScrollViewReader { proxy in
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
            .onChange(of: themes) { [oldValue = themes] newValue in
                updateScrollPosition(proxy: proxy, oldThemes: oldValue, newThemes: newValue)
            }
        }
    }

    private func updateScrollPosition(proxy: ScrollViewProxy, oldThemes: [Theme], newThemes: [Theme]) {
        let oldDefault = oldThemes.first(where: { $0.isDefault })
        let newDefault = newThemes.first(where: { $0.isDefault })
        if oldDefault?.id != newDefault?.id, let newDefaultId = newDefault?.id {
            withAnimation(.customSpring) {
                proxy.scrollTo(newDefaultId, anchor: .center)
            }
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
                    theme.isDefault ? Image("theme.pin").offset(x: -8, y: -8) : nil,
                    alignment: .topLeading
                )
        } else {
            Image(theme.theme?.imageName ?? "")
                .frame(width: 80, height: 78)
                .overlay(
                    theme.isDefault ? Image("theme.pin").offset(x: -8, y: -8) : nil,
                    alignment: .topLeading
                )
        }
    }

    private var themeInfoView: some View {
        VStack {
            HStack(spacing: 0) {
                Text(theme.name)
                    .font(STFont.detailLabel)
                Image("theme.chevron.right")
            }
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
