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
            isExpanded = quarter == current?.quarter
        }
        .onChange(of: current, perform: { newValue in
            if !isExpanded {
                // 현재 시간표가 속한 학기는 처음부터 확장되어 있도록 한다.
                withAnimation(.customSpring) {
                    isExpanded = quarter == current?.quarter
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
    let openEllipsis: ((TimetableMetadata) -> Void)?
    @State var isLoading: Bool = false

    var body: some View {
        HStack(spacing: 0) {
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
                HStack(spacing: 5) {
                    Text(timetableMetadata.title)
                        .font(.system(size: 15))
                        .lineLimit(1)

                    Text("(\(timetableMetadata.totalCredit)학점)")
                        .font(.system(size: 14))
                        .foregroundColor(Color(uiColor: .secondaryLabel))
                        .lineLimit(1)
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
                    .frame(width: 35)
                    .opacity(0.5)
            }
            Button {
                openEllipsis?(timetableMetadata)
            } label: {
                Image("menu.ellipsis")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 35)
                    .opacity(0.5)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

//struct MenuSection_Previews: PreviewProvider {
//    static var previews: some View {
//        ScrollView {
//            LazyVStack {
//                MenuSection(quarter: .init(year: 2022, semester: Semester(rawValue: 1)!)) {
//                    MenuSectionRow(timetableMetadata: .init(id: "434", year: 2022, semester: 2, title: "나의 시간표", updatedAt: "344343", totalCredit: 4), isSelected: false, selectTimetable: nil, duplicateTimetable: nil, openEllipsis: nil)
//                }
//            }
//        }
//    }
//}
