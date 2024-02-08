//
//  ThemeSettingScene.swift
//  SNUTT
//
//  Created by 이채민 on 2024/01/17.
//

import Combine
import SwiftUI
import UIKit

struct ThemeSettingScene: View {
    @ObservedObject var viewModel: ThemeSettingViewModel

    var body: some View {
        ZStack {
            Form {
                Section(header: Text("커스텀 테마")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            VStack {
                                Button {
                                    viewModel.openNewThemeSheet()
                                } label: {
                                    Image("theme.new")
                                }
                                Text("새 테마")
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 5)
                                    .font(STFont.detailLabel)
                            }

                            ForEach(viewModel.themes, id: \.id) {
                                theme in
                                if theme.isCustom {
                                    Button {
                                        viewModel.openBottomSheet(for: theme)
                                    } label: {
                                        VStack {
                                            ThemeIcon(theme: theme)
                                                .overlay(
                                                    theme.isDefault ? Image("theme.pin")
                                                        .offset(x: -8, y: -8) : nil,
                                                    alignment: .topLeading
                                                )
                                            HStack(spacing: 0) {
                                                Text(theme.name)
                                                    .font(STFont.detailLabel)
                                                Image("theme.chevron.right")
                                            }
                                            .frame(width: 70, height: 15)
                                            .padding(.vertical, 5)
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 10)
                        }
                    }
                }

                Section(header: Text("제공 테마")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(viewModel.themes, id: \.id) {
                                theme in
                                if !theme.isCustom {
                                    Button {
                                        viewModel.openBottomSheet(for: theme)
                                    } label: {
                                        VStack {
                                            Image(theme.theme?.imageName ?? "")
                                                .overlay(
                                                    theme.isDefault ? Image("theme.pin")
                                                        .offset(x: -8, y: -8) : nil,
                                                    alignment: .topLeading
                                                )
                                                .frame(width: 88, height: 90)

                                            HStack(spacing: 0) {
                                                Text(theme.name)
                                                    .font(STFont.detailLabel)
                                                Image("theme.chevron.right")
                                            }
                                            .padding(.horizontal, 10)
                                            .padding(.bottom, 5)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.top, 5)
                    .padding(.bottom, 10)
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

struct ThemeButton: View {
    var theme: Theme
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack {
                if theme.isCustom {
                    ThemeIcon(theme: theme)
                } else {
                    Image(theme.theme?.imageName ?? "")
                }
                HStack {
                    Text(theme.name)
                        .padding(.vertical, 5)
                        .font(STFont.detailLabel)
                    Image("vacancy.chevron.right")
                }
            }
            if theme.isDefault {
                Image("theme.pin")
                    .offset(x: -5, y: -5)
            }
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
