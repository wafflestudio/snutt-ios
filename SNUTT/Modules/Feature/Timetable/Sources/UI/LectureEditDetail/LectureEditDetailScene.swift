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

    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @Environment(\.timetableViewModel) private var timetableViewModel
    @Environment(\.themeViewModel) private var themeViewModel
    @Environment(\.errorAlertHandler) private var errorAlertHandler

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
                editOrSaveButton
            }
        }
        .toolbarBackground(TimetableAsset.navBackground.swiftUIColor, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    @ViewBuilder private var cancelButton: some View {
        switch displayMode {
        case .normal where editMode.isEditing:
            Button {
                viewModel.editableLecture = viewModel.entryLecture
                editMode = .inactive
                application.dismissKeyboard()
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

    @ViewBuilder private var editOrSaveButton: some View {
        switch displayMode {
        case .normal:
            Button {
                errorAlertHandler.withAlert {
                    if editMode == .active {
                        editMode = .transient
                        defer {
                            editMode = .inactive
                        }
                        try await viewModel.saveEditableLecture()
                    } else {
                        editMode = .active
                    }
                }
            } label: {
                Text(editMode.isEditing ? "저장" : "편집")
            }
        case .create:
            Button {
                // TODO: addCustomLecture
            } label: {
                Text("저장")
            }
        case let .preview(shouldHideDismissButton):
            EmptyView()
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

            ForEach(0 ..< viewModel.editableLecture.timePlaces.count, id: \.self) { index in
                VStack(spacing: 5) {
                    EditableRow(label: "시간", keyPath: \.timePlaces[index])
                    EditableRow(label: "장소", keyPath: \.timePlaces[index].place)
                }
            }

            if editMode.isEditing {
                // TODO: 시간 추가 버튼
//                Button {
//                    lecture = viewModel.getLectureWithNewTimePlace(lecture: lecture)
//                } label: {
//                    Text("+ 시간 추가")
//                        .font(.system(size: 16))
//                        .animation(.customSpring, value: lecture.timePlaces.count)
//                }
//                .padding(.top, 5)
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
            entryLecture: PreviewHelpers.preview(id: "1").lectures.first!, displayMode: .normal
        )
    }
    .tint(.label)
}
