//
//  TimetableScene.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/04/07.
//

import SwiftUI

struct TimetableScene: View, Sendable {
    @State private var pushToBookmarkScene = false
    @ObservedObject var viewModel: TimetableViewModel

    private let statusBarHeight = UIApplication.shared
        .connectedScenes
        .compactMap { ($0 as? UIWindowScene)?.statusBarManager?.statusBarFrame.height }
        .first ?? 0
    
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            // toolbar
            HStack(spacing: 12) {
                NavBarButton(imageName: "nav.menu") {
                    viewModel.setIsMenuOpen(true)
                }
                .circleBadge(condition: viewModel.isNewCourseBookAvailable)

                HStack(spacing: 8) {
                    Text(viewModel.timetableTitle)
                        .font(STFont.bold17.font)
                        .minimumScaleFactor(0.9)
                        .lineLimit(1)

                    Text("(\(viewModel.totalCredit)학점)")
                        .font(STFont.regular12.font)
                        .foregroundStyle(STColor.assistive)

                    Spacer()
                }

                HStack(spacing: 6) {
                    NavBarButton(imageName: "nav.bookmark") {
                        pushToBookmarkScene = true
                    }
                    NavBarButton(imageName: "nav.vacancy.off") {
                        viewModel.goToVacancyPage()
                    }
                }
            }
            .frame(height: statusBarHeight)
            .padding(.leading, 16)
            .padding(.trailing, 12)

            Rectangle().frame(height: 0.5)
                .foregroundStyle(STColor.divider)

            if viewModel.isVacancyBannerVisible {
                VacancyBanner {
                    viewModel.goToVacancyPage()
                }
                .transition(.move(edge: .trailing))
            }
            timetable
        }
        .animation(.customSpring, value: viewModel.isVacancyBannerVisible)
        .analyticsScreen(.timetableHome)
        
        let _ = debugChanges()
    }

    var timetable: some View {
        TimetableZStack(current: viewModel.currentTimetable, config: viewModel.configuration)
            .animation(.customSpring, value: viewModel.currentTimetable?.id)
            // navigate programmatically, because NavigationLink inside toolbar doesn't work
            .background(
                Group {
                    NavigationLink(
                        destination: VacancyScene(viewModel: .init(container: viewModel.container)),
                        isActive: $viewModel.routingState.pushToVacancy
                    ) { EmptyView() }
                }
            )
            .navigationBarTitleDisplayMode(.inline)
    }
}
