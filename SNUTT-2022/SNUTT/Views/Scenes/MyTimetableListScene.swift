//
//  MyTimetableListScene.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/03/30.
//

import SwiftUI

struct MyTimetableListScene: View {
    let myDummyLectureList = DummyAppState.shared.lectures

    var body: some View {
        TimetableList(lectures: myDummyLectureList)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavBarButton(imageName: "nav.plus") {
                        print("menu tapped.")
                    }
                }
            }
    }
}

struct MyTimetableListScene_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TabView {
                MyTimetableListScene()
            }
        }
    }
}
