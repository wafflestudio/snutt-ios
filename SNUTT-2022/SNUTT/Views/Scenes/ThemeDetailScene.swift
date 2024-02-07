//
//  ThemeDetailScene.swift
//  SNUTT
//
//  Created by 이채민 on 2024/01/17.
//

import Combine
import SwiftUI

struct ThemeDetailScene: View {
    @ObservedObject var viewModel: ThemeDetailViewModel
    @State var theme: Theme
    var themeType: ThemeType
    @State var openPickerIndex: Int?
    
    @State private var unDidDefault = false
    @State private var isUndoDefaultAlertPresented = false
    @State private var isDefaultChanged = false

    init(viewModel: ThemeDetailViewModel, theme: Theme, themeType: ThemeType, openPickerIndex _: Int? = nil) {
        self.viewModel = viewModel
        _theme = State(initialValue: theme)
        self.themeType = themeType
        _openPickerIndex = State(initialValue: theme.colors.count - 1)
    }

    enum ThemeType {
        case basic
        case custom
        case new
    }

    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                HStack {
                    DetailLabel(text: "테마명")
                    switch themeType {
                    case .basic:
                        Text("\(theme.name)")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(Color(uiColor: .label.withAlphaComponent(0.6)))
                    case .custom, .new:
                        EditableTextField(text: $theme.name, readOnly: false)
                            .environment(\.editMode, Binding.constant(.active))
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 15)
            }
            .background(STColor.groupForeground)
            .border(Color.black.opacity(0.1), width: 0.5)
            .padding(.vertical, 20)

            switch themeType {
            case .basic:
                VStack(spacing: 0) {
                    let colorList = theme.theme?.getLectureColorList() ?? []
                    ForEach(colorList.indices.dropFirst(1), id: \.self) { index in
                        HStack(alignment: .center) {
                            DetailLabel(text: "색상 \(index)")
                            LectureColorPreview(lectureColor: colorList[index])
                                .frame(height: 25)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)

                        Divider()
                            .frame(height: 1)
                    }
                }
                .background(STColor.groupForeground)
                .border(Color.black.opacity(0.1), width: 0.5)
                .padding(.vertical, 10)

            case .custom, .new:
                VStack(spacing: 0) {
                    HStack {
                        DetailLabel(text: "색 조합")
                        Spacer()
                    }
                    .padding(.horizontal, 20)

                    VStack {
                        Spacer(minLength: 5)
                        ForEach(theme.colors.indices, id: \.self) { index in

                            VStack {
                                HStack {
                                    DetailLabel(text: "색상 \(index + 1)")
                                    Button {
                                        if openPickerIndex == index {
                                            openPickerIndex = nil
                                        } else {
                                            openPickerIndex = index
                                        }
                                    } label: {
                                        LectureColorPreview(lectureColor: theme.colors[index])
                                            .frame(height: 25)
                                    }

                                    Spacer()

                                    Button {
                                        theme = viewModel.copyThemeColor(theme: theme, index: index)
                                        openPickerIndex = nil
                                    } label: {
                                        Image("menu.duplicate")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 30)
                                            .opacity(0.5)
                                    }

                                    Button {
                                        theme = viewModel.deleteThemeColor(theme: theme, index: index)
                                    } label: {
                                        Image("xmark.black")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 15)
                                            .opacity(0.5)
                                    }
                                    .padding(.horizontal, 10)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 5)

                                if openPickerIndex == index {
                                    VStack {
                                        Group {
                                            ColorPicker("글꼴색", selection: $theme.colors[index].fg, supportsOpacity: false)
                                            ColorPicker("배경색", selection: $theme.colors[index].bg, supportsOpacity: false)
                                        }
                                        .foregroundColor(STColor.disabled)
                                        .font(STFont.detailLabel)
                                    }
                                    .padding(.leading, 80)
                                    .padding(.trailing, 20)
                                    .padding(.vertical, 10)
                                    .transition(.move(edge: .top).combined(with: .opacity))
                                }

                                Divider()
                                    .frame(height: 1)
                            }
                            .animation(nil, value: theme.colors.count)
                        }
                    }
                    .background(STColor.groupForeground)
                    .border(Color.black.opacity(0.1), width: 0.5)
                    .padding(.vertical, 10)

