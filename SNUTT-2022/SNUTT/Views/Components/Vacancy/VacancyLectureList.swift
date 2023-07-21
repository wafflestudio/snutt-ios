//
//  VacancyLectureList.swift
//  SNUTT
//
//  Created by 박신홍 on 2023/07/22.
//

import SwiftUI

struct VacancyLectureList: View {
    let viewModel: ViewModel
    let lectures: [Lecture]

    var body: some View {
        List {
            ForEach(lectures) { lecture in
                VacancyLectureCell(lecture: lecture)
                    .listRowInsets(EdgeInsets())
            }
        }
        .listStyle(.plain)
        .animation(.customSpring, value: lectures.count)
        .refreshable {

        }
        .navigationTitle("빈자리 알림")
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension VacancyLectureList {
    class ViewModel: BaseViewModel {}
}

#if DEBUG
struct VacancyLectureList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            VacancyLectureList(viewModel: .init(container: .preview), lectures: [.preview, .preview, .preview])
        }
    }
}
#endif
