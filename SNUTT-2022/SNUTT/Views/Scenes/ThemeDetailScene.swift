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
    
    init(viewModel: ThemeDetailViewModel, theme: Theme, themeType: ThemeType, openPickerIndex: Int? = nil) {
        self.viewModel = viewModel
        self._theme = State(initialValue: theme)
        self.themeType = themeType
        self._openPickerIndex = State(initialValue: theme.colors.count - 1)
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
                        DetailLabel(text: "\(theme.name)")
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
                                        if (openPickerIndex == index) {
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
                                
                                if (openPickerIndex == index) {
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
                switch themeType {
                case .basic:
                    Button {
                        Task {
                            await viewModel.saveBasicTheme(theme: theme)
                            dismiss()
                        }
                    } label: {
                        Text("저장")
                            .foregroundColor(Color(uiColor: .label))
                    }
                case .custom:
                    Button {
                        Task {
                            await viewModel.updateTheme(theme: theme)
                            dismiss()
                        }
                    } label: {
                        Text("저장")
                            .foregroundColor(Color(uiColor: .label))
                    }
                case .new:
                    Button {
                        Task {
                            await viewModel.addTheme(theme: theme)
                            dismiss()
                        }
                    } label: {
                        Text("저장")
                            .foregroundColor(Color(uiColor: .label))
                    }
                    
                }
            }
        }
    }
}

struct ThemeDetailScene_Previews: PreviewProvider {
    static var previews: some View {
        ThemeDetailScene(viewModel: .init(container: .preview), theme: .init(from: .init(id: UUID().uuidString, theme: 0, name: "새 테마", colors: [ThemeColorDto(bg: "#1BD0C8", fg: "#ffffff"), ThemeColorDto(bg: "#1BD0C8", fg: "#ffffff")], isDefault: false, isCustom: true)), themeType: .new)
    }
}