                    Button {
                        theme = viewModel.getThemeNewColor(theme: theme)
                        openPickerIndex = theme.colors.count - 1
                    } label: {
                        Text("+ 색상 추가")
                            .font(.system(size: 16))
                            .foregroundColor(STColor.disabled)
                            .animation(.customSpring, value: theme.colors.count)
                    }
                    .padding(.top, 10)
                }
            }

            VStack(spacing: 0) {
                Toggle("기본 테마로 지정", isOn: $theme.isDefault)
                    .animation(.easeInOut, value: theme.isDefault)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 10)
                    .onChange(of: theme.isDefault) { newValue in
                        if newValue == false {
                            unDidDefault = true
                        }
                        isDefaultChanged = true
                    }
            }
            .background(STColor.groupForeground)
            .border(Color.black.opacity(0.1), width: 0.5)
            .padding(.vertical, 10)

            HStack {
                DetailLabel(text: "미리보기")
                Spacer()
            }
            .padding(.horizontal, 24)

            VStack(spacing: 0) {
                TimetableZStack(current: viewModel.currentTimetable, config: viewModel.configuration)
                    .frame(height: 500)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(lineWidth: 0.5)
                        .foregroundColor(Color(UIColor.quaternaryLabel))
                    )
                    .shadow(color: .black.opacity(0.05), radius: 3)
                    .padding(15)
                    .environment(\.dependencyContainer, nil)
            }
            .background(STColor.groupForeground)
            .border(Color.black.opacity(0.1), width: 0.5)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .padding(.bottom, 15)
            .padding(.horizontal, 10)

            Spacer(minLength: 30)
        }
        .onChange(of: theme) { newTheme in
            viewModel.currentTimetable?.selectedTheme = newTheme
        }
        .background(STColor.groupBackground)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(themeType == .basic ? "제공 테마" : "커스텀 테마")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Text("취소")
                        .foregroundColor(Color(uiColor: .label))
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    Task {
                        switch themeType {
                        case .basic:
                            if unDidDefault { isUndoDefaultAlertPresented = true } else if isDefaultChanged {
                                let success = await viewModel.saveBasicTheme(theme: theme)
                                if success {
                                    dismiss()
                                }
                            } else {
                                dismiss()
                            }
                        case .custom:
                            if unDidDefault { isUndoDefaultAlertPresented = true } else {
                                let success = await viewModel.updateTheme(theme: theme)
                                if success {
                                    dismiss()
                                }
                            }
                        case .new:
                            let success = await viewModel.addTheme(theme: theme)
                            if success {
                                dismiss()
                            }
                        }
                    }
                } label: {
                    Text("저장")
                        .foregroundColor(Color(uiColor: .label))
                }
            }
        }
        .alert("기본 테마 지정을 취소하시겠습니까?\n'SNUTT'테마가 기본 적용됩니다.", isPresented: $isUndoDefaultAlertPresented) {
            Button("취소", role: .cancel) {}
            Button("확인", role: .destructive) {
                Task {
                    let success = await theme.isCustom ? viewModel.updateTheme(theme: theme) : viewModel.saveBasicTheme(theme: theme)
                    if success {
                        dismiss()
                    }
                }
            }
        }
        .alert(viewModel.errorTitle, isPresented: $viewModel.isErrorAlertPresented) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}

struct ThemeDetailScene_Previews: PreviewProvider {
    static var previews: some View {
        ThemeDetailScene(viewModel: .init(container: .preview), theme: .init(from: .init(id: UUID().uuidString, theme: 0, name: "새 테마", colors: [ThemeColorDto(bg: STColor.cyan.toHex(), fg: Color.white.toHex())], isDefault: false, isCustom: true)), themeType: .new)
    }
}
