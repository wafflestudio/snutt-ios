//
//  VacancyLectureListView.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI

struct VacancyLectureListView: View {
    let viewModel: VacancyViewModel

    @Binding var editMode: EditMode
    @State private var selectedLectureIDs = Set<String>()
    @State private var isDeleteConfirmAlertPresented = false
    @Environment(\.errorAlertHandler) private var errorAlertHandler

    var body: some View {
        ZStack {
            List(selection: $selectedLectureIDs) {
                ForEach(viewModel.vacancyLectures, id: \.id) { lecture in
                    VacancyLectureListCell(lecture: lecture)
                }
            }
            .tint(SharedUIComponentsAsset.cyan.swiftUIColor)
            .toolbar {
                editButton
            }
            .listStyle(.plain)
            .refreshable {
                errorAlertHandler.withAlert {
                    try await viewModel.fetchVacancyLectures()
                }
            }
            .environment(\.editMode, self.$editMode)
            .safeAreaInset(edge: .bottom) {
                if editMode.isEditing {
                    deleteButton
                        .transition(.opacity.combined(with: .move(edge: .bottom)).animation(.defaultSpring))
                }
            }
            .animation(.defaultSpring, value: viewModel.vacancyLectures.count)
        }
    }

    private var deleteButton: some View {
        Button {
            isDeleteConfirmAlertPresented = true
        } label: {
            Text("선택한 강의 삭제")
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .contentShape(Rectangle())
                .foregroundColor(.white)
        }
        .background(selectedLectureIDs.isEmpty ? SharedUIComponentsAsset.assistive
            .swiftUIColor : SharedUIComponentsAsset.cyan.swiftUIColor)
        .disabled(selectedLectureIDs.isEmpty)
        .foregroundColor(Color(uiColor: .systemBackground))
        .alert(Text("목록에서 삭제"), isPresented: $isDeleteConfirmAlertPresented) {
            Button("취소", role: .cancel, action: {})
            Button("삭제", role: .destructive) {
                errorAlertHandler.withAlert {
                    editMode = .inactive
                    try await viewModel.deleteVacancyLectures(lectureIDs: selectedLectureIDs)
                }
            }
        } message: {
            Text("선택한 강의의 빈자리 알림을 해제하시겠습니까?")
        }
    }

    private var editButton: some View {
        Button(action: {
            withAnimation {
                self.editMode.toggle()
            }
            self.selectedLectureIDs = Set<String>()
        }) {
            Text(self.editMode.title)
        }
        .disabled(viewModel.vacancyLectures.isEmpty)
    }
}

extension EditMode {
    fileprivate var title: String {
        self == .active ? "취소" : "편집"
    }

    fileprivate mutating func toggle() {
        switch self {
        case .inactive:
            self = .active
        case .active:
            self = .inactive
        default:
            break
        }
    }
}

#Preview {
    @Previewable @State var editMode = EditMode.inactive
    @Previewable @State var viewModel = VacancyViewModel()
    let _ = Task {
        try await viewModel.fetchVacancyLectures()
    }
    VacancyLectureListView(viewModel: viewModel, editMode: $editMode)
}
