//
//  VacancyLectureList.swift
//  SNUTT
//
//  Created by 박신홍 on 2023/07/22.
//

import SwiftUI

struct VacancyLectureList: View {
    @ObservedObject var viewModel: VacancyScene.ViewModel
    @State var editMode = EditMode.inactive
    @State var selection = Set<String>()

    var body: some View {
        List(selection: $selection) {
            ForEach(viewModel.lectures, id: \.id) { lecture in
                VacancyLectureCell(lecture: lecture)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(lecture.hasVacancy ? STColor.vacancyRedBackground : .clear)
            }
            .onDelete { indexSet in
                let lectures = viewModel.lectures
                viewModel.lectures.remove(atOffsets: indexSet)
                Task {
                    let lecturesToDelete = indexSet.map { lectures[$0] }
                    await viewModel.deleteLectures(lectures: lecturesToDelete)
                }
            }
        }
//        .toolbar {
//            editButton
//        }
        .listStyle(.plain)
        .refreshable {
            await viewModel.fetchLectures()
        }
        .navigationTitle("빈자리 알림")
        .navigationBarTitleDisplayMode(.inline)
        .environment(\.editMode, self.$editMode)
        .animation(.customSpring, value: viewModel.lectures.count)
        .animation(.customSpring, value: editMode)
    }

    private var editButton: some View {
        Button(action: {
            self.editMode.toggle()
            self.selection = Set<String>()
        }) {
            Text(self.editMode.title)
        }
    }
}

extension EditMode {
    var title: String {
        self == .active ? "완료" : "편집"
    }

    mutating func toggle() {
        self = self == .active ? .inactive : .active
    }
}

#if DEBUG
struct VacancyLectureList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            VacancyLectureList(viewModel: .init(container: .preview))
        }
    }
}
#endif
