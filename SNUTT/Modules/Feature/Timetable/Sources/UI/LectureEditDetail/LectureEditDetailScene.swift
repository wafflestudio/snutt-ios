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
import SwiftUIIntrospect
import TimetableInterface

struct LectureEditDetailScene: View {
    @Dependency(\.application) private var application
    @State private var viewModel: LectureEditDetailViewModel
    @State private var editMode: EditMode = .inactive
    
    @State private var isMapViewExpanded: Bool = true

    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss

    let displayMode: DisplayMode

    private var buildings: [Building] { viewModel.lectureBuildings }
    
    private var buildingDictList: [Location: String] {
        var dict: [Location: String] = [:]
        buildings.forEach { dict[$0.locationInDMS] = $0.number + "동" }
        return dict
    }

    private var isGwanak: Bool {
        buildings.allSatisfy { $0.campus == .GWANAK }
    }

    private var showMapMismatchWarning: Bool {
        !viewModel.entryLecture.timePlaces.map { $0.place }.allSatisfy { place in
            buildings.first(where: { place.hasPrefix($0.number) }) != nil
        }
    }
    
    init(entryLecture: any Lecture, displayMode: DisplayMode) {
        _viewModel = .init(initialValue: .init(entryLecture: entryLecture))
        self.displayMode = displayMode
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
        .introspect(.scrollView, on: .iOS(.v17, .v18), customize: { scrollView in
            scrollView.makeTouchResponsive()
        })
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
                if editMode.isEditing {
                    // save
                    editMode = .inactive
                } else {
                    editMode = .active
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

    @State private var title: String = ""

    private var firstDetailSection: some View {
        VStack(spacing: 20) {
            EditableRow(label: "강의명", keyPath: \.courseTitle)
            EditableRow(label: "교수", keyPath: \.instructor)
            if viewModel.entryLecture.isCustom {
                EditableRow(label: "학점", keyPath: \.credit)
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
                
            } else {
                // TODO: needs `supportForMapViewEnabled` flag
                if !buildingDictList.isEmpty && isGwanak {
                    if isMapViewExpanded {
                        Group {
                            LectureMapView(buildings: buildingDictList)
                                .frame(maxWidth: .infinity)
                                .frame(height: 256)
                                .padding(.top, 4)

                            if showMapMismatchWarning {
                                HStack {
                                    Text("* 장소를 편집한 경우, 실제 위치와 다르게 표시될 수 있습니다.")
                                        .font(SNUTTFont.regular13.font)
                                        .foregroundStyle(colorScheme == .dark
                                                          ? SharedUIComponentsAsset.gray30.swiftUIColor.opacity(0.6)
                                                          : SharedUIComponentsAsset.darkGray.swiftUIColor.opacity(0.6))
                                        .padding(.top, 8)
                                    Spacer()
                                }
                            }
                        }
                        .animation(.linear(duration: 0.2), value: isMapViewExpanded)
                        .transition(.asymmetric(insertion: .opacity, removal: .identity))

                        Button {
                            withAnimation {
                                isMapViewExpanded.toggle()
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text("지도 닫기")
                                    .font(SNUTTFont.regular14.font)
                                    .foregroundStyle(colorScheme == .dark
                                                      ? SharedUIComponentsAsset.gray30.swiftUIColor
                                                      : SharedUIComponentsAsset.darkGray.swiftUIColor)
                                TimetableAsset.chevronDown.swiftUIImage
                                    .rotationEffect(.init(degrees: 180.0))
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
                                TimetableAsset.mapOpen.swiftUIImage
                                Spacer().frame(width: 8)
                                Text("지도에서 보기")
                                    .font(SNUTTFont.regular14.font)
                                    .foregroundStyle(colorScheme == .dark
                                                      ? SharedUIComponentsAsset.gray30.swiftUIColor
                                                      : SharedUIComponentsAsset.darkGray.swiftUIColor)
                                Spacer().frame(width: 4)
                                TimetableAsset.chevronDown.swiftUIImage
                            }
                        }
                        .padding(.top, 8)
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
}

#Preview {
    NavigationStack {
        LectureEditDetailScene(entryLecture: PreviewHelpers.preview(id: "1").lectures.first!, displayMode: .normal)
    }
    .tint(.label)
}
