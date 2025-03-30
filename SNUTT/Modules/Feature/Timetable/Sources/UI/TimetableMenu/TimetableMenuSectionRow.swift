//
//  TimetableMenuSectionRow.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI
import TimetableInterface

struct TimetableMenuSectionRow: View {
    let viewModel: TimetableMenuViewModel
    let timetableMetadata: TimetableMetadata
    let isSelected: Bool

    @State private var isLoadingTimetable = false
    @State private var isEllipsisMenuPresented = false
    @State private var isCopyingTimetable = false

    @Environment(\.errorAlertHandler) private var errorHandler

    private enum Design {
        static let detailFont = Font.system(size: 12)
    }

    var body: some View {
        HStack(spacing: 0) {
            Group {
                if isLoadingTimetable {
                    ProgressView()
                        .scaleEffect(0.7)
                } else {
                    TimetableAsset.checkmarkCircleTick.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .opacity(isSelected ? 1 : 0)
                }
            }
            .frame(width: 15, height: 15)
            .padding(.leading, 10)
            .padding(.trailing, 8)

            Button {
                Task {
                    guard !isLoadingTimetable else { return }
                    isLoadingTimetable = true
                    defer {
                        isLoadingTimetable = false
                    }
                    errorHandler.withAlert {
                        try await viewModel.selectTimetable(timetableID: timetableMetadata.id)
                    }
                }
            } label: {
                HStack {
                    Text(timetableMetadata.title)
                        .font(Design.detailFont)
                        .foregroundColor(Color(uiColor: .label))
                        .lineLimit(1)

                    Spacer().frame(width: 5)

                    Text(TimetableStrings.timetableToolbarTotalCredit(timetableMetadata.totalCredit))
                        .font(Design.detailFont)
                        .foregroundColor(Color(uiColor: .secondaryLabel))
                        .lineLimit(1)
                        .layoutPriority(0.5)

                    if timetableMetadata.isPrimary {
                        Spacer().frame(width: 5)

                        TimetableAsset.menuShared.swiftUIImage
                            .layoutPriority(1)
                    }
                }
                .animation(.defaultSpring, value: timetableMetadata.isPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }

            Spacer()

            Button {
                Task {
                    guard !isCopyingTimetable else { return }
                    isCopyingTimetable = true
                    defer {
                        isCopyingTimetable = false
                    }
                    await errorHandler.withAlert {
                        try await viewModel.copyTimetable(timetableID: timetableMetadata.id)
                    }
                }
            } label: {
                if isCopyingTimetable {
                    ProgressView()
                        .frame(width: 30, height: 30)
                        .scaleEffect(0.7)
                        .opacity(0.7)
                } else {
                    TimetableAsset.menuDuplicate.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30)
                        .opacity(0.5)
                }
            }

            Spacer().frame(width: 12)

            Button {
                isEllipsisMenuPresented = true
            } label: {
                TimetableAsset.menuEllipsis.swiftUIImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30)
                    .opacity(0.5)
            }
            .sheet(isPresented: $isEllipsisMenuPresented) {
                MenuEllipsisSheet(viewModel: viewModel, metadata: timetableMetadata)
            }
        }
        .animation(.defaultSpring, value: isSelected)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
