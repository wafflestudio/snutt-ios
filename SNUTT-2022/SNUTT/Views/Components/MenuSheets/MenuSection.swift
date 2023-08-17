//
//  MenuSection.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/22.
//

import SwiftUI

struct MenuSection<Content>: View where Content: View {
    let quarter: Quarter
    let current: Timetable?

    let isEmptyQuarter: Bool
    var content: () -> Content

    @State var isExpanded: Bool = false

    var body: some View {
        VStack {
            Button {
                withAnimation(.customSpring) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 5) {
                    Text(quarter.longString())
                        .font(.system(size: 16, weight: .semibold))

                    Image("chevron.right")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 13)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0), anchor: .init(x: 0.75, y: 0.5))

                    if isEmptyQuarter {
                        CircleBadge(color: .red)
                            .padding(.leading, 8)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(spacing: 10) {
                    content()
                }
                .padding(.top, 5)
                .padding(.bottom, 15)
            }
        }
        .padding(.horizontal, 15)
        .frame(maxHeight: .infinity)
        .onAppear {
            // 새로운 학기와 현재 시간표가 속한 학기는 처음부터 확장되어 있도록 한다.
            isExpanded = (quarter == current?.quarter) || isEmptyQuarter
        }
        .onChange(of: current?.quarter, perform: { newValue in
            // 현재 시간표가 속한 학기는 처음부터 확장되어 있도록 한다.
            if !isExpanded {
                withAnimation(.customSpring) {
                    isExpanded = quarter == newValue
                }
            }
        })
    }
}

struct MenuSectionRow: View {
    let timetableMetadata: TimetableMetadata
    var isSelected: Bool
    let selectTimetable: ((String) async -> Void)?
    let duplicateTimetable: ((String) async -> Void)?
    let openEllipsis: (@MainActor (TimetableMetadata) -> Void)?
    @State var isLoading: Bool = false

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Group {
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.7)
                } else {
                    Image("checkmark.circle.tick")
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
                    isLoading = true
                    await selectTimetable?(timetableMetadata.id)
                    isLoading = false
                }
            } label: {
                HStack(alignment: .center) {
                    Text(timetableMetadata.title)
                        .font(STFont.detailLabel)
                        .lineLimit(1)
                    
                    Spacer().frame(width: 5)

                    Text("(\(timetableMetadata.totalCredit)학점)")
                        .font(STFont.detailLabel)
                        .foregroundColor(Color(uiColor: .secondaryLabel))
                        .lineLimit(1)
                        .layoutPriority(0.5)
                    
                    if timetableMetadata.isPrimary {
                        Spacer().frame(width: 4)
                        
                        PrimaryBadge()
                            .layoutPriority(1)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }

            Spacer()

            Button {
                Task {
                    await duplicateTimetable?(timetableMetadata.id)
                }
            } label: {
                Image("menu.duplicate")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30)
                    .opacity(0.5)
            }
            
            Spacer().frame(width: 12)
            
            Button {
                openEllipsis?(timetableMetadata)
            } label: {
                Image("menu.ellipsis")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30)
                    .opacity(0.5)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct PrimaryBadge: View {
    var body: some View {
        Text("대표")
            .font(.system(size: 8, weight: .semibold))
            .padding(.horizontal, 5)
            .padding(.vertical, 3)
            .foregroundColor(STColor.cyan)
            .background(RoundedRectangle(cornerRadius: 8).strokeBorder(STColor.cyan, lineWidth: 0.5))
            .environment(\.colorScheme, .light)
    }
}

// struct MenuSection_Previews: PreviewProvider {
//    static var previews: some View {
//        ScrollView {
//            LazyVStack {
//                MenuSection(quarter: .init(year: 2022, semester: Semester(rawValue: 1)!)) {
//                    MenuSectionRow(timetableMetadata: .init(id: "434", year: 2022, semester: 2, title: "나의 시간표", updatedAt: "344343", totalCredit: 4), isSelected: false, selectTimetable: nil, duplicateTimetable: nil, openEllipsis: nil)
//                }
//            }
//        }
//    }
// }
