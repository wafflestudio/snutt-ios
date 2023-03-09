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
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(lectures) { lecture in
                    NavigationLink {
                        LectureDetailScene(viewModel: .init(container: viewModel.container), lecture: lecture, displayMode: .normal, bookmarks: [])
                    } label: {
                        VStack(spacing: 0) {
                            Divider()
                                .frame(height: 1)
                            LectureListCell(lecture: lecture)
                                .padding(.vertical, 5)
                                .padding(.trailing, 20)
                        }
                        .padding(.leading, 20)
                    }
                    .buttonStyle(RectangleButtonStyle())
                }
                Divider()
                    .frame(height: 1)
                    .padding(.leading, 20)
            }
            .animation(.customSpring, value: lectures.count)
        }

        let _ = debugChanges()
    }
}

extension LectureList {
    class ViewModel: BaseViewModel {}
}

#if DEBUG
    struct TimetableList_Previews: PreviewProvider {
        static var previews: some View {
            NavigationView {
                LectureList(viewModel: .init(container: .preview), lectures: [.preview, .preview, .preview])
            }
        }
    }
#endif
