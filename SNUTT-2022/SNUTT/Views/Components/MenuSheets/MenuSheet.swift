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
                                    .font(STFont.detailLabel)
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
                                if let quarterTimetableList = timetablesByQuarter[quarter],
                                   let sortedTimetableList = quarterTimetableList.sorted(by: { $0.isPrimary && !$1.isPrimary })
                                {
                                    MenuSection(quarter: quarter, current: current, isEmptyQuarter: false) {
                                        Group {
                                            ForEach(sortedTimetableList, id: \.id) { timetable in
                                                MenuSectionRow(timetableMetadata: timetable,
                                                               isSelected: current?.id == timetable.id,
                                                               selectTimetable: selectTimetable,
                                                               duplicateTimetable: duplicateTimetable,
                                                               openEllipsis: openEllipsis)
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
                    // TODO: 새로운 시간표 생성했을 때 해당 위치로 스크롤하기
//                    .onChange(of: menuState.onCreateToggle) { _ in
//                        // due to Apple's bug, customSpring animation doesn't work for now
//                        withAnimation(.customSpring) {
//                            reader.scrollTo(timetableState.current?.quarter.hashValue, anchor: .bottom)
//                        }
//                    }
                }
            }
        }
    }
}
