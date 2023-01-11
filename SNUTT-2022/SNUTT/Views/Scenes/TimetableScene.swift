//
//  MyTimetableScene.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/04/07.
//

import LinkPresentation
import SwiftUI

struct TimetableScene: View {
    @State private var pushToListScene = false
    @State private var pushToNotiScene = false
    @State private var isShareSheetOpened = false
    @State private var screenshot: UIImage = .init()
    @ObservedObject var viewModel: TimetableViewModel

    /// Provide title for `UIActivityViewController`.
    private let linkMetadata = LinkMetadata()

    var body: some View {
        GeometryReader { reader in
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
                                self.screenshot = body.takeScreenshot(size: reader.size)
                                isShareSheetOpened = true
                            }

                            NavBarButton(imageName: "nav.alarm.off") {
                                pushToNotiScene = true
                            }
                            .circleBadge(condition: viewModel.unreadCount > 0)
                        }
                    }
                }
                .sheet(isPresented: $isShareSheetOpened) { [screenshot] in
                    ActivityViewController(activityItems: [screenshot, linkMetadata])
                }
                .onLoad {
                    viewModel.preloadWebViews()

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
        }
        let _ = debugChanges()
    }
}

// MARK: ActivityViewController

private struct ActivityViewController: UIViewControllerRepresentable {
    var activityItems: [Any]

    func makeUIViewController(context _: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_: UIActivityViewController, context _: UIViewControllerRepresentableContext<ActivityViewController>) {}
}

private final class LinkMetadata: NSObject, UIActivityItemSource {
    var linkMetadata: LPLinkMetadata

    override init() {
        linkMetadata = LPLinkMetadata()
        linkMetadata.title = "SNUTT"
        super.init()
    }

    func activityViewControllerPlaceholderItem(_: UIActivityViewController) -> Any {
        return ""
    }

    func activityViewController(_: UIActivityViewController, itemForActivityType _: UIActivity.ActivityType?) -> Any? {
        return nil
    }

    func activityViewControllerLinkMetadata(_: UIActivityViewController) -> LPLinkMetadata? {
        return linkMetadata
    }
}

// struct MyTimetableScene_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            TimetableScene(viewModel: .init(container: .preview))
//        }
//    }
// }
