//
//  MyLectureListScene.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/03/30.
//

import SwiftUI

struct LectureListScene: View {
    let viewModel: MyLectureListViewModel

    var body: some View {
        LectureList(viewModel: .init(container: viewModel.container),
                    lectures: viewModel.currentTimetable?.lectures ?? [])
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavBarButton(imageName: "nav.plus") {
                        print("menu tapped.")
                    }
                }
            }

        let _ = debugChanges()
    }
}

struct MyTimetableListScene_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TabView {
                LectureListScene(viewModel: .init(container: .preview))
            }
        }
    }
}
