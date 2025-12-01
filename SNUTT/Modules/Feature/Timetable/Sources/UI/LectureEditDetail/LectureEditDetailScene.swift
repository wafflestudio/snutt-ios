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
    @Environment(\.themeViewModel) private var themeViewModel
    @Environment(\.errorAlertHandler) var errorAlertHandler
    @Environment(\.lectureTimeConflictHandler) var conflictHandler
    @Environment(\.reviewsUIProvider) private var reviewsUIProvider
    @Environment(\.presentToast) var presentToast
    @Dependency(\.notificationCenter) var notificationCenter

    let paths: Binding<[TimetableDetailSceneTypes]>
    let belongsToOtherTimetable: Bool

    init(
        viewModel: LectureEditDetailViewModel,
        paths: Binding<[TimetableDetailSceneTypes]> = .constant([]),
        belongsToOtherTimetable: Bool = false
    ) {
        _viewModel = .init(initialValue: viewModel)
        self.paths = paths
        self.belongsToOtherTimetable = belongsToOtherTimetable
        self._editMode = .init(initialValue: viewModel.displayMode.isCreate ? .active : .inactive)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Group {
                    firstDetailSection

                    if let reminderViewModel = viewModel.reminderViewModel {
                        lectureReminderSection(viewModel: reminderViewModel)
                    }

                    secondDetailSection
                    timePlaceSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical)
                .background(TimetableAsset.groupForeground.swiftUIColor)

                actionButtonsSection
            }
            .animation(.defaultSpring, value: viewModel.reminderViewModel == nil)
            .padding(.vertical, 20)
            .padding(.bottom, 40)
        }
        .withResponsiveTouch()
        .task {
            await errorAlertHandler.withAlert {
                try await viewModel.initialLoad()
            }
            await viewModel.fetchBuildingList()
        }
        .background(TimetableAsset.groupBackground.swiftUIColor)
        .environment(\.editMode, $editMode)
        .environment(viewModel)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(editMode.isEditing)
        .navigationTitle(viewModel.displayMode.isPreview ? TimetableStrings.editDetailTitle : "")
        .toolbar {
            toolbarContent
        }
        .overlay(alignment: .bottom) {
            floatingButtonIfNeeded
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
            if viewModel.displayMode.timetable != nil {
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
    }

    private func lectureReminderSection(viewModel: LectureReminderViewModel) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(TimetableStrings.reminderTitle)
                .font(.custom(.regular15))
                .foregroundColor(.primary)
            LectureReminderPicker(
                selection: Binding(
                    get: { viewModel.option },
                    set: { newValue in
                        errorAlertHandler.withAlert {
                            try await viewModel.updateOption(newValue)
                            // Show toast with "View" button to navigate to settings
                            if let message = newValue.toastMessage {
                                presentToast(
                                    .init(
                                        message: message,
                                        button: .init(title: TimetableStrings.toastActionView) {
                                            @Sendable @MainActor in
                                            @Dependency(\.notificationCenter) var notificationCenter
                                            notificationCenter.post(NavigateToLectureRemindersMessage())
                                        }
                                    )
                                )
                            }
                        }
                    }
                )
            )
            .padding(.horizontal, -4)
            Text(TimetableStrings.reminderDescription)
                .lineHeight(with: .regular13, percentage: 140)
                .foregroundColor(SharedUIComponentsAsset.gray30.swiftUIColor)
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
                if viewModel.displayMode.quarter.year >= 2025 {
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

                if !viewModel.entryLecture.isCustom, viewModel.displayMode.isNormal, editMode.isEditing {
                    Button {
                        showResetConfirmation = true
                    } label: {
                        Text(TimetableStrings.editReset)
                            .foregroundStyle(.red)
                    }
                }

                if viewModel.displayMode.isNormal, !editMode.isEditing {
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
    private func resolvedColor(for lecture: Lecture) -> LectureColor {
        TimetablePainter(
            currentTimetable: viewModel.displayMode.timetable,
            selectedLecture: nil,
            preferredTheme: nil,
            availableThemes: themeViewModel.availableThemes,
            configuration: .init()
        )
        .resolveColor(for: lecture)
    }

    @ViewBuilder
    private var floatingButtonIfNeeded: some View {
        if belongsToOtherTimetable,
            viewModel.displayMode.isNormal,
            editMode == .inactive,
            let timetableID = viewModel.displayMode.timetable?.id
        {
            FloatingButton(text: TimetableStrings.editGoToTimetable) {
                notificationCenter.post(NavigateToTimetableMessage(timetableID: timetableID))
            }
            .padding(.bottom, 20)
        }
    }
}

#Preview {
    let timetable = PreviewHelpers.preview(id: "1")
    let lecture = timetable.lectures.first!
    let viewModel = LectureEditDetailViewModel(
        displayMode: .normal(timetable: timetable),
        entryLecture: lecture
    )

    return NavigationStack {
        LectureEditDetailScene(
            viewModel: viewModel,
            belongsToOtherTimetable: false
        )
    }
    .tint(.label)
}
