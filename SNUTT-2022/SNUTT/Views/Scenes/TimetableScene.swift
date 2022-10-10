//
//  MyTimetableScene.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/04/07.
//

import SwiftUI

struct TimetableScene: View {
    @State private var pushToListScene = false
    @State private var pushToNotiScene = false
    @ObservedObject var viewModel: TimetableViewModel

    var body: some View {
        TimetableZStack(current: viewModel.currentTimetable, config: viewModel.configuration)
            .animation(.customSpring, value: viewModel.currentTimetable?.id)
            // navigate programmatically, because NavigationLink inside toolbar doesn't work
            .background(
                Group {
                    NavigationLink(destination: LectureListScene(viewModel: .init(container: viewModel.container)), isActive: $pushToListScene) { EmptyView() }
                    NavigationLink(destination: NotificationList(notifications: viewModel.notifications,
                                                                 initialFetch: viewModel.fetchInitialNotifications,
                                                                 fetchMore: viewModel.fetchMoreNotifications), isActive: $pushToNotiScene) { EmptyView() }
                }
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        NavBarButton(imageName: "nav.menu") {
                            viewModel.setIsMenuOpen(true)
                        }
                        .circleBadge(condition: viewModel.isNewCourseBookAvailable)

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
                            pushToNotiScene = true
                        }
                        .circleBadge(condition: viewModel.unreadCount > 0)
                    }
                }
            }
            .onLoad {
                // make the following three api calls execute concurrently
                await withTaskGroup(of: Void.self, body: { group in
                    group.addTask {
                        await viewModel.fetchTimetableList()
                    }
                    group.addTask {
                        await viewModel.fetchRecentTimetable()
                    }
                    group.addTask {
                        await viewModel.fetchCourseBookList()
                    }
                    group.addTask {
                        await viewModel.fetchInitialNotifications(updateLastRead: false)
                    }
                    group.addTask {
                        await viewModel.fetchNotificationsCount()
                    }
                })
            }
            .alert(viewModel.errorTitle, isPresented: $viewModel.isErrorAlertPresented) {
                Button("확인") {}
            } message: {
                Text(viewModel.errorMessage)
            }
            
//            .onAppear {
//                Task {
//                    await viewModel.fetchNotificationsCount()
//                }
//            }

        let _ = debugChanges()
    }
}

// struct MyTimetableScene_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            TimetableScene(viewModel: .init(container: .preview))
//        }
//    }
// }
