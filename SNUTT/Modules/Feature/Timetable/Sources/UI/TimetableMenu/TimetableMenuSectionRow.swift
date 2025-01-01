//
//  TimetableMenuSectionRow.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import SwiftUI
import TimetableInterface

struct TimetableMenuSectionRow: View {
    let viewModel: TimetableMenuViewModel
    let timetableMetadata: any TimetableMetadata
    let isSelected: Bool

    @State private var isLoading: Bool = false

    private enum Design {
        static let detailFont = Font.system(size: 12)
    }

    var body: some View {
        HStack(spacing: 0) {
            Group {
                if isLoading {
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
                    guard !isLoading else { return }
                    isLoading = true
                    defer {
                        isLoading = false
                    }
                    try await viewModel.selectTimetable(timetableID: timetableMetadata.id)
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
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }

            Spacer()

            Button {
                Task {}
            } label: {
                TimetableAsset.menuDuplicate.swiftUIImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30)
                    .opacity(0.5)
            }

            Spacer().frame(width: 12)

            Button {} label: {
                TimetableAsset.menuEllipsis.swiftUIImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30)
                    .opacity(0.5)
            }
        }
        .animation(.defaultSpring, value: isSelected)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
