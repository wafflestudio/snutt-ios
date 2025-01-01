//
//  TimetableScene+Toolbar.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SwiftUI

extension TimetableScene {
    var toolbarContent: some View {
        HStack(spacing: 0) {
            if isSearchMode {
                SearchToolBarView(searchViewModel: searchViewModel)
                    .transition(toolbarTransition(from: .bottom))
            } else {
                timetableToolbarView
                    .transition(toolbarTransition(from: .top))
            }
        }
        .animation(.defaultSpring, value: isSearchMode)
        .frame(height: 40)
        .clipped()
    }

    private var timetableToolbarView: some View {
        HStack(spacing: 0) {
            ToolbarButton(image: TimetableAsset.navMenu.image) {
                timetableViewModel.isMenuPresented.toggle()
            }
            .timetableMenuSheet(isPresented: $timetableViewModel.isMenuPresented, viewModel: timetableViewModel)

            Text(timetableViewModel.timetableTitle)
                .font(.system(size: 17, weight: .bold))
                .minimumScaleFactor(0.9)
                .lineLimit(1)
                .padding(.trailing, 8)
            Text(TimetableStrings.timetableToolbarTotalCredit(timetableViewModel.totalCredit))
                .font(.system(size: 12))
                .foregroundColor(Color(UIColor.secondaryLabel))
            Spacer()
            ToolbarButton(image: TimetableAsset.navList.image) {
                timetableViewModel.paths = [.lectureList]
            }
            ToolbarButton(image: TimetableAsset.navAlarmOff.image) {
                timetableViewModel.paths = [.notificationList]
            }
        }
    }

    private func toolbarTransition(from edge: Edge) -> AnyTransition {
        if edge == .top {
            AnyTransition.asymmetric(
                insertion: AnyTransition(.blurReplace(.downUp).combined(with: .push(from: .top))),
                removal: AnyTransition(.blurReplace(.downUp).combined(with: .push(from: .bottom)))
            )
        } else {
            AnyTransition.asymmetric(
                insertion: AnyTransition(.blurReplace(.downUp).combined(with: .push(from: .bottom))),
                removal: AnyTransition(.blurReplace(.downUp).combined(with: .push(from: .top)))
            )
        }
    }
}
