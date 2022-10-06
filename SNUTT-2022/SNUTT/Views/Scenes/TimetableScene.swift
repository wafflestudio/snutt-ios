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
            .animation(.customSpring, value: viewModel.timetableState.current?.id)
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
//            .onAppear {
//                Task {
//                    await viewModel.fetchNotificationsCount()
//                }
//            }

        let _ = debugChanges()
    }
}

// TODO: Move this to Modifiers folder.
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

// struct MyTimetableScene_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            TimetableScene(viewModel: .init(container: .preview))
//        }
//    }
// }
