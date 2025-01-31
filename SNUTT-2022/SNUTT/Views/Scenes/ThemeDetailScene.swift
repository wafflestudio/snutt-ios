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

    @State private var isNewThemeCreated = false

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
        case downloaded
    }

    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                HStack {
                    DetailLabel(text: "테마명")
                    switch themeType {
                    case .basic, .downloaded:
                        Text("\(theme.name)")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(Color(uiColor: .label.withAlphaComponent(0.6)))
                    case .custom, .new:
                        EditableTextField(text: $theme.name, readOnly: false)
                            .environment(\.editMode, Binding.constant(.active))
                            .submitLabel(.done)
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
                                        .font(STFont.regular14.font)
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
                            .font(STFont.regular14.font)
                            .foregroundColor(STColor.disabled)
                            .animation(.customSpring, value: theme.colors.count)
                    }
                    .padding(.top, 8)
                }
                
            case .downloaded:
                VStack(spacing: 0) {
                    ForEach(theme.colors.indices, id: \.self) { index in
                        HStack(alignment: .center) {
                            DetailLabel(text: "색상 \(index + 1)")
                            LectureColorPreview(lectureColor: theme.colors[index])
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
            }

            HStack {
                DetailLabel(text: "미리보기")
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 30)

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
        .animation(.customSpring, value: theme.colors.count)
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
                switch themeType {
                case .basic, .downloaded:
                    Button {
                        dismiss()
                    } label: {
                        Text("확인")
                            .foregroundColor(Color(uiColor: .label))
                    }
                case .custom:
                    Button {
                        Task {
                            let success = await viewModel.updateTheme(theme: theme)
                            if success {
                                dismiss()
                            }
                        }
                    } label: {
                        Text("저장")
                            .foregroundColor(Color(uiColor: .label))
                    }
                case .new:
                    Button {
                        isNewThemeCreated = true
                    } label: {
                        Text("저장")
                            .foregroundColor(Color(uiColor: .label))
                    }
                }
            }
        }
        .alert("새 테마를 현재 시간표에 적용하시겠습니까?", isPresented: $isNewThemeCreated) {
            Button("취소", role: .cancel) {
                Task {
                    let success = await viewModel.addTheme(theme: theme, apply: false)
                    if success {
                        dismiss()
                    }
                }
            }
            Button("확인") {
                Task {
                    let success = await viewModel.addTheme(theme: theme, apply: true)
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

#if DEBUG
    struct ThemeDetailScene_Previews: PreviewProvider {
        static var previews: some View {
            ThemeDetailScene(viewModel: .init(container: .preview), theme: .init(id: UUID().uuidString, name: "새 테마", colors: [LectureColor(fg: Color.white, bg: STColor.cyan)], isCustom: true), themeType: .new)
        }
    }
#endif
