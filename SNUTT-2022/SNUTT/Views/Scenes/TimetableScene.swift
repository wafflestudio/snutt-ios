//
//  TimetableScene.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/04/07.
//

import SwiftUI

struct TimetableScene: View, Sendable {
    @State private var showPopupMenu = false
    @State private var showCreateLectureSheet = false
    @ObservedObject var viewModel: TimetableViewModel

    private let statusBarHeight = UIApplication.shared
        .connectedScenes
        .compactMap { ($0 as? UIWindowScene)?.statusBarManager?.statusBarFrame.height }
        .first ?? 0
    
    @State private var isNewToScrollLectureList: Bool = true
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                if !viewModel.routingState.pushToBookmark {
                    navigationBar
                }
                
                GeometryReader { reader in
                    ScrollView(.vertical) {
                        VStack(spacing: 0) {
                            bannerAndTimetable
                                .frame(height: reader.size.height)
                            LectureList(
                                viewModel: .init(container: viewModel.container),
                                lectures: viewModel.lectures
                            )
                        }
                    }
                    .simultaneousGesture(
                        DragGesture().onChanged {
                            if $0.translation.height < 0 {
                                isNewToScrollLectureList = false
                            }
                        }
                    )
                }
            }
            
            if !viewModel.routingState.pushToBookmark && isNewToScrollLectureList {
                ToolTip(label: "스크롤하면 상시강의를 확인할 수 있어요.")
                    .padding(.bottom, 12)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: viewModel.routingState.pushToBookmark)
        .animation(.easeInOut(duration: 0.2), value: isNewToScrollLectureList)
        .animation(.customSpring, value: viewModel.isVacancyBannerVisible)
        .analyticsScreen(.timetableHome)
        .sheet(isPresented: $showCreateLectureSheet, content: {
            ZStack {
                NavigationView {
                    LectureDetailScene(
                        viewModel: .init(container: viewModel.container),
                        lecture: viewModel.placeholderLecture,
                        displayMode: .create
                    )
                    .analyticsScreen(.lectureCreate)
                }
                // this view is duplicated on purpose (i.e. there are 2 instances of LectureTimeSheetScene)
                LectureTimeSheetScene(viewModel: .init(container: viewModel.container))
            }
            .accentColor(Color(UIColor.label))
        })
        let _ = debugChanges()
    }
    
    private var navigationBar: some View {
        VStack(spacing: 0) {
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
                        viewModel.goToBookmarkPage()
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
                .foregroundStyle(
                    colorScheme == .dark ? STColor.darkDivider : STColor.divider
                )
        }
    }
    
    private var bannerAndTimetable: some View {
        VStack(spacing: 0) {
            if viewModel.isVacancyBannerVisible && !viewModel.routingState.pushToBookmark {
                VacancyBanner {
                    viewModel.goToVacancyPage()
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .opacity
                ))
            }
            timetable
        }
        
    }

    private var timetable: some View {
        TimetableZStack(current: viewModel.currentTimetable, config: viewModel.configuration)
            .animation(.customSpring, value: viewModel.currentTimetable?.id)
            // navigate programmatically, because NavigationLink inside toolbar doesn't work
            .background(
                NavigationLink(
                    destination: VacancyScene(viewModel: .init(container: viewModel.container)),
                    isActive: $viewModel.routingState.pushToVacancy
                ) { EmptyView() }
            )
            .navigationBarTitleDisplayMode(.inline)
    }
}
