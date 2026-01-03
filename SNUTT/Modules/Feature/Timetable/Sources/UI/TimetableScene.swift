//
//  TimetableScene.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import AnalyticsInterface
import Dependencies
import NotificationsInterface
import SharedUIComponents
import SwiftUI
import TimetableInterface
import TimetableUIComponents

public struct TimetableScene: View {
    @Dependency(\.application) private var application
    @Bindable var timetableViewModel: TimetableViewModel
    @Environment(\.errorAlertHandler) private var errorAlertHandler
    @Environment(\.themeUIProvider) private var themeUIProvider
    @Environment(\.themeViewModel) private var themeViewModel

    public init(timetableViewModel: TimetableViewModel) {
        self.timetableViewModel = timetableViewModel
    }

    public var body: some View {
        NavigationStack(path: $timetableViewModel.paths) {
            VStack(spacing: 0) {
                if #available(iOS 26, *) {
                    timetable
                        .toolbar(content: toolbarContentForNewDesign)
                        .navigationTitle(timetableViewModel.timetableTitle)
                        .navigationSubtitle(
                            TimetableStrings.timetableToolbarTotalCredit(timetableViewModel.totalCredit)
                                .trimmingCharacters(in: .punctuationCharacters)
                        )
                } else {
                    toolbarContent
                    timetable
                }
            }
            .ignoresSafeArea(.keyboard)
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: TimetableDetailSceneTypes.self) {
                TimetableDetails(pathType: $0, timetableViewModel: timetableViewModel)
            }
            .task {
                await errorAlertHandler.withAlert {
                    try await timetableViewModel.loadTimetable()
                }
            }
            .task {
                await errorAlertHandler.withAlert {
                    try await timetableViewModel.loadTimetableList()
                }
            }
            .task {
                await errorAlertHandler.withAlert {
                    try await timetableViewModel.loadCourseBooks()
                }
            }
            .sheet(isPresented: $timetableViewModel.isThemeSheetPresented) {
                themeUIProvider.menuThemeSelectionSheet()
            }
        }
        .analyticsScreen(.timetableHome)
    }

    private var timetable: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color(UIColor.quaternaryLabel.withAlphaComponent(0.1)))
                .frame(height: 1)
            TimetableZStack(
                painter: timetableViewModel.makePainter(
                    selectedLecture: nil,
                    selectedTheme: themeViewModel.selectedTheme,
                    availableThemes: themeViewModel.availableThemes
                )
            )
        }
        .environment(
            \.lectureTapAction,
            LectureTapAction(action: { lecture in
                guard let currentTimetable = timetableViewModel.currentTimetable else { return }
                timetableViewModel.paths.append(
                    .lectureDetail(lecture, parentTimetable: currentTimetable)
                )
                Dependency(\.analyticsLogger).wrappedValue.logScreen(
                    AnalyticsScreen.lectureDetail(.init(lectureID: lecture.referenceID, referrer: .timetable))
                )
            })
        )
    }
}

struct CircleBadge: View {
    let color: Color

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 4, height: 4)
    }
}

struct CircleBadgeModifier: ViewModifier {
    let condition: Bool
    let color: Color

    func body(content: Content) -> some View {
        ZStack(alignment: .topTrailing) {
            content

            if condition {
                CircleBadge(color: .red)
            }
        }
    }
}

extension View {
    func circleBadge(condition: Bool, color: Color = .red) -> some View {
        modifier(CircleBadgeModifier(condition: condition, color: color))
    }
}

@available(iOS 26, *)
#Preview("Default") {
    TabView {
        let viewModel = TimetableViewModel()
        Tab("Timetable", systemImage: "calendar.day.timeline.left") {
            TimetableScene(timetableViewModel: viewModel)
                .overlaySheet()
        }
        Tab("Friends", systemImage: "person") {
            Text("Friends")
        }

        Tab(role: .search) {
            LectureSearchScene(timetableViewModel: viewModel)
        }
    }
}

@available(iOS 26, *)
#Preview("Landscape", traits: .landscapeLeft) {
    TabView {
        let viewModel = TimetableViewModel()
        Tab("Timetable", systemImage: "calendar.day.timeline.left") {
            TimetableScene(timetableViewModel: viewModel)
                .overlaySheet()
        }
        Tab(role: .search) {
            LectureSearchScene(timetableViewModel: viewModel)
        }
    }
    .tabViewStyle(.sidebarAdaptable)
}
