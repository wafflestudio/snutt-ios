//
//  VacancyLectureList.swift
//  SNUTT
//
//  Created by 박신홍 on 2023/07/22.
//

import SwiftUI

struct VacancyLectureList: View {
    @ObservedObject var viewModel: VacancyScene.ViewModel
    @Binding var editMode: EditMode
    var isGuidePopupPresented: Bool
    @State private var selection = Set<String>()
    @State private var isDeleteConfirmAlertPresented = false

    var body: some View {
        ZStack {
            List(selection: $selection) {
                ForEach(viewModel.lectures, id: \.id) { lecture in
                    VacancyLectureCell(lecture: lecture)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(lecture.hasVacancy ? STColor.vacancyRedBackground : .clear)
                }
            }
            .tint(STColor.cyan)
            .toolbar {
                editButton
            }
            .listStyle(.plain)
            .refreshable {
                await viewModel.fetchLectures()
            }
            .environment(\.editMode, self.$editMode)
            .safeAreaInset(edge: .bottom) {
                if editMode.isEditing {
                    deleteButton
                        .transition(.opacity.combined(with: .move(edge: .bottom)).animation(.customSpring))
                }
            }
            .animation(.customSpring, value: viewModel.lectures.count)
            .animation(.customSpring, value: editMode)
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
        .background(selection.isEmpty ? STColor.gray : STColor.cyan)
        .disabled(selection.isEmpty)
        .foregroundColor(Color(uiColor: .systemBackground))
        .alert(Text("목록에서 삭제"), isPresented: $isDeleteConfirmAlertPresented) {
            Button("취소", role: .cancel, action: {})
            Button("삭제", role: .destructive) {
                let lectures = viewModel.lectures
                let selection = selection
                viewModel.lectures.removeAll(where: { selection.contains($0.id) })
                editMode = .inactive
                Task {
                    let lecturesToDelete = lectures.filter { lecture in
                        selection.contains(lecture.id)
                    }
                    await viewModel.deleteLectures(lectures: lecturesToDelete)
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
            self.selection = Set<String>()
        }) {
            Text(self.editMode.title)
        }
        .disabled(viewModel.lectures.isEmpty || isGuidePopupPresented)
    }
}

extension EditMode {
    var title: String {
        self == .active ? "취소" : "편집"
    }

    mutating func toggle() {
        self = self == .active ? .inactive : .active
    }
}

#if DEBUG
    struct VacancyLectureList_Previews: PreviewProvider {
        static var previews: some View {
            NavigationView {
                VacancyLectureList(viewModel: .init(container: .preview), editMode: .constant(.inactive), isGuidePopupPresented: false)
            }
        }
    }
#endif
