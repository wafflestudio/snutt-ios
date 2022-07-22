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
        TimetableZStack(viewModel: .init(container: viewModel.container))
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

                        Text(viewModel.timetableTitle)
                            .font(STFont.title)
                            .minimumScaleFactor(0.9)
                            .lineLimit(1)
                        Text("(\(viewModel.totalCredit) 학점)")
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
            .onLoad {
                await viewModel.fetchRecentTimetable()
            }
            .onLoad {
                await viewModel.fetchTimetableList()
            }
            .alert(isPresented: $viewModel.showAlert) {
                Alert(title: Text("API 에러"), message: Text("API 에러가 발생했습니다. 이 알러트는 테스트용입니다. 나중에 바꿔주세요."), dismissButton: .default(Text("취소")))
            }

        let _ = debugChanges()
    }
}

struct ViewDidLoadModifier: ViewModifier {
    @State private var didLoad = false
    private let action: (() async -> Void)?

    init(perform action: (() async -> Void)? = nil) {
        self.action = action
    }

    func body(content: Content) -> some View {
        content.task {
            if didLoad == false {
                didLoad = true
                await action?()
            }
        }
    }
}

extension View {
    /// Adds an (asynchronous) action to perform when this view is loaded.
    func onLoad(perform action: (() async -> Void)? = nil) -> some View {
        modifier(ViewDidLoadModifier(perform: action))
    }
}

struct MyTimetableScene_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TimetableScene(viewModel: .init(container: .preview))
        }
    }
}
