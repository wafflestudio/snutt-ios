//
//  LectureListScene.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/03/30.
//

import SwiftUI

struct LectureListScene: View {
    @ObservedObject var viewModel: LectureListViewModel

    @State private var showingCreatePage = false

    var body: some View {
        ZStack {
            if viewModel.lectures.isEmpty {
                EmptyLectureList()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                LectureList(viewModel: .init(container: viewModel.container),
                            lectures: viewModel.lectures)
            }
        }
        .analyticsScreen(.lectureList)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavBarButton(imageName: "nav.plus") {
                    showingCreatePage = true
                }
            }
        }
        .background(STColor.systemBackground)
        .sheet(isPresented: $showingCreatePage, content: {
            ZStack {
                NavigationView {
                    LectureDetailScene(
                        viewModel: .init(container: viewModel.container),
                        lecture: viewModel.placeholderLecture,
                        displayMode: .create
                    )
                    .analyticsScreen(.lectureCreate)
                }
                // this view is duplicated on purpose (i.e. there are 2 instances of LectureTimeSheetScene)
                LectureTimeSheetScene(viewModel: .init(container: viewModel.container))
            }
            .accentColor(Color(UIColor.label))
        })

        let _ = debugChanges()
    }
}

#if DEBUG
    struct MyTimetableListScene_Previews: PreviewProvider {
        static var previews: some View {
            NavigationView {
                TabView {
                    LectureListScene(viewModel: .init(container: .preview))
                }
            }
        }
    }
#endif
