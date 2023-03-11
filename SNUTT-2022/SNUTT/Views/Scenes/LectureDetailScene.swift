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
    @State private var isBookmarked: Bool

    init(viewModel: ViewModel, lecture: Lecture, displayMode: DisplayMode, bookmarks _: [Lecture]) {
        self.viewModel = viewModel
        _lecture = State(initialValue: lecture)
        _editMode = State(initialValue: displayMode == .create ? .active : .inactive)
        _isBookmarked = State(initialValue: viewModel.getBookmarkedLecture(lecture) != nil)
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
    @State private var reviewId: String? = ""
    @State private var syllabusURL: String = ""
    @State private var showSyllabusWebView = false
    @State private var isUndoBookmarkAlertPresented = false
    @State private var isBookmarkAlertPresented = false

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

                        if displayMode != .preview {
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

                    if !lecture.isCustom && displayMode != .create && !editMode.isEditing {
                        DetailButton(text: "강의계획서") {
                            Task {
                                syllabusURL = await viewModel.fetchSyllabusURL(of: lecture)
                                if !syllabusURL.isEmpty {
                                    showSyllabusWebView = true
                                }
                            }
                        }.fullScreenCover(isPresented: $showSyllabusWebView) {
                            SyllabusWebView(url: $syllabusURL)
                                .edgesIgnoringSafeArea(.all)
                        }

                        DetailButton(text: "강의평") {
                            if reviewId == nil {
                                viewModel.presentEmailVerifyAlert()
                            } else {
                                showReviewWebView = true
                            }
                        }
                        .alert(viewModel.errorTitle, isPresented: $viewModel.isEmailVerifyAlertPresented, actions: {
                            Button("확인") {
                                viewModel.selectedTab = .review
                            }
                            Button("취소", role: .cancel) {}
                        }, message: {
                            Text(viewModel.errorMessage)
                        })
                        .onAppear {
                            Task {
                                reviewId = await viewModel.fetchReviewId(of: lecture)
                            }
                        }
                        .onChange(of: reviewId) { newValue in
                            guard let reviewId = newValue else { return }
                            viewModel.reloadDetailWebView(detailId: reviewId)
                        }
                        .sheet(isPresented: $showReviewWebView) {
                            ReviewScene(viewModel: .init(container: viewModel.container), isMainWebView: false, detailId: $reviewId)
                                .id(colorScheme)
                                .id(reviewId)
                        }
                    }

                    if !lecture.isCustom && displayMode == .normal && editMode.isEditing {
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

                    if displayMode == .normal && !editMode.isEditing {
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
        .navigationTitle(displayMode == .preview ? "세부사항" : "")
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
                case .normal, .preview:
                    HStack {
                        if !editMode.isEditing {
                            Button {
                                if isBookmarked {
                                    isUndoBookmarkAlertPresented = true
                                } else {
                                    Task {
                                        let success = await viewModel.bookmarkLecture(lecture: lecture)
                                        if success {
                                            self.isBookmarked = true
                                        }
                                    }
                                }
                            } label: {
                                isBookmarked ? Image("nav.bookmark.on") : Image("nav.bookmark")
                            }
                        }
                        if displayMode == .normal {
                            Button {
                                if editMode.isEditing {
                                    guard let tempLecture = tempLecture else { return }
                                    // save
                                    Task {
                                        let success = await viewModel.updateLecture(oldLecture: tempLecture, newLecture: lecture)

                                        if success, let updatedLecture = viewModel.findLectureInCurrentTimetable(lecture) {
                                            lecture = updatedLecture
                                            editMode = .inactive
                                            resignFirstResponder()
                                            return
                                        }

                                        // non-duplicate failures
                                        if !success, !viewModel.isLectureOverlapped {
                                            lecture = tempLecture
                                            editMode = .inactive
                                            resignFirstResponder()
                                            return
                                        }

                                        // in case of duplicate failures, delegate the rollback operation to lecture overlap alert.
                                    }
                                } else {
                                    // edit
                                    tempLecture = lecture
                                    editMode = .active
                                    resignFirstResponder()
                                }
                            } label: {
                                Text(editMode.isEditing ? "저장" : "편집")
                            }
                        }
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
                }
            }
        }
        .environment(\.editMode, $editMode)
        .alert(viewModel.errorTitle, isPresented: $viewModel.isLectureOverlapped) {
            Button {
                Task {
                    var success = false
                    switch displayMode {
                    case .create:
                        success = await viewModel.addCustomLecture(lecture: lecture, isForced: true)
                    case .normal:
                        success = await viewModel.updateLecture(oldLecture: tempLecture, newLecture: lecture, isForced: true)
                    case .preview:
                        return
                    }

                    if success {
                        editMode = .inactive
                        resignFirstResponder()
                        dismiss()
                    }
                }
            } label: {
                Text("확인")
            }

            Button("취소", role: .cancel) {
                viewModel.isLectureOverlapped = false
                guard let tempLecture = tempLecture else { return }
                lecture = tempLecture
            }
        } message: {
            Text(viewModel.errorMessage)
        }
        .alert("강의를 관심강좌에서 제외하시겠습니까?", isPresented: $isUndoBookmarkAlertPresented) {
            Button("취소", role: .cancel, action: {})
            Button("확인", role: .destructive) {
                Task {
                    let success = await viewModel.undoBookmarkLecture(selected: lecture)
                    if success {
                        self.isBookmarked = false
                    }
                }
            }
        }
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
//    struct LectureDetailList_Previews: PreviewProvider {
//        static var previews: some View {
//            NavigationView {
//                LectureDetailScene(viewModel: .init(container: .preview), lecture: .preview, displayMode: .normal)
//                    .navigationBarTitleDisplayMode(.inline)
//            }
//        }
//    }
#endif
