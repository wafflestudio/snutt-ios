//
//  TimetableScene.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/04/07.
//

import LinkPresentation
import SwiftUI

struct TimetableScene: View, Sendable {
    @State private var pushToNotiScene = false
    @State private var pushToListScene = false
    @State private var isShareSheetOpened = false
    @State private var screenshot: UIImage = .init()
    @ObservedObject var viewModel: TimetableViewModel

    /// Provide title for `UIActivityViewController`.
    private let linkMetadata = LinkMetadata()

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isVacancyBannerVisible {
                VacancyBanner {
                    viewModel.goToVacancyPage()
                }
                .transition(.move(edge: .trailing))
            }
            timetable
        }
        .animation(.customSpring, value: viewModel.isVacancyBannerVisible)
        let _ = debugChanges()
    }

    var timetable: some View {
        GeometryReader { reader in
            TimetableZStack(current: viewModel.currentTimetable, config: viewModel.configuration)
                .animation(.customSpring, value: viewModel.currentTimetable?.id)
                // navigate programmatically, because NavigationLink inside toolbar doesn't work
                .background(
                    Group {
                        NavigationLink(destination: LectureListScene(viewModel: .init(container: viewModel.container)), isActive: $pushToListScene) { EmptyView() }
                    }
                )
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItemGroup(placement: .topBarLeading) {
                        HStack {
                            NavBarButton(imageName: "nav.menu") {
                                viewModel.setIsMenuOpen(true)
                            }
                            .circleBadge(condition: viewModel.isNewCourseBookAvailable)

                            Text(viewModel.timetableTitle)
                                .font(STFont.title.font)
                                .minimumScaleFactor(0.9)
                                .lineLimit(1)

                            Text("(\(viewModel.totalCredit)학점)")
                                .font(STFont.details.font)
                                .foregroundColor(Color(UIColor.secondaryLabel))
                        }
                    }
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        HStack {
                            NavBarButton(imageName: "nav.list") {
                                pushToListScene = true
                            }

                            NavBarButton(imageName: "nav.share") {
                                screenshot = self.timetable.takeScreenshot(size: reader.size, preferredColorScheme: colorScheme)
                                isShareSheetOpened = true
                            }

                            NavBarButton(imageName: "nav.alarm.off") {
                                viewModel.routingState.pushToNotification = true
                            }
                            .circleBadge(condition: viewModel.unreadCount > 0)
                        }
                    }
                }
                .sheet(isPresented: $isShareSheetOpened) { [screenshot] in
                    ActivityViewController(activityItems: [screenshot, linkMetadata])
                }
        }
        .background {
            NavigationLink(destination: NotificationList(viewModel: .init(container: viewModel.container)),
                           isActive: $viewModel.routingState.pushToNotification) { EmptyView() }
        }
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
