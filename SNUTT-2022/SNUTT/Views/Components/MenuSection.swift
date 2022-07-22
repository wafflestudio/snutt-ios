//
//  MenuSection.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/22.
//

import SwiftUI

struct MenuSection<Content>: View where Content: View {
    let quarter: Quarter
    @State var isExpanded: Bool = true
    var content: () -> Content
    
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
    }
}

struct MenuSectionRow: View {
    let timetableMetadata: TimetableMetadata
    let isSelected: Bool
    let selectTimetable: ((String) async -> Void)?
//    let duplicateTimetable: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            Image("checkmark.circle.tick")
                .resizable()
                .scaledToFit()
                .frame(width: 15)
                .padding(.leading, 10)
                .padding(.trailing, 8)
                .opacity(isSelected ? 1 : 0)
            
            Button {
                Task {
                    await selectTimetable?(timetableMetadata.id)
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
                .contentShape(Rectangle())
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            
            Spacer()
            
            Button {
                
            } label: {
                Image("menu.duplicate")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 35)
                    .opacity(0.5)
            }
            Button {
                
            } label: {
                Image("menu.ellipsis")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 35)
                    .opacity(0.5)
            }

        }
        .frame(maxWidth: .infinity, alignment: .leading)
        
        let _ = debugChanges()
    }
}

struct MenuSection_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            LazyVStack {
                MenuSection(quarter: .init(year: 2022, semester: Semester(rawValue: 1)!)) {
                    MenuSectionRow(timetableMetadata: .init(id: "434", year: 2022, semester: 2, title: "나의 시간표", updatedAt: "344343", totalCredit: 4), isSelected: false, selectTimetable: nil)
                }
            }
        }

    }
}
