//
//  MenuSheet.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/22.
//

import SwiftUI

struct MenuSheet: View {
    @Binding var isOpen: Bool
    var openCreateSheet: @MainActor (Bool) -> Void
    var current: Timetable?
    var metadataList: [TimetableMetadata]?
    var timetablesByQuarter: [Quarter: [TimetableMetadata]]
    let selectTimetable: (String) async -> Void
    let duplicateTimetable: (String) async -> Void
    let openEllipsis: @MainActor (TimetableMetadata) -> Void

    var body: some View {
        Sheet(isOpen: $isOpen, orientation: .left(maxWidth: 320), cornerRadius: 0, sheetOpacity: 0.7) {
            VStack(spacing: 0) {
                HStack {
                    Logo(orientation: .horizontal)
                        .padding(.vertical)
                    Spacer()
                    Button {
                        isOpen = false
                    } label: {
                        Image("xmark.black")
                            .animation(.customSpring, value: isOpen)
                    }
                }
                .padding(.horizontal, 20)

                Divider()
                    .padding(.horizontal, 10)

                ScrollViewReader { _ in
                    ScrollView {
                        VStack(spacing: 15) {
                            HStack {
                                Text("나의 시간표")
                                    .font(STFont.regular14.font)
                                    .foregroundColor(Color(uiColor: .secondaryLabel))

                                Spacer()

                                Button {
                                    openCreateSheet(true)
                                } label: {
                                    Image("nav.plus")
                                        .resizable()
                                        .frame(width: 25, height: 25)
                                }
                            }
                            .padding(.horizontal, 15)

                            ForEach(Array(timetablesByQuarter.keys.sorted().reversed()), id: \.self) { quarter in
                                let isEmptyQuarter = (timetablesByQuarter[quarter] ?? []).isEmpty
                                if let quarterTimetableList = timetablesByQuarter[quarter] {
                                    MenuSection(quarter: quarter, current: current, isEmptyQuarter: isEmptyQuarter) {
                                        Group {
                                            ForEach(quarterTimetableList, id: \.id) { timetable in
                                                MenuSectionRow(timetableMetadata: timetable,
                                                               isSelected: current?.id == timetable.id,
                                                               selectTimetable: selectTimetable,
                                                               duplicateTimetable: duplicateTimetable,
                                                               openEllipsis: openEllipsis)
                                            }

                                            if isEmptyQuarter {
                                                Button {
                                                    // open CreateSheet without pickers
                                                    openCreateSheet(false)
                                                } label: {
                                                    Text("+ 시간표 추가하기")
                                                        .font(STFont.regular14.font)
                                                        .foregroundColor(Color(uiColor: .secondaryLabel))
                                                        .padding(.leading, 30)
                                                        .frame(maxWidth: .infinity, alignment: .leading)
                                                }
                                            }
                                        }
                                    }
                                    // in extreme cases, there might be hash collision
                                    .id(quarter.hashValue)
                                }
                            }
                        }
                        .padding(.top, 20)
                        .animation(.customSpring, value: metadataList)
                    }
                }
            }
            .analyticsScreen(.timetableMenu, isVisible: isOpen)
        }
    }
}
