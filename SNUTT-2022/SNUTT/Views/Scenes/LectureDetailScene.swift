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
    @State private var reviewId: String? = ""
    @State private var syllabusURL: String = ""
    @State private var showSyllabusWebView = false
    @State private var isMapViewExpanded: Bool = false

    private var buildings: [Building] {
        lecture.timePlaces.compactMap { $0.building }.flatMap { $0 }
    }

    private var buildingDictList: [Location: String] {
        var dict: [Location: String] = [:]
        buildings.forEach { dict[$0.locationInDMS] = $0.number + "동" }
        return dict
    }

    private var isGwanak: Bool {
        buildings.allSatisfy { $0.campus == .GWANAK }
    }
    
    private var didPlaceEdited: Bool {
        !lecture.timePlaces.allSatisfy { timeplace in
            if let building = timeplace.building {
                return building.allSatisfy {
                    $0.number == timeplace.place.split(separator: "-").first!
                }
            }
            return timeplace.place.isEmpty
        }
    }

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
                                DetailLabel(text: "정원(재학생)")
                                EditableTextField(text: .constant("\(lecture.quota)(\(lecture.nonFreshmanQuota))"), readOnly: true)
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

                    VStack(alignment: .leading) {
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
                        } else {
                            if viewModel.supportForMapViewEnabled &&
                                !buildings.isEmpty && isGwanak
                            {
                                if isMapViewExpanded {
                                    Group {
                                        LectureMapView(buildings: buildingDictList)
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 256)
                                            .padding(.top, 4)
                                        
                                        if didPlaceEdited {
                                            Text("* 장소를 편집한 경우, 실제 위치와 다르게 표시될 수 있습니다.")
                                                .font(.system(size: 13))
                                                .foregroundColor(STColor.darkGray.opacity(0.6))
                                                .padding(.top, 8)
                                        }
                                    }
                                    .animation(.linear(duration: 0.2), value: isMapViewExpanded)
                                    .transition(.asymmetric(insertion: .opacity, removal: .identity))
                                        
                                    Button {
                                        withAnimation {
                                            isMapViewExpanded.toggle()
                                        }
                                    } label: {
                                        HStack(spacing: 0) {
                                            Spacer()
                                            Text("지도 닫기")
                                                .font(.system(size: 14))
                                                .foregroundColor(colorScheme == .dark
                                                    ? STColor.gray30
                                                    : STColor.darkGray)
                                            Spacer().frame(width: 4)
                                            Image("chevron.down").rotationEffect(.init(degrees: 180.0))
                                            Spacer()
                                        }
                                    }
                                    .padding(.top, 8)
                                    
                                } else {
                                    Button {
                                        withAnimation(.easeOut(duration: 0.3)) {
                                            isMapViewExpanded.toggle()
                                        }
                                    } label: {
                                        HStack(spacing: 0) {
                                            Spacer()
                                            Image("map.open")
                                            Spacer().frame(width: 8)
                                            Text("지도에서 보기")
                                                .font(.system(size: 14))
                                                .foregroundColor(colorScheme == .dark
                                                    ? STColor.gray30
                                                    : STColor.darkGray)
                                            Spacer().frame(width: 4)
                                            Image("chevron.down")
                                            Spacer()
                                        }
                                    }
                                    .padding(.top, 8)
                                }
                            }
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
                            ReviewScene(viewModel: .init(container: viewModel.container), isMainWebView: false, detailId: reviewId)
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
                                    lecture = originalLecture
                                    editMode = .inactive
                                    resignFirstResponder()
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
        .onAppear {
            isMapViewExpanded = viewModel.shouldOpenLectureMapView()
        }
        .onChange(of: isMapViewExpanded) {
            viewModel.setIsMapViewExpanded($0)
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
                let isBookmarked = viewModel.isBookmarked(lecture: lecture)
                let isVacancyNotificationEnabled = viewModel.isVacancyNotificationEnabled(lecture: lecture)
                switch displayMode {
                case .normal, .preview:
                    HStack {
                        if !lecture.isCustom && !editMode.isEditing {
                            Button {
                                Task {
                                    isVacancyNotificationEnabled
                                        ? await viewModel.deleteVacancyLecture(lecture: lecture)
                                        : await viewModel.addVacancyLecture(lecture: lecture)
                                }
                            } label: {
                                isVacancyNotificationEnabled
                                    ? Image("nav.vacancy.on")
                                    : Image("nav.vacancy.off")
                            }

                            Button {
                                Task {
                                    isBookmarked
                                        ? await viewModel.undoBookmarkLecture(lecture: lecture)
                                        : await viewModel.bookmarkLecture(lecture: lecture)
                                }
                            } label: {
                                isBookmarked
                                    ? Image("nav.bookmark.on")
                                    : Image("nav.bookmark")
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
        .alert(viewModel.errorTitle, isPresented: $viewModel.isErrorAlertPresented, actions: {}) {
            Text(viewModel.errorMessage)
        }
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
