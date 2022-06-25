//
//  MyTimetableScene.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/04/07.
//

import SwiftUI

struct MyTimetableScene: View {
    @State private var pushToListScene = false
    @ObservedObject var viewModel: TimetableViewModel

    var body: some View {
        TimetableZStack()
            // navigate programmatically, because NavigationLink inside toolbar doesn't work
            .background(
                NavigationLink(destination: MyLectureListScene(), isActive: $pushToListScene) {
                    EmptyView()
                }
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        NavBarButton(imageName: "nav.menu") {
                            print("menu tapped.")
                        }

                        Text("나의 시간표").font(STFont.title)
                        Text("(18 학점)")
                            .font(STFont.details)
                            .foregroundColor(Color(UIColor.secondaryLabel))

                        Spacer()

                        NavBarButton(imageName: "nav.list") {
                            pushToListScene = true
                        }

                        NavBarButton(imageName: "nav.share") {
                            print("share tapped")
                        }

                        NavBarButton(imageName: "nav.alarm.off") {
                            print("alarm tapped")
                        }
                    }
                }
            }

        let _ = debugChanges()
    }
}

// struct MyTimetableScene_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            MyTimetableScene(currentTimetable: TimetableViewModel(appState: AppState().currentTimetable))
//        }
//    }
// }
//
