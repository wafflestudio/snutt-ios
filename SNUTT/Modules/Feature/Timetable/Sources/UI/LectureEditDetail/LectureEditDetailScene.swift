//
//  LectureEditDetailScene.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import DependenciesAdditions
import DependenciesUtility
import MemberwiseInit
import ReviewsInterface
import SharedUIComponents
import SwiftUI
import ThemesInterface
import TimetableInterface
import TimetableUIComponents

struct LectureEditDetailScene: View {
    @Dependency(\.application) var application

    @State var viewModel: LectureEditDetailViewModel
    @State var editMode: EditMode
    @State private var isMapViewOpened: Bool = true
    @State var showCancelConfirmation: Bool = false
    @State private var showResetConfirmation: Bool = false
    @State private var showDeleteConfirmation: Bool = false
    @State private var syllabusURL: URL?
    @State private var showSyllabusWebView: Bool = false
    @State private var showReviewsScene: Bool = false

    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @Environment(\.timetableViewModel) private var timetableViewModel
    @Environment(\.themeViewModel) private var themeViewModel
    @Environment(\.errorAlertHandler) var errorAlertHandler
    @Environment(\.lectureTimeConflictHandler) var conflictHandler
    @Environment(\.reviewsUIProvider) private var reviewsUIProvider
    @Environment(\.presentToast) var presentToast

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
        self._editMode = .init(initialValue: displayMode == .create ? .active : .inactive)
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

                actionButtonsSection

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
        .navigationTitle(displayMode.isPreview ? TimetableStrings.editDetailTitle : "")
        .toolbar {
            toolbarContent
        }
        .alert(TimetableStrings.editCancelConfirmationTitle, isPresented: $showCancelConfirmation) {
            Button(SharedUIComponentsStrings.alertCancel, role: .cancel) {}
            Button(TimetableStrings.editConfirm) {
                cancelEditing()
            }
        } message: {
            Text(TimetableStrings.editCancelConfirmationMessage)
        }
        .alert(TimetableStrings.editResetTitle, isPresented: $showResetConfirmation) {
            Button(SharedUIComponentsStrings.alertCancel, role: .cancel) {}
            Button(TimetableStrings.editReset, role: .destructive) {
                errorAlertHandler.withAlert {
                    try await viewModel.resetLecture()
                    editMode = .inactive
                    application.dismissKeyboard()
                }
            }
        } message: {
            Text(TimetableStrings.editResetConfirmationMessage)
        }
        .alert(TimetableStrings.editDeleteConfirmationTitle, isPresented: $showDeleteConfirmation) {
            Button(SharedUIComponentsStrings.alertCancel, role: .cancel) {}
            Button(SharedUIComponentsStrings.alertDelete, role: .destructive) {
                errorAlertHandler.withAlert {
                    try await viewModel.deleteLecture()
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showSyllabusWebView) {
            if let syllabusURL {
                SyllabusWebView(lectureTitle: viewModel.entryLecture.courseTitle, url: syllabusURL)
                    .ignoresSafeArea(edges: .bottom)
                    .interactiveDismissDisabled()
                    .analyticsScreen(.lectureSyllabus(.init(lectureID: viewModel.entryLecture.referenceID)))
            }
        }
        .sheet(isPresented: $showReviewsScene) {
            if let evLectureID = viewModel.entryLecture.evLecture?.evLectureID {
                reviewsUIProvider.makeReviewsScene(for: evLectureID)
                    .analyticsScreen(
                        .reviewDetail(.init(lectureID: viewModel.entryLecture.referenceID, referrer: .lectureDetail))
                    )
            }
        }
    }

    private var firstDetailSection: some View {
        VStack(spacing: 20) {
            EditableRow(label: TimetableStrings.editFieldCourseTitle, keyPath: \.courseTitle)
            EditableRow(label: TimetableStrings.editFieldInstructor, keyPath: \.instructor)
            if viewModel.entryLecture.isCustom {
                EditableRow(label: TimetableStrings.editFieldCredit, keyPath: \.credit)
            }
            HStack {
                DetailLabel(text: TimetableStrings.editFieldColor)
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
                EditableRow(label: TimetableStrings.editFieldDepartment, keyPath: \.department)
                EditableRow(label: TimetableStrings.editFieldAcademicYear, keyPath: \.academicYear)
                EditableRow(label: TimetableStrings.editFieldCredit, keyPath: \.credit)
                EditableRow(label: TimetableStrings.editFieldClassification, keyPath: \.classification)
                EditableRow(label: TimetableStrings.editFieldCategory, keyPath: \.category)

                // 2025년부터 구)교양영역 제공
                if let currentYear = timetableViewModel.currentTimetable?.quarter.year, currentYear >= 2025 {
                    EditableRow(label: TimetableStrings.editFieldCategoryPre2025, keyPath: \.categoryPre2025)
                }

                EditableRow(label: TimetableStrings.editFieldCourseNumber, readOnly: true, keyPath: \.courseNumber)
                EditableRow(label: TimetableStrings.editFieldLectureNumber, readOnly: true, keyPath: \.lectureNumber)
                EditableRow(label: TimetableStrings.editFieldQuota, readOnly: true, keyPath: \.quotaDescription)
            }
            EditableRow(label: TimetableStrings.editFieldRemark, multiline: true, keyPath: \.remark)
        }
    }

    private var timePlaceSection: some View {
        VStack(spacing: 20) {
            Text(TimetableStrings.editTimePlaceTitle)
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
                    Text(TimetableStrings.editTimePlaceAddTime)
                        .font(.system(size: 16))
                }
                .padding(.top, 5)
            } else if true {
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

    private var actionButtonsSection: some View {
        VStack {
            Group {
                if !viewModel.entryLecture.isCustom, !editMode.isEditing {
                    Button {
                        Task {
                            syllabusURL = await viewModel.fetchSyllabusURL()
                            if syllabusURL != nil {
                                showSyllabusWebView = true
                            }
                        }
                    } label: {
                        Text(TimetableStrings.lectureActionSyllabus)
                    }

                    Button {
                        showReviewsScene = true
                    } label: {
                        Text(TimetableStrings.lectureActionReview)
                    }
                }

                if !viewModel.entryLecture.isCustom, displayMode == .normal, editMode.isEditing {
                    Button {
                        showResetConfirmation = true
                    } label: {
                        Text(TimetableStrings.editReset)
                            .foregroundStyle(.red)
                    }
                }

                if displayMode == .normal, !editMode.isEditing {
                    Button {
                        showDeleteConfirmation = true
                    } label: {
                        Text(SharedUIComponentsStrings.alertDelete)
                            .foregroundStyle(.red)
                    }
                }
            }
            .font(.system(size: 16))
            .padding(.vertical, 15)
            .frame(maxWidth: .infinity)
            .background(TimetableAsset.groupForeground.swiftUIColor)
            .contentShape(.rect)
        }
    }
}

extension LectureEditDetailScene {
    enum DisplayMode: Equatable {
        /// 내가 추가한 강의 상세
        case normal
        /// 새로운 강의 추가
        case create
        /// 내가 추가하지 않은 강의 상세
        case preview(LectureDetailPreviewOptions)

        var isPreview: Bool {
            if case .preview = self {
                return true
            }
            return false
        }

        var previewOptions: LectureDetailPreviewOptions? {
            if case let .preview(options) = self {
                return options
            }
            return nil
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
