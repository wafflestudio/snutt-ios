//
//  MyTimetableScene.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/04/07.
//

import SwiftUI

struct TimetableScene: View {
    @State private var pushToListScene = false
    @StateObject var viewModel: TimetableViewModel

    var body: some View {
        TimetableZStack()
            .environmentObject(viewModel.timetableSetting)
            // navigate programmatically, because NavigationLink inside toolbar doesn't work
            .background(
                NavigationLink(destination: LectureListScene(viewModel: .init(container: viewModel.container)), isActive: $pushToListScene) {
                    EmptyView()
                }
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        NavBarButton(imageName: "nav.menu") {
                            viewModel.toggleMenuSheet()
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
            .task {
                await viewModel.fetchRecentTimetable()
            }
            .alert(isPresented: $viewModel.showAlert) {
                Alert(title: Text("API 에러"), message: Text("API 에러가 발생했습니다. 이 알러트는 테스트용입니다. 나중에 바꿔주세요."), dismissButton: .default(Text("취소")))
            }

        let _ = debugChanges()
    }
}

struct MyTimetableScene_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TimetableScene(viewModel: .init(container: .preview))
        }
    }
}
