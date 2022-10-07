//
//  LectureDetailScene.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/03/24.
//

import Combine
import SwiftUI

struct LectureDetailScene: View {
    @ObservedObject var viewModel: ViewModel
    @State var lecture: Lecture
    var displayMode: DisplayMode

    @State private var editMode: EditMode
    @State private var tempLecture: Lecture?

    init(viewModel: ViewModel, lecture: Lecture, displayMode: DisplayMode) {
        self.viewModel = viewModel
        _lecture = State(initialValue: lecture)
        _editMode = State(initialValue: displayMode == .create ? .active : .inactive)
        self.displayMode = displayMode
    }

    enum DisplayMode {
        case normal
        case create
        case preview
    }

    @State private var isResetAlertPresented = false
    @State private var isDeleteAlertPresented = false
    @State private var showReviewWebView = false
    @State private var reviewId: String = ""

    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Group {
                    VStack(spacing: 20) {
                        HStack {
                            DetailLabel(text: "강의명")
                            EditableTextField(text: $lecture.title)
                        }
                        HStack {
                            DetailLabel(text: "교수")
                            EditableTextField(text: $lecture.instructor)
                        }
                        if lecture.isCustom {
                            HStack {
                                DetailLabel(text: "학점")
                                EditableNumberField(value: $lecture.credit)
                            }
                        }

                        HStack {
                            DetailLabel(text: "색")
                            NavigationLink {
                                LectureColorList(theme: lecture.theme ?? .snutt, colorIndex: $lecture.colorIndex, customColor: $lecture.color)
                            } label: {
                                HStack {
                                    LectureColorPreview(lectureColor: lecture.getColor())
                                        .frame(height: 25)
                                    Spacer()
                                    if editMode.isEditing {
                                        Image("chevron.right")
                                    }
                                }
                            }
                            .disabled(!editMode.isEditing)
                        }
                    }
                    .padding()

                    if !lecture.isCustom {
                        VStack(spacing: 20) {
                            HStack {
                                DetailLabel(text: "학과")
                                EditableTextField(text: $lecture.department)
                            }
                            HStack {
                                DetailLabel(text: "학년")
                                EditableTextField(text: $lecture.academicYear)
                            }
                            HStack {
                                DetailLabel(text: "학점")
                                EditableNumberField(value: $lecture.credit)
                            }
                            HStack {
                                DetailLabel(text: "분류")
                                EditableTextField(text: $lecture.classification)
                            }
                            HStack {
                                DetailLabel(text: "구분")
                                EditableTextField(text: $lecture.category)
                            }
                            HStack {
                                DetailLabel(text: "강좌번호")
                                EditableTextField(text: $lecture.courseNumber, readOnly: true)
                            }
                            HStack {
                                DetailLabel(text: "분반번호")
                                EditableTextField(text: $lecture.lectureNumber, readOnly: true)
                            }
                            HStack {
                                DetailLabel(text: "정원")
                                EditableNumberField(value: $lecture.quota, readOnly: true)
                            }
                            HStack {
                                DetailLabel(text: "비고")
                                EditableTextField(text: $lecture.remark, multiLine: true)
                            }
                        }
                        .padding()
                    } else {
                        VStack {
                            HStack {
                                DetailLabel(text: "비고")
                                EditableTextField(text: $lecture.remark, multiLine: true)
                            }
                        }
                        .padding()
                    }

                    VStack {
                        Text("시간 및 장소")
                            .font(STFont.detailLabel)
                            .foregroundColor(Color(uiColor: .label.withAlphaComponent(0.8)))
                            .frame(maxWidth: .infinity, alignment: .leading)

                        ForEach(lecture.timePlaces) { timePlace in
                            HStack(alignment: .top) {
                                VStack {
                                    HStack {
                                        DetailLabel(text: "시간")
                                        EditableTimeField(lecture: $lecture, timePlace: timePlace) {
                                            viewModel.openLectureTimeSheet(lecture: $lecture, timePlace: timePlace)
                                            resignFirstResponder()
                                        }
                                    }
                                    Spacer()
                                        .frame(height: 5)
                                    HStack {
                                        DetailLabel(text: "장소")
                                        EditableTextField(lecture: $lecture, timePlace: timePlace)
                                    }
                                }
                                .padding(.vertical, 2)

                                Spacer()

                                if editMode.isEditing {
                                    Button {
                                        lecture = viewModel.getLecture(lecture: lecture, without: timePlace)
                                    } label: {
                                        Image("xmark.black")
                                    }
                                    .padding(.top, 5)
                                }
                            }
                        }

                        if editMode.isEditing {
                            Button {
                                lecture = viewModel.getLectureWithNewTimePlace(lecture: lecture)
                            } label: {
                                Text("+ 시간 추가")
                                    .font(.system(size: 16))
                                    .animation(.customSpring, value: lecture.timePlaces.count)
                            }
                            .padding(.top, 5)
                        }
                    }
                    .padding()

                    if displayMode == .normal && !editMode.isEditing {
                        DetailButton(text: "강의계획서") {}

                        DetailButton(text: "강의평") {
                            Task {
                                await viewModel.fetchReviewId(of: lecture, bind: $reviewId)
                                showReviewWebView = true
                            }
                        }
                        .sheet(isPresented: $showReviewWebView) {
                            ReviewScene(viewModel: .init(container: viewModel.container), detailId: $reviewId)
                                .id(colorScheme)
                        }
                    }

                    if displayMode == .normal && editMode.isEditing {
                        DetailButton(text: "초기화", role: .destructive) {
                            isResetAlertPresented = true
                        }
                        .alert("강의 초기화", isPresented: $isResetAlertPresented) {
                            Button("취소", role: .cancel, action: {})
                            Button("초기화", role: .destructive, action: {
                                Task {
                                    guard let originalLecture = await viewModel.resetLecture(lecture: lecture) else { return }
                                    DispatchQueue.main.async {
                                        lecture = originalLecture
                                        editMode = .inactive
                                        resignFirstResponder()
                                    }
                                }
                            })
                        } message: {
                            Text("이 강의에 적용한 수정 사항을 모두 초기화하시겠습니까?")
                        }
                    }

                    if displayMode == .normal {
                        DetailButton(text: "삭제", role: .destructive) {
                            isDeleteAlertPresented = true
                        }
                        .alert("강의를 삭제하시겠습니까?", isPresented: $isDeleteAlertPresented) {
                            Button("취소", role: .cancel, action: {})
                            Button("삭제", role: .destructive) {
                                Task {
                                    await viewModel.deleteLecture(lecture: lecture)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 5)
                .background(STColor.groupForeground)
            }
            .animation(.customSpring, value: lecture.timePlaces.count)
            .animation(.customSpring, value: editMode.isEditing)
            .padding(.vertical, 20)
        }
        .background(STColor.groupBackground)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(editMode.isEditing)
        .navigationTitle("세부사항")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                switch displayMode {
                case .normal:
                    if editMode.isEditing {
                        Button {
                            // cancel
                            if let tempLecture = tempLecture {
                                lecture = tempLecture
                            }
                            editMode = .inactive
                            resignFirstResponder()
                        } label: {
                            Text("취소")
                        }
                    }
                case .preview, .create:
                    Button {
                        dismiss()
                    } label: {
                        Text("취소")
                            .foregroundColor(Color(uiColor: .label))
                    }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                switch displayMode {
                case .normal:
                    Button {
                        if editMode.isEditing {
                            guard let tempLecture = tempLecture else { return }
                            // save
                            Task {
                                guard let updatedLecture = await viewModel.updateLecture(oldLecture: tempLecture, newLecture: lecture) else {
                                    lecture = tempLecture
                                    return
                                }
                                lecture = updatedLecture
                            }
                            editMode = .inactive
                            resignFirstResponder()
                        } else {
                            // edit
                            tempLecture = lecture
                            editMode = .active
                            resignFirstResponder()
                        }
                    } label: {
                        Text(editMode.isEditing ? "저장" : "편집")
                    }
                case .create:
                    Button {
                        Task {
                            let success = await viewModel.addCustomLecture(lecture: lecture)
                            if success {
                                dismiss()
                            }
                        }
                    } label: {
                        Text("저장")
                    }
                case .preview:
                    EmptyView()
                }
            }
        }
        .environment(\.editMode, $editMode)
    }
}

private struct DisplayModeKey: EnvironmentKey {
    static let defaultValue: LectureDetailScene.DisplayMode = .normal
}

extension EnvironmentValues {
    var displayMode: LectureDetailScene.DisplayMode {
        get { self[DisplayModeKey.self] }
        set { self[DisplayModeKey.self] = newValue }
    }
}

struct RectangleButtonStyle: ButtonStyle {
    var color: Color? = nil
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .contentShape(Rectangle())
            .background(configuration.isPressed ? STColor.buttonPressed : (color ?? .clear))
    }
}

#if DEBUG
    struct LectureDetailList_Previews: PreviewProvider {
        static var previews: some View {
            NavigationView {
                LectureDetailScene(viewModel: .init(container: .preview), lecture: .preview, displayMode: .normal)
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
#endif
