//
//  LectureEditDetailScene.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import DependenciesAdditions
import DependenciesUtility
import MemberwiseInit
import SharedUIComponents
import SwiftUI
import ThemesInterface
import TimetableInterface
import TimetableUIComponents

struct LectureEditDetailScene: View {
    @Dependency(\.application) private var application

    @State private var viewModel: LectureEditDetailViewModel
    @State private var editMode: EditMode = .inactive
    @State private var isMapViewOpened: Bool = true
    @State private var showCancelConfirmation: Bool = false
    @State private var showResetConfirmation: Bool = false
    @State private var showDeleteConfirmation: Bool = false

    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @Environment(\.timetableViewModel) private var timetableViewModel
    @Environment(\.themeViewModel) private var themeViewModel
    @Environment(\.errorAlertHandler) private var errorAlertHandler
    @Environment(\.lectureTimeConflictHandler) private var conflictHandler

    let displayMode: DisplayMode
    let paths: Binding<[TimetableDetailSceneTypes]>

    init(
        timetableViewModel: TimetableViewModel? = nil,
        entryLecture: Lecture,
        displayMode: DisplayMode,
        paths: Binding<[TimetableDetailSceneTypes]> = .constant([])
    ) {
        _viewModel = .init(initialValue: .init(timetableViewModel: timetableViewModel, entryLecture: entryLecture))
        self.displayMode = displayMode
        self.paths = paths
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Group {
                    firstDetailSection
                    secondDetailSection
                    timePlaceSection
                }
                .padding()
                .padding(.horizontal, 5)
                .background(TimetableAsset.groupForeground.swiftUIColor)

                Group {
                    actionButtonsSection
                }
                .padding()
                .padding(.horizontal, 5)
                .background(TimetableAsset.groupForeground.swiftUIColor)
            }
            .padding(.vertical, 20)
            .padding(.bottom, 40)
        }
        .withResponsiveTouch()
        .task {
            await viewModel.fetchBuildingList()
        }
        .background(TimetableAsset.groupBackground.swiftUIColor)
        .environment(\.editMode, $editMode)
        .environment(viewModel)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(editMode.isEditing)
        .navigationTitle(displayMode.isPreview ? "세부사항" : "")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                cancelButton
            }
            ToolbarItem(placement: .topBarTrailing) {
                HStack {
                    if shouldShowToolbarActions {
                        toolbarActionButtons
                    }
                    editOrSaveButton
                }
            }
        }
        .toolbarBackground(TimetableAsset.navBackground.swiftUIColor, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .alert("변경사항을 취소하시겠습니까?", isPresented: $showCancelConfirmation) {
            Button("취소", role: .cancel) {}
            Button("확인") {
                cancelEditing()
            }
        } message: {
            Text("편집 중인 내용이 모두 사라집니다.")
        }
        .alert("강의 초기화", isPresented: $showResetConfirmation) {
            Button("취소", role: .cancel) {}
            Button("초기화", role: .destructive) {
                errorAlertHandler.withAlert {
                    try await viewModel.resetLecture()
                    editMode = .inactive
                    application.dismissKeyboard()
                }
            }
        } message: {
            Text("이 강의에 적용한 수정 사항을 모두 초기화하시겠습니까?")
        }
        .alert("강의를 삭제하시겠습니까?", isPresented: $showDeleteConfirmation) {
            Button("취소", role: .cancel) {}
            Button("삭제", role: .destructive) {
                errorAlertHandler.withAlert {
                    try await viewModel.deleteLecture()
                    dismiss()
                }
            }
        }
    }

    @ViewBuilder private var cancelButton: some View {
        switch displayMode {
        case .normal where editMode.isEditing:
            Button {
                if viewModel.hasUnsavedChanges {
                    showCancelConfirmation = true
                } else {
                    cancelEditing()
                }
            } label: {
                Text("취소")
            }
        case .create:
            Button {
                dismiss()
            } label: {
                Text("취소")
            }
        case let .preview(shouldHideDismissButton) where !shouldHideDismissButton:
            Button {
                dismiss()
            } label: {
                Text("취소")
            }
        default:
            EmptyView()
        }
    }

    private func cancelEditing() {
        viewModel.cancelEdit()
        editMode = .inactive
        application.dismissKeyboard()
    }

    @ViewBuilder private var editOrSaveButton: some View {
        switch displayMode {
        case .normal:
            Button {
                if editMode == .active {
                    editMode = .transient
                    errorAlertHandler.withAlert {
                        do {
                            try await conflictHandler.withConflictHandling { overrideOnConflict in
                                try await viewModel.saveEditableLecture(overrideOnConflict: overrideOnConflict)
                            }
                            editMode = .inactive
                        } catch {
                            // 에러가 발생하거나 취소된 경우 변경사항 되돌리기
                            viewModel.cancelEdit()
                            editMode = .inactive
                            throw error
                        }
                    }
                } else {
                    editMode = .active
                }
            } label: {
                Text(editMode.isEditing ? "저장" : "편집")
            }
        case .create:
            Button {
                errorAlertHandler.withAlert {
                    do {
                        try await conflictHandler.withConflictHandling { overrideOnConflict in
                            try await viewModel.addCustomLecture(overrideOnConflict: overrideOnConflict)
                        }
                        dismiss()
                    } catch {
                        // 에러가 발생하거나 취소된 경우
                        throw error
                    }
                }
            } label: {
                Text("저장")
            }
        case .preview:
            EmptyView()
        }
    }

    private var shouldShowToolbarActions: Bool {
        !viewModel.entryLecture.isCustom && !editMode.isEditing && (displayMode == .normal || displayMode.isPreview)
    }

    private var toolbarActionButtons: some View {
        HStack {
            // 공석알림 버튼
            Button {
                errorAlertHandler.withAlert {
                    try await viewModel.toggleVacancyNotification()
                }
            } label: {
                Image(
                    uiImage: viewModel.isVacancyNotificationEnabled
                        ? TimetableAsset.searchVacancyFill
                            .image : TimetableAsset.searchVacancy.image
                )
            }

            // 북마크 버튼
            Button {
                errorAlertHandler.withAlert {
                    try await viewModel.toggleBookmark()
                }
            } label: {
                Image(
                    uiImage: viewModel.isBookmarked
                        ? TimetableAsset.navBookmarkOn.image
                        : TimetableAsset.navBookmark
                            .image
                )
            }
        }
    }

    private var firstDetailSection: some View {
        VStack(spacing: 20) {
            EditableRow(label: "강의명", keyPath: \.courseTitle)
            EditableRow(label: "교수", keyPath: \.instructor)
            if viewModel.entryLecture.isCustom {
                EditableRow(label: "학점", keyPath: \.credit)
            }
            HStack {
                DetailLabel(text: "색상")
                LectureColorPreviewButton(
                    lectureColor: resolvedColor(for: viewModel.editableLecture),
                    title: nil,
                    trailingImage: editMode.isEditing ? TimetableAsset.chevronRight.swiftUIImage : nil
                ) {
                    paths.wrappedValue.append(.lectureColorSelection(viewModel))
                }
                .disabled(!editMode.isEditing)
            }
        }
    }

    private var secondDetailSection: some View {
        VStack(spacing: 20) {
            if !viewModel.entryLecture.isCustom {
                EditableRow(label: "학과", keyPath: \.department)
                EditableRow(label: "학년", keyPath: \.academicYear)
                EditableRow(label: "학점", keyPath: \.credit)
                EditableRow(label: "분류", keyPath: \.classification)
                EditableRow(label: "구분", keyPath: \.category)

                // 2025년부터 구)교양영역 제공
                if let currentYear = timetableViewModel.currentTimetable?.quarter.year, currentYear >= 2025 {
                    EditableRow(label: "구) 교양영역", keyPath: \.categoryPre2025)
                }

                EditableRow(label: "강좌번호", readOnly: true, keyPath: \.courseNumber)
                EditableRow(label: "분반번호", readOnly: true, keyPath: \.lectureNumber)
                EditableRow(label: "정원(재학생)", readOnly: true, keyPath: \.quotaDescription)
            }
            EditableRow(label: "비고", multiline: true, keyPath: \.remark)
        }
    }

    private var timePlaceSection: some View {
        VStack {
            Text("시간 및 장소")
                .font(.system(size: 14))
                .foregroundColor(.label.opacity(0.8))
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(Array(viewModel.editableLecture.timePlaces.enumerated()), id: \.element.id) { index, _ in
                HStack {
                    TimePlaceEditableRow(timePlace: $viewModel.editableLecture.timePlaces[index])

                    if editMode.isEditing && viewModel.canRemoveTimePlace {
                        Button {
                            withAnimation(.defaultSpring) {
                                viewModel.removeTimePlace(at: index)
                            }
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.red)
                        }
                        .padding(.leading, 8)
                    }
                }
            }

            if editMode.isEditing {
                Button {
                    withAnimation(.defaultSpring) {
                        viewModel.addTimePlace()
                    }
                } label: {
                    Text("+ 시간 추가")
                        .font(.system(size: 16))
                }
                .padding(.top, 5)
            } else if viewModel.showMapView {
                if isMapViewOpened {
                    LectureMapView(
                        buildings: viewModel.buildings,
                        showMismatchWarning: viewModel.showMapMismatchWarning
                    )
                }
                MapToggleButton(isOpen: $isMapViewOpened) {
                    withAnimation(.defaultSpring) {
                        isMapViewOpened.toggle()
                    }
                }
            }
        }
    }

    @ViewBuilder private var actionButtonsSection: some View {
        switch displayMode {
        case .normal:
            VStack(spacing: 20) {
                if !viewModel.entryLecture.isCustom && editMode.isEditing {
                    Button {
                        showResetConfirmation = true
                    } label: {
                        Text("초기화")
                            .font(.system(size: 16))
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity)
                    }
                }

                if !editMode.isEditing {
                    Button {
                        showDeleteConfirmation = true
                    } label: {
                        Text("삭제")
                            .font(.system(size: 16))
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        default:
            EmptyView()
        }
    }
}

extension LectureEditDetailScene {
    enum DisplayMode: Equatable {
        case normal
        case create
        case preview(shouldHideDismissButton: Bool)

        var isPreview: Bool {
            if case .preview = self {
                return true
            }
            return false
        }
    }

    private func resolvedColor(for lecture: Lecture) -> LectureColor {
        TimetablePainter(
            currentTimetable: timetableViewModel.currentTimetable,
            selectedLecture: nil,
            preferredTheme: nil,
            availableThemes: themeViewModel.availableThemes,
            configuration: .init()
        )
        .resolveColor(for: lecture)
    }
}

#Preview {
    NavigationStack {
        LectureEditDetailScene(
            timetableViewModel: .init(),
            entryLecture: PreviewHelpers.preview(id: "1").lectures.first!,
            displayMode: .normal
        )
    }
    .tint(.label)
}
