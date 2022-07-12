//
//  LectureList.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/03/24.
//

import SwiftUI

struct LectureList: View {
    let viewModel: ViewModel
    let lectures: [Lecture]

    var body: some View {
        List(lectures) { lecture in
            ZStack {
                NavigationLink {
                    LectureDetailScene(viewModel: .init(container: viewModel.container))
                } label: {
                    EmptyView()
                }
                // workaround to hide arrow indicator
                .opacity(0.0)

                LectureListCell(lecture: lecture)
            }
        }.listStyle(PlainListStyle())

        let _ = debugChanges()
    }
}

extension LectureList {
    class ViewModel: BaseViewModel {}
}

struct TimetableList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LectureList(viewModel: .init(container: .preview),lectures: [.preview, .preview, .preview])
        }
    }
}
